//
//  BaseViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 28/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    deinit {
         Log(message: "\(type(of:self))已经被回收了")
    }

    
}
