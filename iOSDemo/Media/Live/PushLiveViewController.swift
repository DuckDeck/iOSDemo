//
//  PushLiveViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/5/7.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import LFLiveKit

class PushLiveViewController: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        view.addSubview(LivePreview(frame: view.bounds))
        
    }
    
}

extension PushLiveViewController:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let res =  viewController is PushLiveViewController
            
        navigationController.navigationBar.isHidden = res
        navigationController.setNavigationBarHidden(res, animated: true)
    }
}
