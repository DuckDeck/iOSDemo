//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/6.
//

import UIKit

private var UIViewController_Tag = 110
public extension UIViewController{
    @objc  var tag:Int{
        get{
            return objc_getAssociatedObject(self, &UIViewController_Tag) as? Int ?? 0
        }
        set{
            objc_setAssociatedObject(self, &UIViewController_Tag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
