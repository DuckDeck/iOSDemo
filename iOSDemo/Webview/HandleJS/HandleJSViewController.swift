//
//  HandleJSViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/7/5.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import WebKit
//这里用js打开相册和摄像头
class HandleJSViewController: BaseViewController {
    var web:WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnRunjs = UIBarButtonItem(title: "RunJs", style: .plain, target: self, action: #selector(runJS))
        navigationItem.rightBarButtonItem = btnRunjs
        let config = WKWebViewConfiguration()
        let hander = ScriptMessageHandler()
        hander.delegate = self
        let param = [1,2,3,4,5]
        let script = WKUserScript(source: "function callJs(){passAnArray(\(param));}", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.add(hander, name: "mobile")
        config.userContentController.addUserScript(script)
        let htmlUrl = Bundle.main.url(forResource: "demo", withExtension: "html")
        let str = try! String.init(contentsOf: htmlUrl!)
        web = WKWebView(frame: CGRect(), configuration: config)
        web.uiDelegate = self
        web.navigationDelegate = self
        web.addTo(view: view).snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        web.loadHTMLString(str, baseURL: nil)
        // Do any additional setup after loading the view.
    }

    @objc func runJS() {
        let js = "callJs()"
        web.evaluate(script: js) { (res, err) in
            print(res)
        }
    }
    
    deinit {
        web.configuration.userContentController.removeScriptMessageHandler(forName: "mobile")
    }
}

extension HandleJSViewController:WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "mobile" else {
            print("不是绑定的响应对象")
            return
        }
        let dict = message.body as! [String:Any]
        let title = dict["title"] as? String
        let message = dict["message"] as? String
        //这些信息要商量好
        UIAlertController.title(title: title ?? "", message: message ?? "").action(title: "OK", handle: nil).show()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        UIAlertController.title(title: message, message: nil).action(title: "OK", handle: nil).show()
        completionHandler()
    }
    
    
}

class ScriptMessageHandler: NSObject {
    weak var delegate:WKScriptMessageHandler?
}

extension ScriptMessageHandler:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let target = delegate{
            target.userContentController(userContentController, didReceive: message)
        }
    }
}


extension WKWebView {
    func evaluate(script: String, completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        var finished = false
        
        evaluateJavaScript(script) { (result, error) in
            if error == nil {
                if result != nil {
                    completion(result, nil)
                }
            } else {
                completion(nil, error)
            }
            finished = true
        }
        
        while !finished {
            RunLoop.current.run(mode: .default, before: Date.distantFuture)
        }
    }
}
