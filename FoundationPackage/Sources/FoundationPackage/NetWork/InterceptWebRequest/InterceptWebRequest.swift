//
//  File.swift
//  
//
//  Created by chen liang on 2021/4/15.
//

import UIKit
import WebKit
import SwiftUI
import SnapKit
import CommonLibrary
class WebViewController: BaseViewController {
    var webView:TestWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let handler = URLSchemeHandler()
        config.setURLSchemeHandler(handler, forURLScheme: "http")
        config.setURLSchemeHandler(handler, forURLScheme: "https")
        webView = TestWebView(frame: CGRect.zero, configuration: config)
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
       
        webView.load(URLRequest(url: URL(string: "https://www.163.com")!))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
        }
//       清除WKWebView的缓存
//       WKWebsiteDataTypeDiskCache, 在磁盘缓存上。
//       WKWebsiteDataTypeOfflineWebApplicationCache, html离线Web应用程序缓存。
//       WKWebsiteDataTypeMemoryCache, 内存缓存。
//       WKWebsiteDataTypeLocalStorage, 本地存储。
//       WKWebsiteDataTypeCookies, Cookies
//       WKWebsiteDataTypeSessionStorage,会话存储
//       WKWebsiteDataTypeIndexedDBDatabases,IndexedDB数据库。
//       WKWebsiteDataTypeWebSQLDatabases查询数据库。
    }
    
    
}
struct InterceptDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = WebViewController
    
    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController()
    }
}

class TestWebView: WKWebView {
    deinit {
        Log(message: "\(type(of:self))已经被回收了")
    }
}
