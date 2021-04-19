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
//        let handler = URLSchemeHandler()
//        config.setURLSchemeHandler(handler, forURLScheme: "http")
//        config.setURLSchemeHandler(handler, forURLScheme: "https")
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
        let type = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
//        清除WKWebView的缓存
//           在磁盘缓存上。
//           WKWebsiteDataTypeDiskCache,
//           
//           html离线Web应用程序缓存。
//           WKWebsiteDataTypeOfflineWebApplicationCache,
//           
//           内存缓存。
//           WKWebsiteDataTypeMemoryCache,
//           
//           本地存储。
//           WKWebsiteDataTypeLocalStorage,
//           
//           Cookies
//           WKWebsiteDataTypeCookies,
//           
//           会话存储
//           WKWebsiteDataTypeSessionStorage,
//           
//           IndexedDB数据库。
//           WKWebsiteDataTypeIndexedDBDatabases,
//           
//           查询数据库。
//           WKWebsiteDataTypeWebSQLDatabases
        WKWebsiteDataStore.default().removeData(ofTypes: type, modifiedSince: date) {
            print("移除所有cache")
        }
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
