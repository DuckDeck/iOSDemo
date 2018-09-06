

//
//  ShadowDownloader.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
enum RangeInfoRequestType:Int{
    case RequestFromCache = 0,RequestFromNet
}

class ShadowDownloader:NSObject {
    var loadingRequest:AVAssetResourceLoadingRequest
    fileprivate var rangeInfoArray:[ShadowRangeInfo]
    fileprivate var urlSchema:String
    fileprivate var dataManager:ShadowDataManager
    fileprivate var currentRangeInfo:ShadowRangeInfo?
    fileprivate var urlSession:URLSession?
    fileprivate var dataTask:URLSessionDataTask?
    fileprivate var receivedDataLength = 0
    init?(loadingRequest:AVAssetResourceLoadingRequest,rangeInfoArray:[ShadowRangeInfo],urlSchema:String,dataManager:ShadowDataManager) {
        self.rangeInfoArray = rangeInfoArray
        self.loadingRequest = loadingRequest
        self.urlSchema = urlSchema
        self.dataManager = dataManager
        
    }
    
    func handleLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest,rangeArray:[ShadowRangeInfo])  {
        if rangeArray.count > 0{
            let rangeInfo = rangeArray.first!
            currentRangeInfo = rangeInfo
            receivedDataLength = 0
            if rangeInfo.requestType == .RequestFromCache{
                let cacheRange = rangeInfo.requestRange
                let cacheData = dataManager.readCacheDataIn(range: cacheRange)
                loadingRequest.dataRequest?.respond(with: cacheData)
                var tmp = rangeArray
                tmp.remove(at: 0)
                handleLoadingRequest(loadingRequest: loadingRequest, rangeArray: tmp)
            }
            else{
                //将私有协议开头的请求处理成真正可用的url
                let url = loadingRequest.request.url!
                guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else{
                    print("\(url) can not convert to urlComponents")
                    return
                }
                urlComponents.scheme = urlSchema
                if urlSession == nil{
                    urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
                }
                var request = URLRequest(url: urlComponents.url!)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                let requestRange = "bytes=\(rangeInfo.requestRange.location)-\(rangeInfo.requestRange.location + rangeInfo.requestRange.length - 1)"
                request.setValue(requestRange, forHTTPHeaderField: "Range")
                let task = urlSession!.dataTask(with: request)
                dataTask = task
                task.resume()
            }
        }
        else{
            cancel()
        }
    }
    
    func cancel()  {
        
    }
    
    func fillContentInfo(response:URLResponse)  {
        guard let contentInfoRequest = loadingRequest.contentInformationRequest else{
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        let byteRangeAccessSupported = (httpResponse.allHeaderFields["Accept-Ranges"] as! String) == "bytes"
        let contentLength = (httpResponse.allHeaderFields["Content-Range"] as! String).components(separatedBy: "/").last?.toInt() ?? 0
        dataManager.contentLength = contentLength
        guard let mimeType = httpResponse.mimeType else{
            return
        }
        guard let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() as String? else{
            return
        }
        contentInfoRequest.isByteRangeAccessSupported = byteRangeAccessSupported
        contentInfoRequest.contentLength = Int64(contentLength)
        contentInfoRequest.contentType = contentType
    }
    
    func handleReceiveData(data:Data)  {
        let cacheRange = NSRange(location: currentRangeInfo!.requestRange.location + receivedDataLength, length: data.count)
        dataManager.addCache(data: data, range: cacheRange)
        
    }
    
}

extension ShadowDownloader:URLSessionDataDelegate{
 
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
    
}

struct  ShadowRangeInfo {
    var requestType = RangeInfoRequestType.RequestFromCache
    var requestRange:NSRange
    init(requestType:RangeInfoRequestType,requestRange:NSRange) {
        self.requestType = requestType
        self.requestRange = requestRange
    }
}
