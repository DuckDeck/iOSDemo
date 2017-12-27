//
//  ThreadViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class ThreadViewController: UIViewController {
    let lbl =   UILabel().then {
        $0.text = "this is for test thread"
        $0.textColor = UIColor.red
        $0.backgroundColor = UIColor.green
        $0.frame = CGRect(x: 0, y: 200, width: 100, height: 100)
    }
    
    let btn = UIButton().then {
        $0.setTitle("按钮", for: .normal)
        $0.color(color: UIColor.red).bgColor(color: UIColor.gray).completed()
        $0.frame = CGRect(x: 200, y: 200, width: 100, height: 30)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(lbl)
        btn.addTarget(self, action: #selector(ThreadViewController.clickDown(sender:)), for: .touchUpInside)
        view.addSubview(btn)
        
     
    }

    @objc func clickDown(sender:UIButton)  {
        Semaphore.testSemaphore()
        Semaphore.testAsyncFinished()
        Semaphore.testProductionAndConsumer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
