//
//  KeyboardViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 28/02/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class KeyboardViewController: UIViewController {

    let txtkeyboard = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        txtkeyboard.placeholder = "这个试试身份证号"
        txtkeyboard.addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(NavigationBarHeight)
            m.height.equalTo(30)
        }
        
    }

}
