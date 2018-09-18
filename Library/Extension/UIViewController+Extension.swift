//
//  UIViewController+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/14.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

private var UIViewController_Tag = 110
extension UIViewController{
    @objc  var tag:Int{
        get{
            return objc_getAssociatedObject(self, &UIViewController_Tag) as? Int ?? 0
        }
        set{
            objc_setAssociatedObject(self, &UIViewController_Tag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
