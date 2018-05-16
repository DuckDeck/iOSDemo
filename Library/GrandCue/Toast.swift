//
//  Toast.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import WSProgressHUD
class Toast{
    static var isShowing = false
    
    static func showToast(msg:String) {
        WSProgressHUD.dismiss()
        isShowing = false
        GrandCue.toast(msg)
    }
    static func showToast(msg:String,originy:Float) {
        GrandCue.toast(msg, verticalScale: originy)
    }
    
    static func showLoading(txt:String = "加载中..."){
        WSProgressHUD.show(withStatus: txt, maskType: .clear)
        isShowing = true
    }
    
    //    func isShowing() -> Bool {
    //
    //    }
    
    static func dismissLoading() {
        WSProgressHUD.dismiss()
        isShowing = false
    }
}
