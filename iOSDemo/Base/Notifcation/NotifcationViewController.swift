//
//  NotifcationViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/8/26.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit

class NotifcationViewController: UIViewController {

    let btnAddNotif = UIButton().title(title: "加通知").bgColor(color: UIColor.red)
    let btnAddAsyncNotif = UIButton().title(title: "加异步通知").bgColor(color: UIColor.green)

    let btnSendNotif =  UIButton().title(title: "发通知").bgColor(color: UIColor.yellow)
    let btnSendAsyncNotif =  UIButton().title(title: "非主线程通知").bgColor(color: UIColor.yellow)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(btnAddNotif)
        btnAddNotif.snp.makeConstraints { (m) in
            m.left.equalTo(50)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        btnAddNotif.addTarget(self, action: #selector(addNotif), for: .touchUpInside)
        
        view.addSubview(btnAddAsyncNotif)
        btnAddAsyncNotif.snp.makeConstraints { (m) in
            m.left.equalTo(50)
            m.top.equalTo(150)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        btnAddAsyncNotif.addTarget(self, action: #selector(addAsyncNotif), for: .touchUpInside)
        
        view.addSubview(btnSendNotif)
        btnSendNotif.snp.makeConstraints { (m) in
            m.left.equalTo(50)
            m.top.equalTo(350)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        btnSendNotif.addTarget(self, action: #selector(sendNotif), for: .touchUpInside)

        
        view.addSubview(btnSendAsyncNotif)
           btnSendAsyncNotif.snp.makeConstraints { (m) in
               m.left.equalTo(50)
               m.top.equalTo(400)
               m.width.equalTo(200)
               m.height.equalTo(40)
           }
           
           btnSendAsyncNotif.addTarget(self, action: #selector(sendAsyncNotif), for: .touchUpInside)
        
    }
    
    
    @objc  func addNotif() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotif(notif:)), name: NSNotification.Name.init(rawValue: "test"), object: "123")
        Toast.showToast(msg: "添加一次通知")
    }
    
    @objc  func addAsyncNotif() {
        
        NotificationQueue.default.enqueue(Notification(name: NSNotification.Name.init(rawValue: "test1")), postingStyle: .now, coalesceMask: .onName, forModes: [RunLoop.Mode.common])
        Toast.showToast(msg: "添加一次异步通知")
    }
    
    @objc func sendNotif() {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "test"), object: "123")
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "test1"), object: nil)
    }
    
    @objc func sendAsyncNotif() {
        DispatchQueue.global().async {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "test"), object: "123")

        }
   }

    @objc func receiveNotif(notif:Notification)  {
        print("abc")
    }
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
}
