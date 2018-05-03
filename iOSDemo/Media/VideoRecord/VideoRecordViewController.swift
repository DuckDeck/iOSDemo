//
//  VideoRecordViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class VideoRecordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let btnBar = UIBarButtonItem(title: "已有视频", style: .plain, target: self, action: #selector(gotoAlreadyExistVideo))
        navigationItem.rightBarButtonItem = btnBar

    }
    @objc func gotoAlreadyExistVideo()  {
        
    }
    
    

}
