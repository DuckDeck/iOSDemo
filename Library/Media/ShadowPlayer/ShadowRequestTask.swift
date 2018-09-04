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
    var requestUrl:URL?
    var requestOffset = 0
    var fileLength = 0
    var cacheLength = 0
    var isCache = false
    var isCancel = false
    private var session:URLSession?
    private var task:URLSessionTask?
    var path:String?
    override init() {
       path =  ShadowFileHandle.createTempFile(fileName: "temp1", extensionName: "mp4")
    }
    
    func start()  {
        
        var request = URLRequest(url: requestUrl!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
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
        
    }
}
