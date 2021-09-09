//
//  CaptureImg.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/8/12.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import Foundation
import WebKit
class CaptureImgViewComtroller: UIViewController {
    var web : WKWebView?
    override func viewDidLoad() {
        let config = WKWebViewConfiguration()
        let hander = ScriptMessageHandler()
        config.userContentController.add(hander, name: "mobile")
        web = WKWebView(frame: CGRect(), configuration: config)
        web?.addTo(view: view).snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        
        web?.load(URLRequest(url: URL(string: "https://qr.1688.com/share.html?secret=BJSAqRAj")!))
        
        let navBtn = UIBarButtonItem(title: "抓图", style: .plain, target: self, action: #selector(capture))
        navigationItem.rightBarButtonItem = navBtn
    }
    
    @objc func capture() {
        
        web?.evaluate(script: "document.documentElement.outerHTML.toString()", completion: { html, err in
            print(html)
            if let htmlStr = html as? NSString{
                let ex = try! NSRegularExpression(pattern: "^(https|http)://[^\\s]*(.mp4)$", options: [.dotMatchesLineSeparators,.caseInsensitive])
                let res =  ex.matches(in: htmlStr as String, options: .reportCompletion, range: NSRange(location: 0, length: htmlStr.length))
                for item in res.enumerated(){
                    let rag = item.element.range
                    let s = htmlStr.substring(with: rag)
                    print(s)
                }
            }
        })
        
//        HttpClient.get(web!.url!.absoluteString).completion { data, err in
//            let str = String(data: data!, encoding: .utf8)
//            let ex = try! NSRegularExpression(pattern: "^(https|http)://[^\\s]*(.mp4)$", options: [.dotMatchesLineSeparators,.caseInsensitive])
//            let res =  ex.matches(in: str!, options: .reportCompletion, range: NSRange(location: 0, length: str!.count))
//            for item in res.enumerated(){
//                let rag = item.element.range
//                let s = str!.substring(from: rag.location, length: rag.length)
//                print(s)
//            }
//        }
    }
}
