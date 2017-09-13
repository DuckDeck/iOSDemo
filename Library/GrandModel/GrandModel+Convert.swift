//
//  GrandModel+Convert.swift
//  GrandModelDemo
//
//  Created by HuStan on 5/26/16.
//  Copyright © 2016 StanHu. All rights reserved.
//

import UIKit

extension GrandModel{
    func convert() -> [String:Any] {
        var dict = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let k =  child.label{
                dict[k] = child.value
            }
        }
        return dict
    }
}