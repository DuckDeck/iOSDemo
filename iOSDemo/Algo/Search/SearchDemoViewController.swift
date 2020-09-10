//
//  SearchDemoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/9/7.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit
import SwiftyMarkdown
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
        
        var k = 20.createRandomNums(max: 100)
        k.sort()
        let code = """
        ```
         var s = 100;
        ```
        """
        lblCode.attributedText = SwiftyMarkdown(string: code).attributedString()
        lblCode.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(10)
            m.top.equalTo(lblIntro.snp.bottom).offset(20)
        }
        
        
    }
    

   

}
