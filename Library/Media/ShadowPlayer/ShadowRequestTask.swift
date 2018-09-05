//
//  ShadowRequestTask.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

@objc protocol ShadowRequestTaskDeledate {
    func requestTaskDidUpdateCache();
    @objc optional func requestTaskDidReceiveResponse();
    @objc optional func requestTaskDidFinishLoadingWithCache(isCache:Bool);
    @objc optional func requestTaskDidFailWithError(error:Error)
}

class ShadowRequestTask: NSObject {
    weak var delegate:ShadowRequestTaskDeledate?
    var requestUrl:URL!
    var requestOffset = 0
    var fileLength = 0
    var cacheLength = 0
    var isCache = false
    var isCancel = false
    private var session:URLSession?
    private var task:URLSessionTask?
    var path:String?
    fileprivate override init() {
        
    }
    init(url:URL) {
        self.requestUrl = url
        var fileName = url.pathComponents.last ?? "tmp"
        var extensionname = "mp4"
        if fileName.contains("."){
            extensionname = fileName.components(separatedBy: ".").last!
            fileName = fileName.components(separatedBy: ".").first!
        }
        path =  ShadowFileHandle.createTempFile(fileName: fileName, extensionName: extensionname)
    }
    
    func start()  {
        
        var request = URLRequest(url: requestUrl.changeSchema(targetSchema: "http")!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        if requestOffset > 0{
            request.addValue("bytes=\(requestOffset)-\(fileLength-1)", forHTTPHeaderField: "Range")
        }
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        task = session!.dataTask(with: request)
        task?.resume()
    }
    
    func setCancel(cancel:Bool)  {
        isCancel = cancel
        task?.cancel()
        session?.invalidateAndCancel()
    }
    
    
}

extension ShadowRequestTask:URLSessionDataDelegate{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if isCancel{
            return
        }
        completionHandler(.allow)
        let httpResponse = response as! HTTPURLResponse
        let contentRange = httpResponse.allHeaderFields["Content-Range"] as? String
        let length = contentRange?.components(separatedBy: "/").last ?? "0"
        fileLength = Int(length)! > 0 ? Int(length)! : Int(response.expectedContentLength)
        delegate?.requestTaskDidReceiveResponse?()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if isCancel{
            return
        }
        ShadowFileHandle.writeTempFile(data: data, path: path!)
        cacheLength += data.count
        delegate?.requestTaskDidUpdateCache()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if isCancel{
            
        }
        else{
            if error != nil{
                delegate?.requestTaskDidFailWithError?(error: error!)
            }
            else{
                if isCancel{
                    _ = ShadowFileHandle.cacheTempFileWithFile(fileName: requestUrl.path.components(separatedBy: "/").last!, tmpPath: path!)
                }
                delegate?.requestTaskDidFinishLoadingWithCache?(isCache: isCancel)
            }
        }
    }
}
