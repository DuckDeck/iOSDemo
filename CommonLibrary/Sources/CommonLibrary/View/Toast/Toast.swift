//
//  Toast.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import KRProgressHUD
public class Toast{
    public static var isShowing = false
    
    public static func showToast(msg:String) {
        KRProgressHUD.dismiss()
        isShowing = false
        GrandCue.toast(msg)
    }
    public static func showToast(msg:String,originy:Float) {
        GrandCue.toast(msg, verticalScale: originy)
    }
    
    public static func showLoading(txt:String = "加载中..."){
        KRProgressHUD.showMessage(txt)
        isShowing = true
    }
    
    //    func isShowing() -> Bool {
    //
    //    }
    
    public static func dismissLoading() {
        KRProgressHUD.dismiss()
        isShowing = false
    }
}
