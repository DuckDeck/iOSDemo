//
//  LockView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/27.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

protocol LockViewDelegate:class {
    func comparePassword(lockView:LockView,password:String) -> Bool
    func drawImageUp(lockView:LockView,image:UIImage)
}

class LockView: UIView {
    weak var delegate:LockViewDelegate?
    var arrBtn:[UIButton]={
       var arr = [UIButton]()
        let btn = UIButton()
        
        return arr
    }()
    var arrSelectedBtn = [UIButton]()
    var currentPoint = CGPoint()
    var result = false
    var con:PointLockViewController?
    var currentPassword = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    
}
