//
//  PointLockViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/27.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SwiftUI
import CommonLibrary
class PointLockViewController: UIViewController {

    let imgUp = UIImageView()
    let vLock = LockView()
    
    var password = "012"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        vLock.delegate = self
        vLock.backgroundColor = UIColor.lightGray
        view.addSubview(vLock)
        vLock.snp.makeConstraints { (m) in
            m.width.height.equalTo(300)
            m.centerX.equalTo(view)
            m.bottom.equalTo(-50)
        }
        
        view.addSubview(imgUp)
        imgUp.snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.width.height.equalTo(80)
            m.top.equalTo(100)
        }
        
        // Do any additional setup after loading the view.
    }

}

extension PointLockViewController:LockViewDelegate{
    func outputResult(lockView: LockView, image: UIImage, result: Bool) {
        imgUp.image = image
        if result {
            Toast.showToast(msg: "密码正确")
        }
        else{
            Toast.showToast(msg: "密码错误")
        }
    }
    
    func comparePassword(lockView: LockView, password: String) -> Bool {
        if password == self.password{
            return true
        }
        return false
    }
}
struct PinLockDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = PointLockViewController
    
    func makeUIViewController(context: Context) -> PointLockViewController {
        return PointLockViewController()
    }
}

