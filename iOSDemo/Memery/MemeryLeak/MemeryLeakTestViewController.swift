//
//  MemeryLeakTestViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
class MemeryLeakTestViewController: UIViewController {

    override func loadView() {
        super.loadView()
        self.view = TGFrameLayout(frame: self.view.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
