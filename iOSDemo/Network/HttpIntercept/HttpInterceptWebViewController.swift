//
//  HttpInterceptWebViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/10/18.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import Foundation
import WebKit
import SwiftyJSON
class HttpInterceptWebViewController:BaseViewController{
    var webView:WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let handler = CustomURLSchemeHandler()
        config.setURLSchemeHandler(handler, forURLScheme: "http")
        config.setURLSchemeHandler(handler, forURLScheme: "https")
        
        
        let pre = WKPreferences()
        pre.minimumFontSize = 13
        pre.javaScriptEnabled = true
        config.preferences = pre
        let wkuser = WKUserContentController()
        config.userContentController = wkuser
        wkuser.add(self, name: "showMobile")

        
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        webView?.uiDelegate = self;
        webView?.navigationDelegate = self;

        let path = Bundle.main.path(forResource: "upload", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        
        _ =  webView?.load(request)

        
        let btn = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(reloadHTML))
        navigationItem.rightBarButtonItem = btn
    }
    
    @objc func reloadHTML(){
        let path = Bundle.main.path(forResource: "upload", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        
        _ =  webView?.load(request)

    }
}

extension HttpInterceptWebViewController:WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let js = JSON(message.body)
        let str = js["data"].stringValue
        let d = Data(base64Encoded: str)!
        
        HttpClient.post("http://lovelive.ink:9000/upload/header").addMultiParams(params: ["upload-key":d]).completion { data, error in
            if error != nil{
                print(error.debugDescription)
                return
            }
            let str = String(data: data!, encoding: .utf8)
            print(str)
        }
    }
    
    
}
