//
//  GandAlert.swift
//  iOSDemo
//
//  Created by Stan Hu on 01/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

extension UIAlertController{
    static func title(title:String?,message:String?, style:UIAlertController.Style = .alert) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        return alert
    }
    
  

    func setMessageAligment(aligment:NSTextAlignment) -> Self {
        let parent = self.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]
        if title == nil && message != nil{
            if let lbl = parent.subviews[0] as? UILabel{
               lbl.textAlignment = aligment  //只能改这个，不能改色和字体
            }
        }
        else if title != nil && message != nil{
            if let lbl = parent.subviews[1] as? UILabel{
                 lbl.textAlignment = aligment
            }
        }
        return self
    }
    
  
    
    static func title(attrTitle:NSAttributedString?,attrMessage:NSAttributedString?, style:UIAlertController.Style = .alert) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: style)
        if let t = attrTitle{
            alert.setValue(t, forKey: "attributedTitle")
        }
        if let m = attrMessage{
            alert.setValue(m, forKey: "attributedMessage")
        }
        return alert
    }
    
    func action(title:String,handle:((_ action:UIAlertAction)->Void)?, style:UIAlertAction.Style = .default) -> Self  {
        let action = UIAlertAction(title: title, style: style, handler: handle)
        self.addAction(action)
        return self
    }
    
    func action(title:String,handle:((_ action:UIAlertAction)->Void)?, color:UIColor, style:UIAlertAction.Style = .default) -> Self  {
        let action = UIAlertAction(title: title, style: style, handler: handle)
        action.setValue(color, forKey: "_titleTextColor")
        self.addAction(action)
        return self
    }
    
    func showAlert(viewController:UIViewController,animation:Bool = true)  {
        viewController.present(self, animated: animation, completion: nil)
    }
    
    public func show() {
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
}
