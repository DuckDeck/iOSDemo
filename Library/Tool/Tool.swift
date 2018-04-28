//
//  Tool.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class Tool{
    static func hiddenKeyboard(){
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
    }
    
    static func ChineseToPinyin(chinese:String)->String{
        let py = NSMutableString(string: chinese)
        CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
        return py as String
    }
}
