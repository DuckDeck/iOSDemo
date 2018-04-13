//
//  GandAlert.swift
//  iOSDemo
//
//  Created by Stan Hu on 01/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

extension UIAlertController{
    static func title(title:String?,message:String?, style:UIAlertControllerStyle = .alert) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        return alert
    }
    
    static func title(attrTitle:NSAttributedString?,attrMessage:NSAttributedString?, style:UIAlertControllerStyle = .alert) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: style)
        if let t = attrTitle{
            alert.setValue(t, forKey: "attributedTitle")
        }
        if let m = attrMessage{
            alert.setValue(m, forKey: "attributedMessage")
            if let v = alert.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[attrTitle == nil ? 0 : 1] as? UILabel{
                v.textAlignment = .left
            }
        }
        return alert
    }
    
    func action(title:String,handle:((_ action:UIAlertAction)->Void)?, style:UIAlertActionStyle = .default) -> Self  {
        let action = UIAlertAction(title: title, style: style, handler: handle)
        self.addAction(action)
        return self
    }
    
    func action(title:String,handle:((_ action:UIAlertAction)->Void)?, color:UIColor, style:UIAlertActionStyle = .default) -> Self  {
        let action = UIAlertAction(title: title, style: style, handler: handle)
        action.setValue(color, forKey: "_titleTextColor")
        self.addAction(action)
        return self
    }
    
    func showAlert(viewController:UIViewController,animation:Bool = true)  {
        viewController.present(self, animated: animation, completion: nil)
    }
}
