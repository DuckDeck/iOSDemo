//
//  Tool.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class Tool{
    static func hiddenKeyboard(){
       UIApplication.shared.keyWindow?.currentViewController()?.view.endEditing(true)
    }
}
