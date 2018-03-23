//
//  RippleViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 20/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class RippleViewController: UIViewController {

    let vAni = RippleAnimtaionView(frame: CGRect(x: 50, y: 150, width: 100, height: 100))
    let vAni2 = RippleAnimtaionView2(frame: CGRect(x: 220, y: 150, width: 100, height: 100))
    let bgView = UIView(frame: CGRect(x: 220, y: 150, width: 100, height: 100))
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        view.addSubview(vAni)
        bgView.backgroundColor = UIColor.orange
        bgView.layer.cornerRadius = 50
        view.addSubview(bgView)
        view.addSubview(vAni2)
        
        // Do any additional setup after loading the view.
    }

 

}
