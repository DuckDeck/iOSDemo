//
//  WKWebView+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/7/14.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import WebKit
extension WKWebView{
    @objc static func gghandlesURLScheme(_ urlScheme: String) -> Bool{
        if urlScheme == "http" || urlScheme == "https" {
            return false
        }
        else{
            return gghandlesURLScheme(urlScheme)
        }
    }
    
    @objc func ggLoad(_ request: URLRequest) -> WKNavigation?{
        print("--------------hook Load 方法成功--------------")
        return ggLoad(request)
    }
}
