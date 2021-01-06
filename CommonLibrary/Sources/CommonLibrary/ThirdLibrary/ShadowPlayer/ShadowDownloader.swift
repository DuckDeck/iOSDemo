

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
    var loadingRequest:AVAssetResourceLoadingRequest!
    fileprivate var rangeInfoArray:[ShadowRangeInfo]!
    fileprivate var urlSchema:String!
    fileprivate var dataManager:ShadowDataManager!
    fileprivate var currentRangeInfo:ShadowRangeInfo?
    fileprivate var urlSession:URLSession?
    fileprivate var dataTask:URLSessionDataTask?
    fileprivate var receivedDataLength = 0

    init?(loadingRequest:AVAssetResourceLoadingRequest,rangeInfoArray:[ShadowRangeInfo],urlSchema:String,dataManager:ShadowDataManager) {
        super.init()
        self.rangeInfoArray = rangeInfoArray
        self.loadingRequest = loadingRequest
        self.urlSchema = urlSchema
        self.dataManager = dataManager
        self.handleLoadingRequest(loadingRequest: loadingRequest)
    }
    
    func handleLoadingRequest( loadingRequest:AVAssetResourceLoadingRequest)  {
        if rangeInfoArray.count > 0{
            let rangeInfo = rangeInfoArray.first!
            currentRangeInfo = rangeInfo
            receivedDataLength = 0
            rangeInfoArray.remove(at: 0)
            if rangeInfo.requestType == .RequestFromCache{
                let cacheRange = rangeInfo.requestRange
                let cacheData = dataManager.readCacheDataIn(range: cacheRange)
                loadingRequest.dataRequest?.respond(with: cacheData)
                handleLoadingRequest(loadingRequest: loadingRequest)
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
                Log(message: "设置请求范围\(requestRange)")
                request.setValue(requestRange, forHTTPHeaderField: "Range")
                let task = urlSession!.dataTask(with: request)
                dataTask = task
                task.resume()
            }
        }
        else{//如果当前rangeModelArray.count <= 0,则说明当前loadingRequest已经处理完成，可做finish处理
            cancel()
        }
    }
    
    func cancel()  {
        if !loadingRequest.isFinished{
            loadingRequest.finishLoading()
        }
        dataTask?.cancel()//保证请求被立即取消，不然服务器还会继续返回一段数据，这段数据不会被利用到，浪费流量
        urlSession?.invalidateAndCancel()
    }
    
    func fillContentInfo(response:URLResponse)  {
        guard let contentInfoRequest = loadingRequest.contentInformationRequest else{
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
         //服务器端是否支持分段传输
        var  byteRangeAccessSupported = false
        //返回的是这样的
        //- value : "Content-Range"
        //- value : bytes 0-1/4425575
        //ISSUE我用URLSession里面设置了Range，所以返回的allHeaderFields里面没有Accept-Ranges这个字段，取而代之的是Content-Range，里面有文件长度和当前请求的长度
        //所以判断里面有没有bytes所以得出支不支持分段传输
        if httpResponse.allHeaderFields.keys.contains("Accept-Ranges") && httpResponse.allHeaderFields["Accept-Ranges"] is String{
            let acceprange = httpResponse.allHeaderFields["Accept-Ranges"] as! String
            byteRangeAccessSupported = acceprange == "bytes"
        }
         //获取返回文件的长度，同时判断支不支持分段传输
        let contentLengthStr = httpResponse.allHeaderFields["Content-Range"] as? String ?? ""
        if contentLengthStr.contains("bytes"){
            byteRangeAccessSupported = true
        }
        let contentLength = contentLengthStr.components(separatedBy: "/").last?.toInt() ?? 0
        dataManager.contentLength = contentLength
        guard let mimeType = httpResponse.mimeType else{
            return
        }
         //获取返回文件的类型
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
        ShadowRangeManager.shareInstance?.addCacheRange(newRange: cacheRange)
        receivedDataLength += data.count
        loadingRequest.dataRequest?.respond(with: data)
    }
    
}

extension ShadowDownloader:URLSessionDataDelegate{
 
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //服务器首次响应请求时，返回的响应头，长度为2字节，包含该次网络请求返回的音频文件的内容信息，例如文件长度，类型等
        print("获取数据开始")
        fillContentInfo(response: response)
        completionHandler(.allow)
    }
    
    //下载中，服务器返回数据时，调用该方法，可能会调用多次
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        handleReceiveData(data: data)
         print("获取到数据，大小是\(data.count)")
        //这里还可以设置进度
    }
    
    //请求完成调用该方法   请求失败则error有值
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("获取数据结结束")
        if error != nil{
            print(error!.localizedDescription)
        }
        else{
             handleLoadingRequest(loadingRequest: loadingRequest)
        }
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
