//
//  ShadowResourceLoader.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
@objc protocol ShadowResourceLoaderDelegate{
    func loader(loader:ShadowResourceLoader,progress:Float);
    @objc optional func loader(loader:ShadowResourceLoader,error:Error);
    
}
class ShadowResourceLoader: NSObject {
    weak var delegate:ShadowResourceLoaderDelegate?
    var isSeekRequired = false
    var isCacheFinished = false
    var requestList = [AVAssetResourceLoadingRequest]()
    var requestTask:ShadowRequestTask?
    
    
    
    
    func stopLoading() {
        requestTask?.isCancel = true
    }
    
    func newTaskWithLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest,isCache:Bool)  {
        var fileLength = 0
        if requestTask != nil {
            fileLength = requestTask!.fileLength
            requestTask?.isCancel = true
        }
        requestTask = ShadowRequestTask()
        requestTask?.requestUrl = loadingRequest.request.url
        requestTask?.requestOffset = Int(loadingRequest.dataRequest!.requestedOffset)
        requestTask?.isCache = isCache
        if fileLength > 0{
            requestTask?.fileLength = fileLength
        }
        requestTask?.delegate = self
        requestTask?.start()
        isSeekRequired = false
    }
    
    func removeLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest) {
        requestList.removeWith(condition: {item  in
           return item.request.url == loadingRequest.request.url
        })
    }
    
    func processRequestList() {
        for request in requestList{
            
        }
    }
    
    func finishLoadingWithLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest) -> Bool {
          //填充信息
        loadingRequest.contentInformationRequest?.contentType = "video/mp4"
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(requestTask!.fileLength)
        var cacheLength = requestTask!.cacheLength
        var requestedOffset = loadingRequest.dataRequest!.requestedOffset
        if loadingRequest.dataRequest!.currentOffset != 0{
            requestedOffset = loadingRequest.dataRequest!.currentOffset
        }
        //let canReadLength = cacheLength - (requestedOffset - requestTask!.requestOffset)
        
        return true
    }
}

extension ShadowResourceLoader:ShadowRequestTaskDeledate{
    func requestTaskDidUpdateCache() {
        
    }
    
    
}
