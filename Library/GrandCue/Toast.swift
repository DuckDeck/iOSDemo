//
//  Toast.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import KRProgressHUD
class Toast{
    
    
    
    static var isShowing = false
    
    static func showToast(msg:String) {
       
        DispatchQueue.main.async {
            KRProgressHUD.dismiss()
            self.isShowing = false
            GrandCue.toast(msg)
        }
        
    }
    static func showToast(msg:String,originy:Float) {
        GrandCue.toast(msg, verticalScale: originy)
    }
    
    static func showLoading(txt:String = "加载中..."){
        KRProgressHUD.set(style: .custom(background: UIColor.blue, text: UIColor.red, icon: UIColor.yellow)).showMessage(txt)
        isShowing = true
    }
    
    //    func isShowing() -> Bool {
    //
    //    }
    
    static func dismissLoading() {
        KRProgressHUD.dismiss()
        isShowing = false
    }
}
