//
//  LogViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/11/17.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import UIKit
class LogViewController:BaseViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        btnNewLog.addTo(view: view).snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(100)
        }
        btnNewLog.addClickEvent { btn in
        }
        btnGetLog.addTo(view: view).snp.makeConstraints { make in
            make.left.equalTo(150)
            make.top.equalTo(100)
        }
        btnGetLog.addClickEvent { btn in
            
            
        }
        btnUploadLog.addTo(view: view).snp.makeConstraints { make in
            make.left.equalTo(230)
            make.top.equalTo(100)
        }
        btnUploadLog.addClickEvent { btn in
            
        }

        
    }
    
    lazy var btnNewLog: UIButton = {
        let v = UIButton()
        v.setTitle("写一条日志", for: .normal)
        v.setTitleColor(UIColor.red, for: .normal)
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.yellow.cgColor
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        v.layer.cornerRadius = 16
        return v
    }()
    
    lazy var btnGetLog: UIButton = {
        let v = UIButton()
        v.setTitle("提取日志", for: .normal)
        v.setTitleColor(UIColor.red, for: .normal)
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.yellow.cgColor
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        v.layer.cornerRadius = 16
        return v
    }()
    
    lazy var btnUploadLog: UIButton = {
        let v = UIButton()
        v.setTitle("上传日志", for: .normal)
        v.setTitleColor(UIColor.red, for: .normal)
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.yellow.cgColor
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        v.layer.cornerRadius = 16
        return v
    }()
    
}
