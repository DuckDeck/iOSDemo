//
//  TextLayoutViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 17/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class TextLayoutViewController: UIViewController {

    let lbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        lbl.text = "我来试试"
        view.addSubview(lbl)
        lbl.layer.borderWidth = 1
        lbl.TwoSideAligment()
        lbl.snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(100)
            m.width.equalTo(150)
            m.height.equalTo(20)
        }
        // Do any additional setup after loading the view.
    }


}
