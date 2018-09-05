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
    
    func addLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest){
        requestList.append(loadingRequest)
        objc_sync_enter(self)
        if requestTask != nil{
            if Int(loadingRequest.dataRequest!.requestedOffset) >= requestTask!.requestOffset && Int(loadingRequest.dataRequest!.requestedOffset) <= requestTask!.requestOffset + requestTask!.cacheLength{
                 //数据已经缓存，则直接完成
                processRequestList()
            }
            else{
                if isSeekRequired{
                    newTaskWithLoadingRequest(loadingRequest: loadingRequest, isCache: false)
                }
            }
        }
        else{
            newTaskWithLoadingRequest(loadingRequest: loadingRequest, isCache: true)
        }
        objc_sync_exit(self)
    }
    
    func newTaskWithLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest,isCache:Bool)  {
        var fileLength = 0
        if requestTask != nil {
            fileLength = requestTask!.fileLength
            requestTask?.isCancel = true
        }
        requestTask = ShadowRequestTask(url: loadingRequest.request.url!)
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
        //这里存在疑问
        requestList.removeWith(condition: {item  in
           return item.request.url == loadingRequest.request.url
        })
    }
    
    func processRequestList() {
        var indexs = [Int]()
        for i in 0..<requestList.count{
            if finishLoadingWithLoadingRequest(loadingRequest: requestList[i]){
                indexs.append(i)
            }
        }
        requestList.removeAtIndexs(indexs: indexs)
        
    }
    
    func finishLoadingWithLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest) -> Bool {
          //填充信息
        loadingRequest.contentInformationRequest?.contentType = "public.mpeg-4"
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentLength = Int64(requestTask!.fileLength)
        let cacheLength = requestTask!.cacheLength
        var requestedOffset:Int = Int(loadingRequest.dataRequest!.requestedOffset)
        if loadingRequest.dataRequest!.currentOffset != 0{
            requestedOffset = Int(loadingRequest.dataRequest!.currentOffset)
        }
        let canReadLength = cacheLength - (Int(requestedOffset) - requestTask!.requestOffset)
        let respondLength = min(canReadLength, loadingRequest.dataRequest!.requestedLength)
        let data =  ShadowFileHandle.readTempFileDataWith(offset: UInt(Int(requestedOffset) - requestTask!.requestOffset), length: respondLength, path: requestTask!.path!)!
        loadingRequest.dataRequest?.respond(with:data)
        let nowendOffset = requestedOffset + canReadLength
        let reqEndOffset = Int(loadingRequest.dataRequest!.requestedOffset) + loadingRequest.dataRequest!.requestedLength
        if nowendOffset >= reqEndOffset{
            loadingRequest.finishLoading()
            return true
        }
        return false
    }
}

extension ShadowResourceLoader:ShadowRequestTaskDeledate{
    func requestTaskDidUpdateCache() {
        processRequestList()
        let process = Float(requestTask!.cacheLength) / Float(requestTask!.fileLength - requestTask!.requestOffset)
        delegate?.loader(loader: self, progress: process)
    }
    
    
    
    func requestTaskDidFinishLoadingWithCache(isCache: Bool) {
        isCacheFinished = isCache
    }
    
    func requestTaskDidFailWithError(error: Error) {
        
    }
    
}

extension ShadowResourceLoader:AVAssetResourceLoaderDelegate{
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("CancelLoadingRequest  < requestedOffset = \(loadingRequest.dataRequest!.requestedOffset), currentOffset = \(loadingRequest.dataRequest!.currentOffset), requestedLength = \(loadingRequest.dataRequest!.requestedLength) >")
        removeLoadingRequest(loadingRequest: loadingRequest)
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("CancelLoadingRequest  < requestedOffset = \(loadingRequest.dataRequest!.requestedOffset), currentOffset = \(loadingRequest.dataRequest!.currentOffset), requestedLength = \(loadingRequest.dataRequest!.requestedLength) >")
        addLoadingRequest(loadingRequest: loadingRequest)
        return true
    }
}
