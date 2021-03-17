//
//  JSViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit
import SwiftUI
class JSViewController: UIViewController {
    var webView :WKWebView?
    var context = JSContext()
    var jsContext: JSContext?
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        let pre = WKPreferences()
        pre.minimumFontSize = 13
        pre.javaScriptEnabled = true
        config.preferences = pre
        let wkuser = WKUserContentController()
        config.userContentController = wkuser
        wkuser.add(self, name: "showMobile")
        webView = WKWebView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64), configuration: config)
        webView?.uiDelegate = self;
        webView?.navigationDelegate = self;
        view.addSubview(webView!)
        
        //在swift package manager 里加资源有问题，我按照里抽的方法死活不能把资源copy进bundle里面，不知道为什么
//        print(Bundle.main.bundlePath)
//        let path = Bundle.main.bundlePath
//        let dict = FileManager.default.subpaths(atPath: path)
//        print(dict)
        //获取不到的
        //目前把这个放在外面，专门用一个地方来放资源
        let path = Bundle.main.path(forResource: "question", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)

        _ =  webView?.load(request)
        
        
//        print("view.safeAreaLayoutGuide = \(view.safeAreaLayoutGuide)")
//        print("\n")
//        print("view.safeAreaInsets = \(view.safeAreaInsets)")
//        let area = UIView(frame: view.safeAreaLayoutGuide.layoutFrame)
//        area.backgroundColor = UIColor.red
//              view.addSubview(area)


    }



}

extension JSViewController:WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate{
   
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "好的", style: UIAlertAction.Style.cancel) { (_) in
            completionHandler()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //confirm弹框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (_) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { (_) in
            completionHandler(false)
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //TextInput弹框
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (_) in}
        let action = UIAlertAction(title: "确定", style: UIAlertAction.Style.default) { (_) in
            completionHandler(alert.textFields?.last?.text)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
         print(message.body)
    }
    
    func toast(str:String)  {
        print("JS invoke toast func")
    }
    
}


struct JSControlDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = JSViewController
    
    func makeUIViewController(context: Context) -> JSViewController {
        return JSViewController()
    }
}
