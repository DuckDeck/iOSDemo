//
//  NYCustomURLSchemeHandler.swift
//  NYOpenH5Demo
//
//  Created by 陈良静 on 2019/7/30.
//  Copyright © 2019 陈良静. All rights reserved.
//

import Foundation
import WebKit
import Alamofire
import Kingfisher
@available(iOS 11.0, *)
class CustomURLSchemeHandler: NSObject {
    // MARK: ---------------------------- lazy var ------------------------
    /// http 管理
//    lazy var httpSessionManager: AFHTTPSessionManager = {
//        let manager = AFHTTPSessionManager()
//        manager.requestSerializer = AFHTTPRequestSerializer()
//        manager.responseSerializer = AFHTTPResponseSerializer()
//        manager.responseSerializer.acceptableContentTypes = Set(arrayLiteral: "text/html", "application/json", "text/json", "text/javascript", "text/plain", "application/javascript", "text/css", "image/svg+xml", "application/font-woff2", "font/woff2", "application/octet-stream")
//
//        return manager
//    }()
    
    // MARK: ---------------------------- var ------------------------
    /// 防止 urlSchemeTask 实例释放了，又给他发消息导致崩溃
    var holdUrlSchemeTasks = [AnyHashable: Bool]()
    /// 资源缓存
    var resourceCache = H5ResourceCache()
    
    // MARK: ---------------------------- life Cycle ------------------------
    deinit {
        print("\(String(describing: self)) 销毁了")
    }
}

// MARK: - privateFunc
extension CustomURLSchemeHandler {
    /// 生成缓存key
    private func creatCacheKey(urlSchemeTask: WKURLSchemeTask) -> String? {
        guard let fileName = urlSchemeTask.request.url?.absoluteString.replacingOccurrences(of: "customscheme://", with: "") else { return nil }
        guard let extensionName = urlSchemeTask.request.url?.pathExtension else { return nil }
        var result = fileName.md5
        if extensionName.count == 0 {
            result += ".html"
        } else {
            result += ".\(extensionName)"
        }
        
        return result
    }
}

// MARK: - resource load
extension CustomURLSchemeHandler {
    /// 加载本地资源
    private func loadLocalFile(fileName: String?, urlSchemeTask: WKURLSchemeTask) {
        if fileName == nil && fileName?.count == 0 { return }
        
        // 先从本地中文件中加载
        if resourceCache.contain(forKey: fileName!)  {
            // 缓存命中
            print("缓存命中!!!!")
            guard let data = resourceCache.data(forKey: fileName!) else { return }
            let mimeType = String.mimeType(pathExtension: self.creatCacheKey(urlSchemeTask: urlSchemeTask))
            resendRequset(urlSchemeTask: urlSchemeTask, mineType: mimeType, requestData: data)
        } else {
            print("没有缓存!!!!")
            requestRomote(fileName: fileName!, urlSchemeTask: urlSchemeTask)
        }
    }
    
    /// 加载远程资源
    func requestRomote(fileName: String, urlSchemeTask: WKURLSchemeTask) {
        // 没有缓存,替换url，重新加载
        guard let urlString = urlSchemeTask.request.url?.absoluteString.replacingOccurrences(of: "customscheme", with: "https") else { return }
        print("开始重新发送网络请求")
        // 替换成https请求
        
        AF.request(urlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).response { res in
            if let isValid = self.holdUrlSchemeTasks[urlSchemeTask.description] {
                if !isValid {
                    return
                }
            }
      
            if res.error != nil{
                urlSchemeTask.didFailWithError(res.error!)
                return
            }
            urlSchemeTask.didReceive(res.response!)
            urlSchemeTask.didReceive(res.data!)
            urlSchemeTask.didFinish()
            guard let accept = urlSchemeTask.request.allHTTPHeaderFields?["Accept"] else { return }
            if !(accept.count > "image".count && accept.contains("image")) {
                // 图片不下载
                self.resourceCache.setData(data: res.data!, forKey: fileName)
            }
        }
        
       
    }
    
    /// 重新发送请求
    ///
    /// - Parameters:
    ///   - urlSchemeTask: <#urlSchemeTask description#>
    ///   - mineType: <#mineType description#>
    ///   - requestData: <#requestData description#>
    func resendRequset(urlSchemeTask: WKURLSchemeTask, mineType: String?, requestData: Data) {
        guard let url = urlSchemeTask.request.url else { return }
        if let isValid = holdUrlSchemeTasks[urlSchemeTask.description] {
            if !isValid {
                return
            }
        }
        
        let mineT = mineType ?? "text/html"
        let response = URLResponse(url: url, mimeType: mineT, expectedContentLength: requestData.count, textEncodingName: "utf-8")
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(requestData)
        urlSchemeTask.didFinish()
    }
}

// MARK: - WKURLSchemeHandler
extension CustomURLSchemeHandler: WKURLSchemeHandler {
    // 自定义拦截请求开始
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        holdUrlSchemeTasks[urlSchemeTask.description] = true
        
        let headers = urlSchemeTask.request.allHTTPHeaderFields
        guard let accept = headers?["Accept"] else { return }
        guard let requestUrlString = urlSchemeTask.request.url?.absoluteString else { return }
        
        if accept.count >= "text".count && accept.contains("text/html") {
            // html 拦截
            print("html = \(String(describing: requestUrlString))")
            loadLocalFile(fileName: creatCacheKey(urlSchemeTask: urlSchemeTask), urlSchemeTask: urlSchemeTask)
        } else if (requestUrlString.isJSOrCSSFile()) {
            // js || css 文件
            print("js || css = \(String(describing: requestUrlString))")
            loadLocalFile(fileName: creatCacheKey(urlSchemeTask: urlSchemeTask), urlSchemeTask: urlSchemeTask)
            
        } else if accept.count >= "image".count && accept.contains("image") {
            // 图片
            print("image = \(String(describing: requestUrlString))")
            guard let originUrlString = urlSchemeTask.request.url?.absoluteString.replacingOccurrences(of: "customscheme", with: "https") else { return }
            
           let _ = KingfisherManager.shared.retrieveImage(with: .network(ImageResource(downloadURL: URL(string: originUrlString)!, cacheKey: nil)), options: nil, progressBlock: nil, downloadTaskUpdated: nil) { result in
                if let img =  try? result.get().image{
                    guard let data = img.jpegData(compressionQuality: 1) else {return}
                    self.resendRequset(urlSchemeTask: urlSchemeTask, mineType: "image/jpeg", requestData: data)
                } else {
                    self.loadLocalFile(fileName: self.creatCacheKey(urlSchemeTask: urlSchemeTask), urlSchemeTask: urlSchemeTask)
                }
            }
            

            
        } else {
            // other resources
            print("other resources = \(String(describing: requestUrlString))")
            guard let cacheKey = self.creatCacheKey(urlSchemeTask: urlSchemeTask) else { return }
            requestRomote(fileName: cacheKey, urlSchemeTask: urlSchemeTask)
        }
    }
    
    /// 自定义请求结束时调用
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        holdUrlSchemeTasks[urlSchemeTask.description] = false
    }
}
