//
//  OffSreenRenderViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/7/9.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit

class OffSreenRenderViewController: UIViewController {

    let v = UIImageView()
    let b = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(v)
        v.backgroundColor = UIColor.cyan
        v.snp.makeConstraints { (m) in
            m.left.top.equalTo(100)
            m.width.height.equalTo(200)
        }
        v.image = UIImage(named: "3")
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.red.cgColor
        v.clipsToBounds = true
        v.layer.cornerRadius = 100
        
        //目前还没有离屏渲染
        
        //目前还是没有，因为iOS9的优化
        
        view.addSubview(b)
        b.snp.makeConstraints { (m) in
            m.left.equalTo(100)
            m.top.equalTo(250)
            m.width.height.equalTo(200)
        }
        b.setImage(UIImage(named: "2"), for: .normal)
        b.layer.cornerRadius = 40
        b.clipsToBounds = true
        b.layer.masksToBounds = true
        //好像也没有离屏渲染
    }
    

 
}
