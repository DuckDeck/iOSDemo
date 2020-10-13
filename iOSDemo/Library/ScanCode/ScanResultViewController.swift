//
//  ScanResultViewController.swift
//  iOSDemo
//
//  Created by shadowedge on 2020/10/13.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit
import WebKit
class ScanResultViewController: UIViewController {
    var res = ""
//    var webView = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "扫码结果"
        let lblRes = UILabel(frame: CGRect(x: 10, y: 100, width: 200, height: 30))
        lblRes.text = res
        view.addSubview(lblRes)
        
    }
    

}
