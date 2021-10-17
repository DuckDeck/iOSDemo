//
//  CacheWebViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/10/16.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import Foundation
import WebKit
import SnapKit

class CacheWebViewController: UIViewController {
    
    var urlString: String
    var timer: DispatchSourceTimer?
    var lastTime: Double?
    
    lazy var webview: WKWebView = {
        let wkwebView = WebViewReusePool.shared.getReusedWebView(ForHolder: self)!
        wkwebView.navigationDelegate = self
        wkwebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        return wkwebView
    }()
    
    lazy var progressLine: UIProgressView = {
        let line = UIProgressView(frame: CGRect.zero)
        line.backgroundColor = UIColor.white
        line.progressTintColor = UIColor.red
        line.isHidden = true
        return line
    }()
    
    lazy var loadTimeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.red
        label.backgroundColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    init(urlString: String) {
        self.urlString = urlString
        
        if self.urlString.hasPrefix("https") {
            self.urlString = self.urlString.replacingOccurrences(of: "https", with: "customscheme")
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.frame = view.bounds
        view.addSubview(webview)
        progressLine.frame = CGRect(x: 0, y: 88, width: view.bounds.width, height: 1)
        view.addSubview(progressLine)
        view.bringSubviewToFront(progressLine)
        
        view.addSubview(loadTimeLabel)
        loadTimeLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 100, y: 100, width: 100, height: 50)
        view.bringSubviewToFront(loadTimeLabel)
        
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webview.load(request)
        
        
        // 开启定时器
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer!.schedule(deadline: .now(), repeating: DispatchTimeInterval.microseconds(1))
        lastTime = CFAbsoluteTimeGetCurrent()
        self.loadTimeLabel.text = String(format: "%.3f", lastTime!)
        timer!.setEventHandler {
            let time = CFAbsoluteTimeGetCurrent() - self.lastTime!
            self.loadTimeLabel.text = String(format: "%.3f秒", time)
        }
        timer?.activate()
    }
    
    deinit {
       webview.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        WebViewReusePool.shared.recycleReusedWebView(webview as? ReuseWebView)
        print("webVC 销毁了!!!")
    }
    
    // 白屏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if webview.title == nil {
            webview.reload()
        }
    }
    
    // 观察者
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let value = change?[NSKeyValueChangeKey.newKey] as! NSNumber
        progressLine.progress = value.floatValue
    }
    
    
}

extension CacheWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressLine.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title", completionHandler: { [weak self] (x, error) in
            print(x as Any)
            print(error as Any)
            self?.title = (x as! String)
        })
        
        progressLine.isHidden = true
        timer?.cancel()
        timer = nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    // 白屏
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}
