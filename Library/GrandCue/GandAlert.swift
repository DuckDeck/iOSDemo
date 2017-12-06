//
//  GandAlert.swift
//  iOSDemo
//
//  Created by Stan Hu on 01/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

extension UIAlertController{
    static func title(title:String,message:String?, style:UIAlertControllerStyle = .alert) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        return alert
    }
    
    func action(title:String,handle:((_ action:UIAlertAction)->Void)?, style:UIAlertActionStyle = .default) -> Self  {
        let action = UIAlertAction(title: title, style: style, handler: handle)
        self.addAction(action)
        return self
    }
    
    func showAlert(viewController:UIViewController,animation:Bool = true)  {
        viewController.present(self, animated: animation, completion: nil)
    }
}
