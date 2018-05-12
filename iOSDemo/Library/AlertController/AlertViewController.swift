//
//  AlertViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 17/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
class AlertViewController: UIViewController {

    let btn = UIButton()
    var timer:GrandTimer!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        btn.title(title: "Alert").color(color: UIColor.purple).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(30)
        }
        btn.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromSeconds(1), target: self, sel: #selector(tick), userInfo: nil, repeats: true, dispatchQueue: DispatchQueue.main)
        
        let startBtn = UIBarButtonItem(title: "start", style: .plain, target: self, action: #selector(start))
        navigationItem.rightBarButtonItem = startBtn
    }

    @objc func showAlert() {
        timer.invalidate()
        let attrStr = NSMutableAttributedString(string: "购买本次修复服务需花费20积分,是否确实购买")
        attrStr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSMakeRange(11, 2))
        let alert = UIAlertController.title(attrTitle: nil, attrMessage: attrStr).action(title: "取消",handle: nil, color:UIColor.gray).action(title: "购买", handle: {(action:UIAlertAction) in
            self.timer.pause()
        })
  //      alert.show()
//
//       let alert = UIAlertController.title(title: nil, message: "这是一个测试").setMessageFont(font: UIFont.systemFont(ofSize: 17)).action(title: "OK", handle: nil)
//
        let txt = UITextView()
        let p =  txt.getProperty()
        let pla = txt.value(forKey: "_placeholderLabel")
        
        print(p)
        alert.show()
    }
   
    @objc func start()  {
        timer.fire()
    }

    @objc func tick() {
        Log(message: "123132123")
    }
    
}
