//
//  FormViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/7/31.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import Eureka
class FormTableViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Section1")
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter Text Here"
            }
            <<< PhoneRow(){ row in
                row.title = "你的电话"
                row.placeholder = "这里写电话号"
            }
        +++ Section("")
            <<< DateRow(){
                $0.title = "请选择日期"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
      
    }

}
