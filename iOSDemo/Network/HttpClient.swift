//
//  HttpClient.swift
//  HttpClient
//
//  Created by Gforce on 11/22/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit
//internal enum HttpMethod:Int{
//    case get = 0
//    case post
//    case put
//    case delete
//    case head
//    
//     var discription:String{
//        get{
//            switch self {
//            case HttpMethod.get:
//                return "Get"
//            case HttpMethod.post:
//                return "Post"
//            case HttpMethod.put:
//                return "Put"
//            case HttpMethod.head:
//                return "Head"
//            case HttpMethod.delete:
//                return "Delete"
//            }
//        }
//    }
//}
public enum HttpClientRequestState{
    case ready
    case executing
    case finished
}
// 用户设定一些Option
public struct HttpClientOption {
   public static let TimeOut = "TimeOut"   // NSNumber 的Int类型  不然无效
   public static let UserAgent = "UserAgent"  //String 类型
   public static let CachePolicy = "CachePolicy" //当使用缓存时设置CachePolicy无效,``____`` 缓存不靠谱,我要 自己写缓存
   public static let SendParametersAsJSON  = "SendParametersAsJSON"   //NSNumber 的Bool类型  不然无效
   public static let UserName = "UserName"
   public static let Password = "Password"
   public static let SavePath = "SavePath"  // 要是个完整路径,不然会报错
   public static let UseFileName = "UseFileName"   //NSNumber 的Bool类型  不然无效
}
// 没有继承于NSObject，所以没有dealloc方法用
public final class HttpClient:Operation,NSURLConnectionDataDelegate{
    //private filed
    fileprivate var _httpClientRequestState:HttpClientRequestState = HttpClientRequestState.ready
    fileprivate var httpClientRequestState:HttpClientRequestState    {
        get{
            return _httpClientRequestState  //这里暂时用不了线程同步
        }
        set{
            objc_sync_enter(self)
            willChangeValue(forKey: "httpClientRequestState")
            _httpClientRequestState = newValue
            didChangeValue(forKey: "httpClientRequestState")
            objc_sync_exit(self)
        }
    }
    fileprivate static var taskCount:UInt = 0
    fileprivate static var GlobalTimeoutInterval:TimeInterval = 20
    fileprivate static var GlobalUserAgent:String = "HttpClient" //need check
    fileprivate static var GlobalCachePolicy:NSURLRequest.CachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
    fileprivate static var GlobalNeedSendParametersAsJSON = false
    fileprivate static var GlobalUserName:String?
    fileprivate static var GlobalPassword:String?
    fileprivate static let sharedQuene:OperationQueue = OperationQueue()
    fileprivate class var operationQueue:OperationQueue{
        get{
            return sharedQuene
        }
    }
    fileprivate static var cacheKeyDict:Dictionary<String,Date> = Dictionary<String,Date>()
    fileprivate class var sharedCacheKeyDict:Dictionary<String,Date>{
        set{
        print("before set")
        for (key,value) in HttpClient.cacheKeyDict{
        print("key:\(key) and value:\(value)")
        }
        HttpClient.cacheKeyDict = newValue
        print("after set")
        for (key,value) in HttpClient.cacheKeyDict{
        print("key:\(key) and value:\(value)")
        }
        }
        get{
            return HttpClient.cacheKeyDict
        }
    }
    
    fileprivate var httpHeaderFields:Dictionary<String,AnyObject>? //现在还没有用到，需要研究怎么用
    internal var operationRequest:NSMutableURLRequest?
    fileprivate var operationData:NSMutableData?
    fileprivate var operationFileHandle:FileHandle?
    fileprivate var operationConnection:NSURLConnection?
    fileprivate var operationParameters:Dictionary<String,AnyObject>?
    fileprivate var operationURLResponse:HTTPURLResponse?
    fileprivate var operationSavePath:String?
    fileprivate var operationRunLoop:CFRunLoop?
    fileprivate var cancelToken:String?
    fileprivate var isCacheInValid:Bool{
        get{
            if let key = operationRequest!.url?.absoluteString
            {
                if let expireDate = HttpClient.sharedCacheKeyDict[(key as NSString).removingPercentEncoding!]
                {
                    if Date().compare(expireDate) == ComparisonResult.orderedDescending{
                        print("key:\(key)的缓存已经失效")
                        return true
                    }
                    else
                    {
                        return false
                    }
                }
            }
            return true
            
        }
    }
    fileprivate var cacheTime:Int = 0
    fileprivate var backgroundTaskIdentifier:UIBackgroundTaskIdentifier?
    fileprivate var saveDataDispatchQueue:DispatchQueue
    fileprivate var saveDataDispatchGroup:DispatchGroup
    fileprivate var operationCompletion:((_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->())?
    fileprivate var operationProgress:((_ progress:Float)->())?
    fileprivate var queryParameters:Dictionary<String,AnyObject>?  //这个是如果使用Post上传，但是还是要在Url后面添加一些参数时的字段
    fileprivate var operationRequestOptions:Dictionary<String,AnyObject>? //这个是设置单独一次请求的相关参数，又如超时，缓存方式等
    fileprivate var requestPath:String?  //这也是一种取消请求的方法，需要研究
    fileprivate var _timeoutTimer:Timer?
    fileprivate var timeoutTimer:Timer?{
        get{
            return _timeoutTimer
        }
        set{
            if _timeoutTimer != nil{
                _timeoutTimer?.invalidate()
                _timeoutTimer = nil
            }
            _timeoutTimer = newValue
        }
    }
    fileprivate var expectedContentLength:Float = 0
    fileprivate var receivedContentLength:Float = 0
    fileprivate var configDict:Dictionary<String,AnyObject>?
    fileprivate var userAgent:String?   //这个可用一个option来设定 作为单次请求的参数
    fileprivate var timeoutInterval:TimeInterval //这个可以用一个Option来设定，作为单次请求的参数
    fileprivate var cachePolicy:NSURLRequest.CachePolicy //这个可以用一个Option来设定，作为单次请求的参数
    fileprivate var sendParametersAsJSON:Bool?
    fileprivate var Username:String?
    fileprivate var Password:String?
    fileprivate var useFileName:Bool = false //是否使用原始文件名上传，默认为否
    public override var isFinished:Bool{
        get{
            return httpClientRequestState == HttpClientRequestState.finished}
    }
    public override var isExecuting:Bool{
        get{
            return httpClientRequestState == HttpClientRequestState.executing
        }
    }
    
//    internal var requestInfo:RequestInfo?
    
    // MARK: public func
    // Global 的方法最好在APPDelegate设置,确保在任何调用前设置
   public static func setGlobalTimeoutInterval(_ timeInterval:TimeInterval){
        HttpClient.GlobalTimeoutInterval = timeInterval
    }
    
   public static func setGlobalUserAgent(_ userAgent:String){
        HttpClient.GlobalUserAgent = userAgent
    }
    
  public  static func setGlobalCachePolicy(_ cachePolicy:NSURLRequest.CachePolicy){
        HttpClient.GlobalCachePolicy = cachePolicy
    }
    
   public static func setGlobalNeedSendParametersAsJSON(_ sendParametersAsJSON:Bool){
        HttpClient.GlobalNeedSendParametersAsJSON = sendParametersAsJSON
    }
    
   public static func setGlobalUsername(_ userName:String){
        HttpClient.GlobalUserName = userName
    }
    
   public static func setGlobalPassword(_ pass:String){
        HttpClient.GlobalPassword = pass
    }
    
   public static func cancelRequestsWithPath(_ path:String){
        for queue in HttpClient.operationQueue.operations{
            if let httpClient = queue as? HttpClient{
                if let  requestPath = httpClient.requestPath
                {
                    if requestPath == path{
                        httpClient.cancel()
                    }
                }
            }
        }
    }
    
   public static func cancelAllRequests(){
        HttpClient.operationQueue.cancelAllOperations()
    }
    
    public static func getHttpState(_ identity:String)->HttpClientRequestState{
        for queue in HttpClient.operationQueue.operations{
            if let httpClient = queue as? HttpClient{
                if let  token = httpClient.cancelToken
                {
                    if token == identity{
                        return httpClient._httpClientRequestState
                    }
                }
            }
        }
        return HttpClientRequestState.ready
    }
    
   public static func cancelRequestWithIndentity(_ cancelToken:String){
        for queue in HttpClient.operationQueue.operations{
            if let httpClient = queue as? HttpClient{
                if let  token = httpClient.cancelToken
                {
                    if token == cancelToken{
                        httpClient.cancel()
                    }
                }
            }
        }
    }
    
   public static func clearUrlCache(_ url:String){
        HttpClient.sharedCacheKeyDict.removeValue(forKey: url)
        let path = HttpClient.getCacheFileName(url)
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch _ {
        }
    }
    
  public  static func urlCacheExist(_ url:String)->Bool{
        return   FileManager.default.fileExists(atPath: HttpClient.getCacheFileName(url))
    }
    
   public static func clearCache(){
        HttpClient.sharedCacheKeyDict.removeAll(keepingCapacity: false)
        var cachePath: AnyObject? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as AnyObject?
        cachePath = (cachePath as! NSString).appendingPathComponent("HttpClientCaches") as String as AnyObject?
        do {
            try FileManager.default.removeItem(atPath: cachePath as! String)
        } catch _ {
        }
    }
    
   public static func get(_ address:String,parameters:Dictionary<String,AnyObject>?,cache:Int,cancelToken:String?, queryPara:Dictionary<String,AnyObject>?, completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) ->HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.get, parameters: parameters, cache: cache, cancelToken: cancelToken, queryPara:queryPara, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func get(_ address:String,parameters:Dictionary<String,AnyObject>?,cache:Int,cancelToken:String?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) ->HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.get, parameters: parameters, cache: cache, cancelToken: cancelToken, queryPara:nil, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func get(_ address:String,parameters:Dictionary<String,AnyObject>?, cache:Int,cancelToken:String?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((_ progress:Float)->())?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) ->HttpClient {
        let httpClient = HttpClient(address: address, method: HttpMethod.get, parameters: parameters, cache: cache, cancelToken: cancelToken, queryPara:nil, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Post(_ address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?, completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) ->HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.post, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:nil, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Post(_ address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.post, parameters: parameters, cache: 0,  cancelToken: cancelToken, queryPara:queryPara, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
  public  static func Post(_ address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((_ progress:Float)->())?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.post, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:queryPara, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Delete(_ address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.delete, parameters: parameters, cache: 0,cancelToken: cancelToken, queryPara:nil, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Put(_ address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((_ progress:Float)->())?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.put, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:nil, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
  public  static func Head(_ address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((_ progress:Float)->())?,completion:@escaping (_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: HttpMethod.head, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:nil, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.url?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
    fileprivate override init(){
        saveDataDispatchGroup = DispatchGroup()
        saveDataDispatchQueue = DispatchQueue(label: "HttpClient", attributes: [])
        timeoutInterval = 20
        cachePolicy = HttpClient.GlobalCachePolicy
        super.init()
    }
    
    // MARK: private func
    fileprivate init(address:String,method:HttpMethod,parameters:Dictionary<String,AnyObject>?, cache:Int,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((_ progress:Float)->())?,completion:((_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->())?){
        operationCompletion = completion
        operationProgress = progress
        operationParameters = parameters
        queryParameters = queryPara
        timeoutInterval = HttpClient.GlobalTimeoutInterval
        sendParametersAsJSON = HttpClient.GlobalNeedSendParametersAsJSON
        httpHeaderFields = headerFields
        self.cancelToken = cancelToken
        saveDataDispatchGroup = DispatchGroup()
        saveDataDispatchQueue = DispatchQueue(label: "HttpClient", attributes: [])
        
        if let url  = URL(string: address){
            operationRequest = NSMutableURLRequest(url: url)
        }
        else{
            assert(false, "you pass a invalid url")  //非法的Url
        }
        if cache > 0{
            cacheTime = cache
            
        }
        
        switch(method){
        case .get: operationRequest?.httpMethod = "GET"
        case .post: operationRequest?.httpMethod = "POST"
        case .put: operationRequest?.httpMethod = "PUT"
        case .delete: operationRequest?.httpMethod = "DELETE"
        case .head: operationRequest?.httpMethod = "HEAD"
        }
        Username = HttpClient.GlobalUserName
        Password = HttpClient.GlobalPassword
        cachePolicy = HttpClient.GlobalCachePolicy
        if requestOptions != nil{
            for (key,value) in requestOptions!{
                switch key{
                case HttpClientOption.SavePath: operationSavePath = value as? String
                case HttpClientOption.CachePolicy:
                    if let policyValue = value as? NSURLRequest.CachePolicy.RawValue{
                        if let policy = NSURLRequest.CachePolicy(rawValue: policyValue){
                            cachePolicy = policy
                        }
                    }
                case HttpClientOption.Password:  Password = value as? String
                case HttpClientOption.SendParametersAsJSON:sendParametersAsJSON = value as? Bool
                case HttpClientOption.TimeOut:                    if let timeInterval = value as? TimeInterval{
                    timeoutInterval = timeInterval
                    }
                case HttpClientOption.UserAgent:    userAgent = value as? String
                case HttpClientOption.UserName:Username = value as? String
                case HttpClientOption.UseFileName:                    if let isUse = value as? Bool{
                    useFileName = isUse
                    }
                default: break
                }
            }
        }
        super.init()
        httpClientRequestState = HttpClientRequestState.ready
        if method != HttpMethod.post && operationSavePath == nil{
            operationRequest?.httpShouldUsePipelining = true
        }
        //这个要放在super.init()后面才行
        //这个地方以后需要研究
    }
    
    public override func start() {
        if isCancelled{
            finish()
            return
        }
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            if self.backgroundTaskIdentifier! != UIBackgroundTaskInvalid{
                UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
                self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            }
        })
        DispatchQueue.main.async(execute: { () -> Void in
            self.increaseTaskCount()
        })
        if operationParameters != nil{             //添加参数
            addParametersToRequest(operationParameters!)
        }
        if userAgent != nil{
            operationRequest?.setValue(userAgent!, forHTTPHeaderField: "User-Agent")
        }
        else
        {
            operationRequest?.setValue(HttpClient.GlobalUserAgent, forHTTPHeaderField: "User-Agent")
        }
        willChangeValue(forKey: "isExecuting") //改变状态
        httpClientRequestState = HttpClientRequestState.executing
        didChangeValue(forKey: "isExecuting")
        if operationSavePath != nil{  //如果需要保存数据
            if   FileManager.default.createFile(atPath: operationSavePath!, contents: nil, attributes: nil){
                operationFileHandle = FileHandle(forWritingAtPath: operationSavePath!)
            }
            else{
                assert(false, "error path")
                let exception = NSException(name: NSExceptionName(rawValue: "Invalid path"), reason: "you provide a invalid path", userInfo: [NSExceptionName.invalidArgumentException:operationSavePath!])
                exception.raise()
            }
        }
        operationData = NSMutableData() //即使保存数据,也是要加载的
        timeoutTimer = Timer.scheduledTimer(timeInterval: timeoutInterval, target: self, selector: #selector(HttpClient.requestTimeout), userInfo: nil, repeats: false)
        operationRequest?.timeoutInterval = timeoutInterval
        operationRequest?.cachePolicy = cachePolicy
        setHeadField()
        signRequestWithUsername()
        //检查有没有设置缓存
        if cacheTime > 0{
            //如果有缓存,检查有没有失效
            if isCacheInValid{  //如果 失效 , 什么也没干
                
            }
            else{ //没有失效,就不再请求,直接从Document获取数据返回
                let filePath = getCacheFileName()
                if FileManager.default.fileExists(atPath: filePath){
                    if let  data = try? Data(contentsOf: URL(fileURLWithPath: filePath)){
                        saveDataDispatchGroup.notify(queue: saveDataDispatchQueue) { () -> Void in
                            self.callCompletionBlockWithResponse(data as AnyObject?, error: nil)
                        }
                        return
                    }
                }
            }
        }
        operationConnection = NSURLConnection(request: operationRequest! as URLRequest, delegate: self, startImmediately: false)
        let currentQueue = OperationQueue.current
        let inBackgroundAndInOperationQueue = currentQueue != nil && currentQueue != OperationQueue.main
        let targetRunLoop = inBackgroundAndInOperationQueue ? RunLoop.current : RunLoop.main
        if operationSavePath != nil{
            operationConnection?.schedule(in: targetRunLoop, forMode: RunLoopMode.commonModes)
        }
        else{
            operationConnection?.schedule(in: targetRunLoop, forMode: RunLoopMode.defaultRunLoopMode)
        }
        operationConnection?.start()
        if let requestUrl = operationRequest?.url?.absoluteString
        {
            NSLog("[%@] %@", operationRequest!.httpMethod, requestUrl);
        }
        if cachePolicy == NSURLRequest.CachePolicy.returnCacheDataDontLoad
        {
            print("Network fail use Cache")
        }
        if inBackgroundAndInOperationQueue{
            operationRunLoop = CFRunLoopGetCurrent()
            CFRunLoopRun()
        }
    }
    //完成
    fileprivate func finish(){
        if isFinished{
            return
        }
        operationConnection?.cancel()
        operationConnection = nil
        decreaseTaskCount()
        if backgroundTaskIdentifier != UIBackgroundTaskInvalid{
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier!)
            backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        httpClientRequestState = HttpClientRequestState.finished
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
        //这里在完成时要从operationqueue里面移除的，但是好像没有办到，不过好像不怎么影响，所以还是
        //暂时不要管这个了OK。以后看有没有办法处理这个
    }
    //取消
    public override func cancel() {
        if !isExecuting{
            return
        }
        super.cancel()
        timeoutTimer = nil
        finish()
    }
    @objc fileprivate func requestTimeout(){
        if let failingUrl = operationRequest?.url{
            let userInfo = [NSLocalizedDescriptionKey:"The operation timed out.",NSURLErrorFailingURLErrorKey:failingUrl,NSURLErrorFailingURLStringErrorKey:failingUrl.absoluteString] as [String : Any]
            let timeoutError:NSError? = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: userInfo)
            connection(nil, error: timeoutError)
        }
    }
    
    public  func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        expectedContentLength = Float(response.expectedContentLength)
        receivedContentLength = 0
        operationURLResponse = response as? HTTPURLResponse
    }
    
    public func connection(_ connection: NSURLConnection, didReceive data: Data) {
        saveDataDispatchQueue.async(group: saveDataDispatchGroup) { () -> Void in
            if self.operationSavePath != nil{
                //try tatch
                if self.operationFileHandle != nil{
                    self.operationFileHandle?.write(data) //这要用到错误捕捉，但是swift没有错误捕捉，以后再补上
                }
                    //catch error
                else{
                    self.operationConnection?.cancel()
                    let info:Dictionary<String,AnyObject> = [NSFilePathErrorKey:self.operationSavePath! as AnyObject]
                    let writeError = NSError(domain: "HttpClientRequestWriteError", code: 0, userInfo: info)
                    let exception = NSException(name: NSExceptionName(rawValue: "write data file"), reason: "You provide a invalid path the you can not write data in the path", userInfo: [NSExceptionName.invalidArgumentException:writeError])
                    exception.raise()
                }
            }
            self.operationData!.append(data) //下载的同时也是可以接到到数据的
        }
        if operationProgress != nil{
            //如果返回的数据头不知道大小，就为-1
            if expectedContentLength != -1{
                receivedContentLength = receivedContentLength + Float(data.count)
                operationProgress!(receivedContentLength / expectedContentLength)
            }
            else{
                operationProgress!(-1)
            }
        }
    }
    
    public func connection(_ connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        if operationProgress != nil && operationRequest!.httpMethod == "POST"{
            operationProgress!(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        }
    }
    
    public func connectionDidFinishLoading(_ connection: NSURLConnection) {
        saveDataDispatchGroup.notify(queue: saveDataDispatchQueue) { () -> Void in
            var response = NSData(data: self.operationData! as Data) as Data
            var error:NSError?
            if  self.operationURLResponse!.mimeType == "application/json"{
                if self.operationData != nil && self.operationData!.length > 0{
                    do {
                        let jsonObject: Any = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.allowFragments)
                        response = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                    } catch let error1 as NSError {
                        error = error1
                    } catch {
                        fatalError()
                    }
                }
            }
            if  self.cacheTime > 0{
                if self.isCacheInValid{
                    if let key = self.operationRequest?.url?.absoluteString{
                        HttpClient.sharedCacheKeyDict[(key as NSString).removingPercentEncoding!] = Date(timeIntervalSinceNow: TimeInterval(self.cacheTime))
                        let filePath = self.getCacheFileName()
                        //NSFileManager.defaultManager().crea
                        FileManager.default.createFile(atPath: filePath, contents: response, attributes: nil)
                    }
                }
            }
            
            self.callCompletionBlockWithResponse(response as AnyObject?, error: error)
        }
    }
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        callCompletionBlockWithResponse(nil, error: error as NSError?)
    }
    
    fileprivate  func connection(_ connection:NSURLConnection?,error:NSError?){
        callCompletionBlockWithResponse(nil, error: error)
    }
    
    fileprivate func callCompletionBlockWithResponse(_ response:AnyObject?,error:NSError?){
        timeoutTimer = nil
        if operationRunLoop != nil{
            CFRunLoopStop(operationRunLoop)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            var serverError:NSError? = error
            if  serverError != nil && self.operationURLResponse?.statusCode == 500{
                let info = [NSLocalizedDescriptionKey:"Bad Server Response.",NSURLErrorFailingURLErrorKey:self.operationRequest!.url!,NSURLErrorFailingURLStringErrorKey:self.operationRequest!.url!.absoluteString] as [String : Any]
                serverError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo:info)
                
            }
            if  !self.isCancelled {
                self.operationCompletion!(response, self.operationURLResponse, serverError)
            }
            self.finish()
        })
    }
    public override var isAsynchronous:Bool{
        get{
            return true
        }
    }
    //增加任务数
    fileprivate  func increaseTaskCount(){
        HttpClient.taskCount += 1
        toggleNetworkActivityIndicator()
    }
    fileprivate  func toggleNetworkActivityIndicator(){
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = HttpClient.taskCount > 0
        })
    }
    fileprivate func decreaseTaskCount(){
        if HttpClient.taskCount > 0 {
            HttpClient.taskCount -= 1
            toggleNetworkActivityIndicator()
        }
        toggleNetworkActivityIndicator()
    }
    func synchronized(_ lock:AnyObject,closure:()->()){
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    fileprivate  func addParametersToRequest(_ parameters:Dictionary<String,AnyObject>){
        let method = operationRequest!.httpMethod
        if method == "POST" || method == "PUT"{
            if queryParameters != nil
            {
                var baseAddress = operationRequest!.url!.absoluteString
                if queryParameters!.count > 0{
                    let range =  (baseAddress as NSString).range(of: "?")
                    let containPara = range.length > 0
                    let sign = containPara ? "&" : "?"
                    baseAddress = baseAddress + sign + parameterStringForDictionary(queryParameters!)
                }
            }
            if sendParametersAsJSON!{
                operationRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var Error:NSError?
                var jsonData: Data?
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
                } catch let error as NSError {
                    Error = error
                    jsonData = nil
                }
                if Error != nil{
                    assert(false, "you use sendParametersAsJSON but the parameter contain invalid data")
                    let exception = NSException(name: NSExceptionName(rawValue: "InValidPara"), reason: "POST and PUT parameters must be provided as NSDictionary or NSArray when sendParametersAsJSON is set to YES.", userInfo: [NSExceptionName.invalidArgumentException:"POST and PUT parameters must be provided as NSDictionary or NSArray when sendParametersAsJSON is set to YES."])
                    exception.raise()
                }
                operationRequest?.httpBody = jsonData
            }
            else
            {
                var hasData = false
                for (_,value) in parameters{
                    if value is Data{
                        hasData = true
                    }
                    else if !(value is String) && !(value is NSString) && !(value is NSNumber){
                        assert(false, "\(operationRequest!.httpMethod)requests only accept NSString and NSNumber parameters.")
                        let exception = NSException(name: NSExceptionName(rawValue: "InValidPara"), reason: "\(operationRequest!.httpMethod)requests only accept NSString and NSNumber parameters.", userInfo: [NSExceptionName.invalidArgumentException:"\(operationRequest!.httpMethod)requests only accept NSString and NSNumber parameters."])
                        exception.raise()
                    }
                }
                if !hasData{
                    let stringData = (parameterStringForDictionary(parameters) as NSString).utf8String
                    let postData = NSMutableData(bytes: stringData, length: Int(strlen(stringData)))
                    operationRequest?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    operationRequest?.httpBody = postData as Data
                }
                else{
                    let boundary = "HttpClientRequestBoundary"
                    let contentType = "multipart/form-data; boundary=\(boundary)"
                    operationRequest?.setValue(contentType, forHTTPHeaderField: "Content-Type")
                    let postData = NSMutableData()
                    var dataIdx = 0
                    for (key,value) in parameters{
                        if !(value is Data){
                            postData.append(NSString(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
                            postData.append(NSString(format: "Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key).data(using: String.Encoding.utf8.rawValue)!)
                            postData.append(NSString(format: "%@", value as! NSObject).data(using: String.Encoding.utf8.rawValue)!) //有可能有问题，要测试
                            postData.append(NSString(string: "\r\n").data(using: String.Encoding.utf8.rawValue)!)
                        }
                        else{
                            postData.append(NSString(format: "--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
                            if let imgExtension = (value as! Data).getImageType(){
                                if useFileName{  // 实际上无法从NSData中获取文件名,所要想要用原始文件名上传,需要把key当作文件名传进来
                                    postData.append(NSString(format: "Content-Disposition: attachment; name=\"%@\"; filename=\"userfile%d%x.\(imgExtension)\"\r\n" as NSString, key,key).data(using: String.Encoding.utf8.rawValue)!)
                                }
                                else{
                                    postData.append(NSString(format: "Content-Disposition: attachment; name=\"\(key)\"; filename=\"userfile%d%x.\(imgExtension)\"\r\n" as NSString,Date(timeIntervalSince1970: 0) as CVarArg).data(using: String.Encoding.utf8.rawValue)!)
                                }
                                postData.append(NSString(format: "Content-Type: image/%@\r\n\r\n",imgExtension).data(using: String.Encoding.utf8.rawValue)!)
                            }
                            else{
                                if useFileName{
                                    postData.append(NSString(format: "Content-Disposition: attachment; name=\"%@\"; filename=\"userfile%d%x\"\r\n", key,dataIdx, Date(timeIntervalSince1970: 0) as CVarArg).data(using: String.Encoding.utf8.rawValue)!)
                                }
                                else{
                                    postData.append(NSString(format: "Content-Disposition: attachment; name=\"%@\"; filename=\"userfile%d%x\"\r\n", key,dataIdx,Date(timeIntervalSince1970: 0) as CVarArg).data(using: String.Encoding.utf8.rawValue)!)
                                }
                                postData.append(NSString(string: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
                            }
                            postData.append(value as! Data)
                            postData.append(NSString(string: "\r\n").data(using: String.Encoding.utf8.rawValue)!)
                            dataIdx += 1
                        }
                    }
                    postData.append(NSString(format: "--%@--\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
                    operationRequest?.httpBody = postData as Data
                }
                
            }
        }
        else {
            var baseAddress = operationRequest!.url!.absoluteString
            let range =  (baseAddress as NSString).range(of: "?")
            let containPara = range.length > 0
            let sign = containPara ? "&" : "?"
            if operationParameters != nil {
                if operationParameters!.count > 0{
                    var paras = operationParameters!
                    if(queryParameters != nil && queryParameters!.count > 0){
                        for (key, value) in queryParameters!{
                            paras[key] = value //
                        }
                    }
                    baseAddress = baseAddress + sign + "\(parameterStringForDictionary(paras))"
                }
                operationRequest!.url = URL(string: baseAddress)
            }
        }
    }
    
    fileprivate func signRequestWithUsername(){
        if Username != nil && Password != nil{
            let authStr = NSString(format: "%@:%@", Username!,Password!)
            let authData = authStr.data(using: String.Encoding.ascii.rawValue)
            let authValue = NSString(format: "Basic %@",authData!.base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed) as CVarArg)
            operationRequest?.setValue(authValue as String, forHTTPHeaderField: "Authorization")
        }
    }
    
    fileprivate func setHeadField(){
        if httpHeaderFields != nil{
            for (key,value) in httpHeaderFields!{
                if let str  = value as? String{
                    operationRequest?.setValue(key, forHTTPHeaderField: str)
                }
            }
        }
    }
    
    fileprivate func getCacheFileName()->String{
        var cachePath: AnyObject? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as AnyObject?
        cachePath = (cachePath as! NSString).appendingPathComponent("HttpClientCaches") as String as AnyObject?
        let url = operationRequest!.url!.absoluteString
        if !FileManager.default.fileExists(atPath: cachePath as! String) {
            do {
                try FileManager.default.createDirectory(atPath: cachePath as! String , withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        let path = (cachePath as! NSString).appendingPathComponent(HttpClient.convertUrlToFilename((url as NSString).removingPercentEncoding!))
        return path as String
    }
    
    fileprivate static func getCacheFileName(_ url:String)->String{
        var cachePath: AnyObject? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as AnyObject?
        cachePath = (cachePath as! NSString).appendingPathComponent("HttpClientCaches") as String as AnyObject?
        if !FileManager.default.fileExists(atPath: cachePath as! String) {
            do {
                try FileManager.default.createDirectory(atPath: cachePath as! String , withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        let path = (cachePath as! NSString).appendingPathComponent(convertUrlToFilename(url))
        return path as String
        
    }
    
    fileprivate static func convertUrlToFilename(_ url:String)->String{
        var result = (url as NSString).replacingOccurrences(of: "\\", with: "_")
        result = (result as NSString).replacingOccurrences(of: "?", with: "!")
        result = (result as NSString).replacingOccurrences(of: "&", with: "-")
        result = (result as NSString).replacingOccurrences(of: ":", with: "~")
        result = (result as NSString).replacingOccurrences(of: "/", with: "_")
        return result
    }
    fileprivate func parameterStringForDictionary(_ parameters:Dictionary<String,AnyObject>)->String{
        var arrParamters = [String]()
        for (key,value) in parameters{
            if value is String || value is NSString{
                arrParamters.append("\(key)=\((value as! String).encodedURLParameterString())")
            }
            else if value is NSNumber{
                arrParamters.append("\(key)=\(value)")
            }
            else{
                assert(false, "GET and DELETE parameters must be provided as NSDictionary")
                let exception = NSException(name: NSExceptionName(rawValue: "InValidPara"), reason: "GET and DELETE parameters must be provided as NSDictionary.", userInfo: [NSExceptionName.invalidArgumentException:"GET and DELETE parameters must be provided as NSDictionary"])
                exception.raise()
                
            }
        }
        return arrParamters.concat("&")
    }
}

extension String{
    func encodedURLParameterString()->String{
        let result  = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as CFString, nil, __CFStringMakeConstantString(":/=,!$&'()*+;[]@#?^%\"`<>{}\\|~ "), CFStringBuiltInEncodings.UTF8.rawValue)
        return result! as String
    }
    
}
extension Array{
    func concat(_ symble:String)->String{
        var str:String = ""
        if self.count == 0
        {
            return str
        }
        for i in 0..<self.count{
            if self[i] is String{
                if i == self.count - 1{
                    str = str + (self[i] as! String)
                }
                else
                {
                    str = str + (self[i] as! String) + symble
                }
            }
        }
        return str
    }
}

extension Data{
    func getImageType()->String?{
        if self.count > 4{
            var buffer:UnsafeMutablePointer<Int>? = nil
            (self as NSData).getBytes(&buffer, length: 4)
            print(buffer!)
            let imageType = buffer.debugDescription;
            switch  (imageType as NSString).substring(with: NSMakeRange((imageType as NSString).length - 8, 8)){
            case "e0ffd8ff": return "jpg"
            case "474e5089": return "png"
            case "00464947": return "gif"
            default: break
            }
        }
        return nil
    }
}


open class HttpClientManager:NSObject {
    fileprivate var httpclient:HttpClient!
    fileprivate var url:String!
    fileprivate var method:HttpMethod!
    fileprivate var params:Dictionary<String,AnyObject>?
    fileprivate var cacheTime:Int = 0
    fileprivate var cancelToken:String?
    fileprivate var queryPara:Dictionary<String,AnyObject>?
    fileprivate  var requestOptions:Dictionary<String,AnyObject>?
    fileprivate  var headerFields:Dictionary<String,AnyObject>?
    fileprivate var progress:((_ progress:Float)->())?
    fileprivate  var completion:((_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->())?
    open static func Get(_ url:String)->HttpClientManager{
        let h = HttpClientManager()
        h.url = url
        h.method = .get
        return h
    }
    open static func Post(_ url:String)->HttpClientManager{
        let h = HttpClientManager()
        h.url = url
        h.method = .post
        return h
    }
    
    open func addParams(_ params:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.params = params
        return self
    }
    
    open func cache(_ cacheTime:Int)->HttpClientManager{
        self.cacheTime = cacheTime
        return self
    }
    
    open func cancelToken(_ cancelToken:String?)->HttpClientManager{
        self.cancelToken = cancelToken
        return self
    }
    
    open func queryPara(_ queryPara:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.queryPara = queryPara
        return self
    }
    open func requestOptions(_ requestOptions:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.requestOptions = requestOptions
        return self
    }
    open func headerFields(_ headerFields:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.headerFields = headerFields
        return self
    }
    open func progress(_ progress:((_ progress:Float)->())?)->HttpClientManager{
        self.progress = progress
        return self
    }
    open func completion(_ completion:((_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->())?){
        self.completion = completion
        self.httpclient = HttpClient(address: url, method: method, parameters: params, cache: cacheTime, cancelToken: cancelToken, queryPara: queryPara, requestOptions: requestOptions, headerFields: headerFields, progress: progress, completion: completion)
        self.httpclient.requestPath = self.httpclient.operationRequest?.url?.absoluteString
        HttpClient.operationQueue.addOperation(self.httpclient)
    }
}

