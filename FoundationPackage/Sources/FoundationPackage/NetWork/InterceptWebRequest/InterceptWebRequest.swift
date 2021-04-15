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
class WebViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let handler = URLSchemeHandler()
        config.setURLSchemeHandler(handler, forURLScheme: "http")
        config.setURLSchemeHandler(handler, forURLScheme: "https")
        //    NSMutableDictionary *handlers = [configuration valueForKey:@"_urlSchemeHandlers"];
        //    handlers[@"https"] = handler;//修改handler,将HTTP和HTTPS也一起拦截
        //    handlers[@"http"] = handler;
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        webView.load(URLRequest(url: URL(string: "https://www.163.com")!))
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
