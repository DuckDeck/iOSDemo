//
//  SoundRecordViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 12/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class SoundRecordViewController: UIViewController {
    
    var btnRecord = UIButton()
    var btnStop = UIButton()
    var btnPlay = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnRecord.title(title: "录音").bgColor(color: UIColor.orange).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.width.equalTo(150)
            m.height.equalTo(22)
            m.top.equalTo(80)
        }
        btnRecord.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        
    }

    @objc func startRecord()  {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}
