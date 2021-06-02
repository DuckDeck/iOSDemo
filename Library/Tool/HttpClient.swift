//
//  HttpClient.swift
//  HttpClient
//
//  Created by Gforce on 11/22/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit
import Alamofire
class HttpClient{
    
    fileprivate var url:String!
    fileprivate var method:HTTPMethod!
    fileprivate var params:Dictionary<String,Any>?
    fileprivate var urlPara:Dictionary<String,Any>?
    fileprivate  var requestOptions:Dictionary<String,AnyObject>?
    fileprivate  var headers:HTTPHeaders?
    fileprivate var multipartFormData:MultipartFormData?
    //    fileprivate var progress:((_ progress:Float)->())?
    fileprivate var completedBlock:((_ data:Data?,_ error:Error?)->Void)?
    public static func get(_ url:String)->HttpClient{
        let m = HttpClient()
        m.url = url
        m.method = .get
        return m
    }
    
    public static func post(_ url:String)->HttpClient{
        let m = HttpClient()
        m.url = url
        m.method = .post
        return m
    }
    
    open func addParams(_ params:Dictionary<String,Any>?)->HttpClient{
        self.params = params
        return self
    }
    
    open func addUrlParams(_ params:Dictionary<String,Any>?)->HttpClient{
        self.urlPara = params
        return self
    }
    
    open func addHeaders(_ params:Dictionary<String,String>?)->HttpClient{
        if params == nil {
            return self
        }
        let header = HTTPHeaders(params!)
        self.headers = header
        return self
    }
    
    open func addMultiParams(params:Dictionary<String,Any>?)->HttpClient{
        let pa = MultipartFormData()
        for item in params! {
            if item.value is Int {
                pa.append(String(item.value as! Int).data(using: .utf8)!, withName: item.key)
            }
            else if item.value is String {
                pa.append((item.value as! String).data(using: .utf8)!, withName: item.key)
            }
            else if item.value is Data  {
                pa.append(item.value as! Data, withName: "filedata", fileName: "blob", mimeType: "application/octet-stream")
            }
        }
        self.multipartFormData = pa
        return self
    }
    
    open func completion(_ completion:((_ data:Data?,_ error:Error?)->Void)?){
        if !url.contain(subStr: "easylog"){
            GLog(message: url)
        }
        if let p = params{
            Log(message: p)
        }
        
        self.completedBlock = completion
        var paras = ""
        if urlPara != nil && (method == .post || method == .put) {
            for item in urlPara! {
                paras += "\(item.key)=\(item.value)&"
            }
            if paras.hasSuffix("&") {
                paras.removeLast()
            }
            if url.contains("?") {
                paras = "&" + paras
            }
            else{
                paras = "?" + paras
            }
        }
        
        if multipartFormData != nil {
            AF.upload(multipartFormData: multipartFormData!, to: self.url,headers: headers).response { data in
                if let d = data.data{
                    if let s = String(data: d, encoding: String.Encoding.utf8){
                        Log(message: s)
                    }
                }
                self.completedBlock?(data.data,data.error)
            }
        }
        else{
            AF.request(paras.isEmpty ? url : url + paras, method: method, parameters: params,headers: headers).responseData {  (data) in
                if let d = data.data{
                    if let s = String(data: d, encoding: String.Encoding.utf8){
                        Log(message: s)
                    }
                }
                self.completedBlock?(data.data,data.error)
            }
        }
        
        
    }
    
    
    
    public struct ArrayEncoding: ParameterEncoding {
        
        /// The options for writing the parameters as JSON data.
        public let options: JSONSerialization.WritingOptions
        
        
        /// Creates a new instance of the encoding using the given options
        ///
        /// - parameter options: The options used to encode the json. Default is `[]`
        ///
        /// - returns: The new instance
        public init(options: JSONSerialization.WritingOptions = []) {
            self.options = options
        }
        
        public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var urlRequest = try urlRequest.asURLRequest()
            
            guard let parameters = parameters,
                let array = parameters[arrayParametersKey] else {
                    return urlRequest
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: array, options: options)
                
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                urlRequest.httpBody = data
                
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
            
            return urlRequest
        }
    }
    
}
private let arrayParametersKey = "arrayParametersKey"
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}


//在Swift4下错误太多，根本改不过来。不需要改了，以后也不怎么用
/*
private enum httpMethod{
    case Get
    case Post
    case Put
    case Delete
    case Head
}
public enum HttpClientRequestState{
    case Ready
    case Executing
    case Finished
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
    private var _httpClientRequestState:HttpClientRequestState = HttpClientRequestState.Ready
    private var httpClientRequestState:HttpClientRequestState    {
        get{
            return _httpClientRequestState  //这里暂时用不了线程同步
        }
        set{
            objc_sync_enter(self)
            willChangeValue(forKey:"httpClientRequestState")
            _httpClientRequestState = newValue
            didChangeValue(forKey:"httpClientRequestState")
            objc_sync_exit(self)
        }
    }
    private static var taskCount:UInt = 0
    private static var GlobalTimeoutInterval:TimeInterval = 20
    private static var GlobalUserAgent:String = "HttpClient" //need check
    private static var GlobalCachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
    private static var GlobalNeedSendParametersAsJSON = false
    private static var GlobalUserName:String?
    private static var GlobalPassword:String?
    private static let sharedQuene:OperationQueue = OperationQueue()
    private class var operationQueue:OperationQueue{
        get{
            return sharedQuene
        }
    }
    private static var cacheKeyDict:Dictionary<String,NSDate> = Dictionary<String,NSDate>()
    private class var sharedCacheKeyDict:Dictionary<String,NSDate>{
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
    
    private var httpHeaderFields:Dictionary<String,AnyObject>? //现在还没有用到，需要研究怎么用
    private var operationRequest:NSMutableURLRequest?
    private var operationData:NSMutableData?
    private var operationFileHandle:FileHandle?
    private var operationConnection:NSURLConnection?
    private var operationParameters:Dictionary<String,AnyObject>?
    private var operationURLResponse:HTTPURLResponse?
    private var operationSavePath:String?
    private var operationRunLoop:CFRunLoop?
    private var cancelToken:String?
    private var isCacheInValid:Bool{
        get{
            if let key = operationRequest!.URL?.absoluteString.stringByRemovingPercentEncoding
            {
                if let expireDate = HttpClient.sharedCacheKeyDict[key]
                {
                    if NSDate().compare(expireDate) == NSComparisonResult.OrderedDescending{
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
    private var cacheTime:Int = 0
    private var backgroundTaskIdentifier:UIBackgroundTaskIdentifier?
    private var saveDataDispatchQueue:dispatch_queue_t
    private var saveDataDispatchGroup:dispatch_group_t
    private var operationCompletion:((_ response:AnyObject?,_  urlResponse:HTTPURLResponse?,_ error:NSError?)->())?
    private var operationProgress:((_ progress:Float)->())?
    private var queryParameters:Dictionary<String,AnyObject>?  //这个是如果使用Post上传，但是还是要在Url后面添加一些参数时的字段
    private var operationRequestOptions:Dictionary<String,AnyObject>? //这个是设置单独一次请求的相关参数，又如超时，缓存方式等
    private var requestPath:String?  //这也是一种取消请求的方法，需要研究
    private var _timeoutTimer:Timer?
    private var timeoutTimer:Timer?{
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
    private var expectedContentLength:Float = 0
    private var receivedContentLength:Float = 0
    private var configDict:Dictionary<String,AnyObject>?
    private var userAgent:String?   //这个可用一个option来设定 作为单次请求的参数
    private var timeoutInterval:TimeInterval //这个可以用一个Option来设定，作为单次请求的参数
    private var cachePolicy:NSURLRequest.CachePolicy //这个可以用一个Option来设定，作为单次请求的参数
    private var sendParametersAsJSON:Bool?
    private var Username:String?
    private var Password:String?
    private var useFileName:Bool = false //是否使用原始文件名上传，默认为否
    public override var isFinished:Bool{
        get{
            return httpClientRequestState == HttpClientRequestState.Finished}
    }
    public override var isExecuting:Bool{
        get{
            return httpClientRequestState == HttpClientRequestState.Executing
        }
    }
    // MARK: public func
    // Global 的方法最好在APPDelegate设置,确保在任何调用前设置
    public static func setGlobalTimeoutInterval(timeInterval:TimeInterval){
        HttpClient.GlobalTimeoutInterval = timeInterval
    }
    
   public static func setGlobalUserAgent(userAgent:String){
        HttpClient.GlobalUserAgent = userAgent
    }
    
    public  static func setGlobalCachePolicy(cachePolicy:NSURLRequest.CachePolicy){
        HttpClient.GlobalCachePolicy = cachePolicy
    }
    
   public static func setGlobalNeedSendParametersAsJSON(sendParametersAsJSON:Bool){
        HttpClient.GlobalNeedSendParametersAsJSON = sendParametersAsJSON
    }
    
   public static func setGlobalUsername(userName:String){
        HttpClient.GlobalUserName = userName
    }
    
   public static func setGlobalPassword(pass:String){
        HttpClient.GlobalPassword = pass
    }
    
   public static func cancelRequestsWithPath(path:String){
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
    
    
    public static func getHttpState(identity:String)->HttpClientRequestState{
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
        return HttpClientRequestState.Ready
    }
    
   public static func cancelRequestWithIndentity(cancelToken:String){
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
    
   public static func clearUrlCache(url:String){
    HttpClient.sharedCacheKeyDict.removeValue(forKey: url)
    let path = HttpClient.getCacheFileName(url: url)
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch _ {
        }
    }
    
  public  static func urlCacheExist(url:String)->Bool{
    return   FileManager.default.fileExists(atPath: HttpClient.getCacheFileName(url: url))
    }
    
   public static func clearCache(){
    HttpClient.sharedCacheKeyDict.removeAll(keepingCapacity: false)
    var cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.CachesDirectory, FileManager.SearchPathDomainMask.UserDomainMask, true).first
        cachePath = (cachePath as! NSString).stringByAppendingPathComponent("HttpClientCaches") as String
        do {
            try FileManager.default.removeItemAtPath(cachePath as! String)
        } catch _ {
        }
    }
    
    public static func get(_ address:String,_ parameters:Dictionary<String,AnyObject>?,_ cache:Int,_ cancelToken:String?,_ queryPara:Dictionary<String,AnyObject>?,_ completion:(_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->()) ->HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Get, parameters: parameters, cache: cache, cancelToken: cancelToken, queryPara:queryPara, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func get(address:String,parameters:Dictionary<String,AnyObject>?,cache:Int,cancelToken:String?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) ->HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Get, parameters: parameters, cache: cache, cancelToken: cancelToken, queryPara:nil, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func get(address:String,parameters:Dictionary<String,AnyObject>?, cache:Int,cancelToken:String?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((progress:Float)->())?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) ->HttpClient {
        let httpClient = HttpClient(address: address, method: httpMethod.Get, parameters: parameters, cache: cache, cancelToken: cancelToken, queryPara:nil, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Post(address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?, completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) ->HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Post, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:nil, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Post(address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Post, parameters: parameters, cache: 0,  cancelToken: cancelToken, queryPara:queryPara, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
  public  static func Post(address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((progress:Float)->())?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Post, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:queryPara, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Delete(address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Delete, parameters: parameters, cache: 0,cancelToken: cancelToken, queryPara:nil, requestOptions:nil,headerFields:nil, progress: nil, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
   public static func Put(address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((progress:Float)->())?,completion:(response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Put, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:nil, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
  public  static func Head(address:String,parameters:Dictionary<String,AnyObject>?,cancelToken:String?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((_ progress:Float)->())?,_ completion:(response:AnyObject?,_ urlResponse:NSHTTPURLResponse?,_ error:NSError?)->()) -> HttpClient{
        let httpClient = HttpClient(address: address, method: httpMethod.Head, parameters: parameters, cache: 0, cancelToken: cancelToken, queryPara:nil, requestOptions:requestOptions,headerFields:headerFields, progress: progress, completion: completion)
        httpClient.requestPath = httpClient.operationRequest?.URL?.absoluteString
        self.operationQueue.addOperation(httpClient)
        return httpClient
    }
    
    private override init(){
        saveDataDispatchGroup = dispatch_group_create()
        saveDataDispatchQueue = dispatch_queue_create("HttpClient", DISPATCH_QUEUE_SERIAL)
        timeoutInterval = 20
        cachePolicy = HttpClient.GlobalCachePolicy
        super.init()
    }
    
    // MARK: private func
    private init(address:String,method:httpMethod,parameters:Dictionary<String,AnyObject>?, cache:Int,cancelToken:String?,queryPara:Dictionary<String,AnyObject>?, requestOptions:Dictionary<String,AnyObject>?,headerFields:Dictionary<String,AnyObject>?, progress:((progress:Float)->())?,completion:((response:AnyObject?,urlResponse:NSHTTPURLResponse?,error:NSError?)->())?){
        operationCompletion = completion
        operationProgress = progress
        operationParameters = parameters
        queryParameters = queryPara
        timeoutInterval = HttpClient.GlobalTimeoutInterval
        sendParametersAsJSON = HttpClient.GlobalNeedSendParametersAsJSON
        httpHeaderFields = headerFields
        self.cancelToken = cancelToken
        saveDataDispatchGroup = dispatch_group_create()
        saveDataDispatchQueue = dispatch_queue_create("HttpClient", DISPATCH_QUEUE_SERIAL)
        
        if let url  = NSURL(string: address){
            operationRequest = NSMutableURLRequest(URL: url)
        }
        else{
            assert(false, "you pass a invalid url")  //非法的Url
        }
        if cache > 0{
            cacheTime = cache
            
        }
        
        switch(method){
        case .Get: operationRequest?.HTTPMethod = "GET"
        case .Post: operationRequest?.HTTPMethod = "POST"
        case .Put: operationRequest?.HTTPMethod = "PUT"
        case .Delete: operationRequest?.HTTPMethod = "DELETE"
        case .Head: operationRequest?.HTTPMethod = "HEAD"
        }
        Username = HttpClient.GlobalUserName
        Password = HttpClient.GlobalPassword
        cachePolicy = HttpClient.GlobalCachePolicy
        if requestOptions != nil{
            for (key,value) in requestOptions!{
                switch key{
                case HttpClientOption.SavePath: operationSavePath = value as? String
                case HttpClientOption.CachePolicy:
                    if let policyValue = value as? NSURLRequestCachePolicy.RawValue{
                        if let policy = NSURLRequestCachePolicy(rawValue: policyValue){
                            cachePolicy = policy
                        }
                    }
                case HttpClientOption.Password:  Password = value as? String
                case HttpClientOption.SendParametersAsJSON:sendParametersAsJSON = value as? Bool
                case HttpClientOption.TimeOut:                    if let timeInterval = value as? NSTimeInterval{
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
        httpClientRequestState = HttpClientRequestState.Ready
        if method != httpMethod.Post && operationSavePath == nil{
            operationRequest?.HTTPShouldUsePipelining = true
        }
        //这个要放在super.init()后面才行
        //这个地方以后需要研究
    }
    
    public override func start() {
        if cancelled{
            finish()
            return
        }
        backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            if self.backgroundTaskIdentifier! != UIBackgroundTaskInvalid{
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
                self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            }
        })
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
        willChangeValueForKey("isExecuting") //改变状态
        httpClientRequestState = HttpClientRequestState.Executing
        didChangeValueForKey("isExecuting")
        if operationSavePath != nil{  //如果需要保存数据
            if   NSFileManager.defaultManager().createFileAtPath(operationSavePath!, contents: nil, attributes: nil){
                operationFileHandle = NSFileHandle(forWritingAtPath: operationSavePath!)
            }
            else{
                assert(false, "error path")
                let exception = NSException(name: "Invalid path", reason: "you provide a invalid path", userInfo: [NSInvalidArgumentException:operationSavePath!])
                exception.raise()
            }
        }
        operationData = NSMutableData() //即使保存数据,也是要加载的
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutInterval, target: self, selector: "requestTimeout", userInfo: nil, repeats: false)
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
                if NSFileManager.defaultManager().fileExistsAtPath(filePath){
                    if let  data = NSData(contentsOfFile: filePath){
                        dispatch_group_notify(saveDataDispatchGroup, saveDataDispatchQueue) { () -> Void in
                            self.callCompletionBlockWithResponse(data, error: nil)
                        }
                        return
                    }
                }
            }
        }
        operationConnection = NSURLConnection(request: operationRequest!, delegate: self, startImmediately: false)
        let currentQueue = NSOperationQueue.currentQueue()
        let inBackgroundAndInOperationQueue = currentQueue != nil && currentQueue != NSOperationQueue.mainQueue()
        let targetRunLoop = inBackgroundAndInOperationQueue ? NSRunLoop.currentRunLoop() : NSRunLoop.mainRunLoop()
        if operationSavePath != nil{
            operationConnection?.scheduleInRunLoop(targetRunLoop, forMode: NSRunLoopCommonModes)
        }
        else{
            operationConnection?.scheduleInRunLoop(targetRunLoop, forMode: NSDefaultRunLoopMode)
        }
        operationConnection?.start()
        if let requestUrl = operationRequest?.URL?.absoluteString
        {
            NSLog("[%@] %@", operationRequest!.HTTPMethod, requestUrl);
        }
        if cachePolicy == NSURLRequestCachePolicy.ReturnCacheDataDontLoad
        {
            print("Network fail use Cache")
        }
        if inBackgroundAndInOperationQueue{
            operationRunLoop = CFRunLoopGetCurrent()
            CFRunLoopRun()
        }
    }
    //完成
    private func finish(){
        if isFinished{
            return
        }
        operationConnection?.cancel()
        operationConnection = nil
        decreaseTaskCount()
        if backgroundTaskIdentifier != UIBackgroundTaskInvalid{
            UIApplication.sharedApplication().endBackgroundTask(backgroundTaskIdentifier!)
            backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
        willChangeValueForKey("isExecuting")
        willChangeValueForKey("isFinished")
        httpClientRequestState = HttpClientRequestState.Finished
        didChangeValueForKey("isExecuting")
        didChangeValueForKey("isFinished")
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
    @objc private func requestTimeout(){
        if let failingUrl = operationRequest?.URL{
            let userInfo = [NSLocalizedDescriptionKey:"The operation timed out.",NSURLErrorFailingURLErrorKey:failingUrl,NSURLErrorFailingURLStringErrorKey:failingUrl.absoluteString]
            let timeoutError:NSError? = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: userInfo)
            connection(nil, error: timeoutError)
        }
    }
    
    public  func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        expectedContentLength = Float(response.expectedContentLength)
        receivedContentLength = 0
        operationURLResponse = response as? NSHTTPURLResponse
    }
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        dispatch_group_async(saveDataDispatchGroup, saveDataDispatchQueue) { () -> Void in
            if self.operationSavePath != nil{
                //try tatch
                if self.operationFileHandle != nil{
                    self.operationFileHandle?.writeData(data) //这要用到错误捕捉，但是swift没有错误捕捉，以后再补上
                }
                    //catch error
                else{
                    self.operationConnection?.cancel()
                    let info:Dictionary<String,AnyObject> = [NSFilePathErrorKey:self.operationSavePath!]
                    let writeError = NSError(domain: "HttpClientRequestWriteError", code: 0, userInfo: info)
                    let exception = NSException(name: "write data file", reason: "You provide a invalid path the you can not write data in the path", userInfo: [NSInvalidArgumentException:writeError])
                    exception.raise()
                }
            }
            self.operationData!.appendData(data) //下载的同时也是可以接到到数据的
        }
        if operationProgress != nil{
            //如果返回的数据头不知道大小，就为-1
            if expectedContentLength != -1{
                receivedContentLength = receivedContentLength + Float(data.length)
                operationProgress!(progress: receivedContentLength / expectedContentLength)
            }
            else{
                operationProgress!(progress: -1)
            }
        }
    }
    
    public func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        if operationProgress != nil && operationRequest!.HTTPMethod == "POST"{
            operationProgress!(progress: Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        }
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        dispatch_group_notify(saveDataDispatchGroup, saveDataDispatchQueue) { () -> Void in
            var response = NSData(data: self.operationData!)
            var error:NSError?
            if  self.operationURLResponse!.MIMEType == "application/json"{
                if self.operationData != nil && self.operationData!.length > 0{
                    do {
                        let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.AllowFragments)
                        response = try! NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions.PrettyPrinted)
                    } catch let error1 as NSError {
                        error = error1
                    } catch {
                        fatalError()
                    }
                }
            }
            if  self.cacheTime > 0{
                if self.isCacheInValid{
                    if let key = self.operationRequest?.URL?.absoluteString.stringByRemovingPercentEncoding{
                        HttpClient.sharedCacheKeyDict[key] = NSDate(timeIntervalSinceNow: NSTimeInterval(self.cacheTime))
                        let filePath = self.getCacheFileName()
                        //NSFileManager.defaultManager().crea
                        NSFileManager.defaultManager().createFileAtPath(filePath, contents: response, attributes: nil)
                    }
                }
            }
            self.callCompletionBlockWithResponse(response, error: error)
        }
    }
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        callCompletionBlockWithResponse(nil, error: error)
    }
    
    private  func connection(connection:NSURLConnection?,error:NSError?){
        callCompletionBlockWithResponse(nil, error: error)
    }
    private func callCompletionBlockWithResponse(response:AnyObject?,error:NSError?){
        timeoutTimer = nil
        if operationRunLoop != nil{
            CFRunLoopStop(operationRunLoop)
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var serverError:NSError? = error
            if  serverError != nil && self.operationURLResponse?.statusCode == 500{
                let info = [NSLocalizedDescriptionKey:"Bad Server Response.",NSURLErrorFailingURLErrorKey:self.operationRequest!.URL!,NSURLErrorFailingURLStringErrorKey:self.operationRequest!.URL!.absoluteString]
                serverError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo:info)
                
            }
            if  !self.cancelled {
                if let completed = self.operationCompletion{
                    completed(response: response, urlResponse: self.operationURLResponse, error: serverError)
                }
            }
            self.finish()
        })
    }
    public override var asynchronous:Bool{
        get{
            return true
        }
    }
    //增加任务数
    private  func increaseTaskCount(){
        //print("increaseTaskCount\(HttpClient.taskCount)")
        HttpClient.taskCount++
        //print("increaseTaskCount\(HttpClient.taskCount)")
        toggleNetworkActivityIndicator()
    }
    private  func toggleNetworkActivityIndicator(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = HttpClient.taskCount > 0
        })
    }
    private func decreaseTaskCount(){
        if HttpClient.taskCount > 0 {
            //print("decreaseTaskCount\(HttpClient.taskCount)")
            HttpClient.taskCount--
            //print("decreaseTaskCount\(HttpClient.taskCount)")
            toggleNetworkActivityIndicator()
        }
    }
    func synchronized(lock:AnyObject,closure:()->()){
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    private  func addParametersToRequest(parameters:Dictionary<String,AnyObject>){
        let method = operationRequest!.HTTPMethod
        if method == "POST" || method == "PUT"{
            if queryParameters != nil
            {
                var baseAddress = operationRequest!.URL!.absoluteString
                if queryParameters!.count > 0{
                    let range =  (baseAddress as NSString).rangeOfString("?")
                    let containPara = range.length > 0
                    let sign = containPara ? "&" : "?"
                    baseAddress = baseAddress + sign + parameterStringForDictionary(queryParameters!)
                    operationRequest!.URL = NSURL(string: baseAddress)
                }
            }
            if sendParametersAsJSON!{
                operationRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var Error:NSError?
                var jsonData: NSData?
                do {
                    jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                } catch let error as NSError {
                    Error = error
                    jsonData = nil
                }
                if Error != nil{
                    assert(false, "you use sendParametersAsJSON but the parameter contain invalid data")
                    let exception = NSException(name: "InValidPara", reason: "POST and PUT parameters must be provided as NSDictionary or NSArray when sendParametersAsJSON is set to YES.", userInfo: [NSInvalidArgumentException:"POST and PUT parameters must be provided as NSDictionary or NSArray when sendParametersAsJSON is set to YES."])
                    exception.raise()
                }
                operationRequest?.HTTPBody = jsonData
            }
            else
            {
                var hasData = false
                for (_,value) in parameters{
                    if value is NSData{
                        hasData = true
                    }
                    else if !(value is String) && !(value is NSString) && !(value is NSNumber){
                        assert(false, "\(operationRequest!.HTTPMethod)requests only accept NSString and NSNumber parameters.")
                        let exception = NSException(name: "InValidPara", reason: "\(operationRequest!.HTTPMethod)requests only accept NSString and NSNumber parameters.", userInfo: [NSInvalidArgumentException:"\(operationRequest!.HTTPMethod)requests only accept NSString and NSNumber parameters."])
                        exception.raise()
                    }
                }
                if !hasData{
                    let stringData = (parameterStringForDictionary(parameters) as NSString).UTF8String
                    let postData = NSMutableData(bytes: stringData, length: Int(strlen(stringData)))
                    operationRequest?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    operationRequest?.HTTPBody = postData
                }
                else{
                    let boundary = "HttpClientRequestBoundary"
                    let contentType = "multipart/form-data; boundary=\(boundary)"
                    operationRequest?.setValue(contentType, forHTTPHeaderField: "Content-Type")
                    let postData = NSMutableData()
                    var dataIdx = 0
                    for (key,value) in parameters{
                        if !(value is NSData){
                            postData.appendData(NSString(format: "--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                            postData.appendData(NSString(format: "Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key).dataUsingEncoding(NSUTF8StringEncoding)!)
                            postData.appendData(NSString(format: "%@", value as! NSObject).dataUsingEncoding(NSUTF8StringEncoding)!) //有可能有问题，要测试
                            postData.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                        }
                        else{
                            postData.appendData(NSString(format: "--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                            if let imgExtension = value.getImageType(){
                                if useFileName{  // 实际上无法从NSData中获取文件名,所要想要用原始文件名上传,需要把key当作文件名传进来
                                    postData.appendData(NSString(format: "Content-Disposition: attachment; name=\"%@\"; filename=\"userfile%d%x.\(imgExtension)\"\r\n", key,key).dataUsingEncoding(NSUTF8StringEncoding)!)
                                }
                                else{
                                    postData.appendData(NSString(format: "Content-Disposition: attachment; name=\"\(key)\"; filename=\"userfile%d%x.\(imgExtension)\"\r\n",NSDate(timeIntervalSince1970: 0)).dataUsingEncoding(NSUTF8StringEncoding)!)
                                }
                                postData.appendData(NSString(format: "Content-Type: image/%@\r\n\r\n",imgExtension).dataUsingEncoding(NSUTF8StringEncoding)!)
                            }
                            else{
                                if useFileName{
                                    postData.appendData(NSString(format: "Content-Disposition: attachment; name=\"%@\"; filename=\"userfile%d%x\"\r\n", key,dataIdx, NSDate(timeIntervalSince1970: 0)).dataUsingEncoding(NSUTF8StringEncoding)!)
                                }
                                else{
                                    postData.appendData(NSString(format: "Content-Disposition: attachment; name=\"%@\"; filename=\"userfile%d%x\"\r\n", key,dataIdx,NSDate(timeIntervalSince1970: 0)).dataUsingEncoding(NSUTF8StringEncoding)!)
                                }
                                postData.appendData(NSString(string: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                            }
                            postData.appendData(value as! NSData)
                            postData.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                            dataIdx++
                        }
                    }
                    postData.appendData(NSString(format: "--%@--\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                    operationRequest?.HTTPBody = postData
                }
                
            }
        }
        else {
            var baseAddress = operationRequest!.URL!.absoluteString
            let range =  (baseAddress as NSString).rangeOfString("?")
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
                operationRequest!.URL =  URL(string: baseAddress)
            }
        }
    }
    
    private func signRequestWithUsername(){
        if Username != nil && Password != nil{
            let authStr = NSString(format: "%@:%@", Username!,Password!)
            let authData = authStr.dataUsingEncoding(NSASCIIStringEncoding.rawValue)
            let authValue = NSString(format: "Basic %@",authData!.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed))
            operationRequest?.setValue(authValue as String, forHTTPHeaderField: "Authorization")
        }
    }
    
    private func setHeadField(){
        if httpHeaderFields != nil{
            for (key,value) in httpHeaderFields!{
                if let str  = value as? String{
                    operationRequest?.setValue(key, forHTTPHeaderField: str)
                }
            }
        }
    }
    
    private func getCacheFileName()->String{
        var cachePath: AnyObject? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        cachePath = (cachePath as! NSString).stringByAppendingPathComponent("HttpClientCaches") as String
        let url = operationRequest!.URL!.absoluteString.stringByRemovingPercentEncoding!
        if !NSFileManager.defaultManager().fileExistsAtPath(cachePath as! String) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(cachePath as! String , withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        let path = (cachePath as! NSString).stringByAppendingPathComponent(HttpClient.convertUrlToFilename(url))
        return path as String
    }
    
    private static func getCacheFileName(url:String)->String{
        var cachePath: AnyObject? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        cachePath = (cachePath as! NSString).stringByAppendingPathComponent("HttpClientCaches") as String
        if !NSFileManager.defaultManager().fileExistsAtPath(cachePath as! String) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(cachePath as! String , withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        let path = (cachePath as! NSString).stringByAppendingPathComponent(convertUrlToFilename(url))
        return path as String
        
    }
    
    private static func convertUrlToFilename(url:String)->String{
        var result = (url as NSString).stringByReplacingOccurrencesOfString("\\", withString: "_")
        result = (result as NSString).stringByReplacingOccurrencesOfString("?", withString: "!")
        result = (result as NSString).stringByReplacingOccurrencesOfString("&", withString: "-")
        result = (result as NSString).stringByReplacingOccurrencesOfString(":", withString: "~")
        result = (result as NSString).stringByReplacingOccurrencesOfString("/", withString: "_")
        return result
    }
    private func parameterStringForDictionary(parameters:Dictionary<String,AnyObject>)->String{
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
                let exception = NSException(name: "InValidPara", reason: "GET and DELETE parameters must be provided as NSDictionary.", userInfo: [NSInvalidArgumentException:"GET and DELETE parameters must be provided as NSDictionary"])
                exception.raise()
                
            }
        }
        return arrParamters.concat("&")
    }
}

extension String{
    func encodedURLParameterString()->String{
        let result  = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as CFStringRef, nil, __CFStringMakeConstantString(":/=,!$&'()*+;[]@#?^%\"`<>{}\\|~ "), CFStringBuiltInEncodings.UTF8.rawValue)
        return result as String
    }
    
}
extension Array{
    func concat(symble:String)->String{
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

extension NSData{
    func getImageType()->String?{
        if self.length > 4{
            var buffer:UnsafeMutablePointer<Int> = UnsafeMutablePointer<Int>()
            self.getBytes(&buffer, length: 4)
            print(buffer)
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


public class HttpClientManager:NSObject {
    private var httpclient:HttpClient!
    private var url:String!
    private var method:httpMethod!
    private var params:Dictionary<String,AnyObject>?
    private var cacheTime:Int = 0
    private var cancelToken:String?
    private var queryPara:Dictionary<String,AnyObject>?
    private  var requestOptions:Dictionary<String,AnyObject>?
    private  var headerFields:Dictionary<String,AnyObject>?
    private var progress:((_ progress:Float)->())?
    private  var completion:((_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->())?
    public static func Get(url:String)->HttpClientManager{
        let h = HttpClientManager()
        h.url = url
        h.method = .Get
        return h
    }
    public static func Post(url:String)->HttpClientManager{
        let h = HttpClientManager()
        h.url = url
        h.method = .Post
        return h
    }
    
    public func addParams(params:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.params = params
        return self
    }
    
    public func cache(cacheTime:Int)->HttpClientManager{
        self.cacheTime = cacheTime
        return self
    }
    
    public func cancelToken(cancelToken:String?)->HttpClientManager{
        self.cancelToken = cancelToken
        return self
    }
    
    public func queryPara(queryPara:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.queryPara = queryPara
        return self
    }
    public func requestOptions(requestOptions:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.requestOptions = requestOptions
        return self
    }
    public func headerFields(headerFields:Dictionary<String,AnyObject>?)->HttpClientManager{
        self.headerFields = headerFields
        return self
    }
    public func progress(progress:((_ progress:Float)->())?)->HttpClientManager{
        self.progress = progress
        return self
    }
    public func completion(completion:((_ response:AnyObject?,_ urlResponse:HTTPURLResponse?,_ error:NSError?)->())?){
        self.completion = completion
        self.httpclient = HttpClient(address: url, method: method, parameters: params, cache: cacheTime, cancelToken: cancelToken, queryPara: queryPara, requestOptions: requestOptions, headerFields: headerFields, progress: progress, completion: completion)
        self.httpclient.requestPath = self.httpclient.operationRequest?.URL?.absoluteString
        HttpClient.operationQueue.addOperation(self.httpclient)
    }
}
 */

