//
//  SearchDemoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/9/7.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit

class SearchDemoViewController: UIViewController {

    let lblIntro = UILabel()
    
    let lblCode = UILabel()
    let btnRun = UIButton()
    var strDesc = ""
    var code : [[String]]?
    let btnClose = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        lblIntro.text(text: strDesc).lineNum(num: 0).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.top.equalTo(10)
            
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    

   

}
