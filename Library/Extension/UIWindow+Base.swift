//
//  UIWindow+Base.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

extension UIWindow{
//        open override func topMostController() -> UIViewController {
//             var topViewController = rootViewController!
//            while topViewController.presentedViewController != nil {
//                topViewController = topViewController.presentedViewController!
//            }
//            return topViewController
//        }
    
      open  func currentViewController() -> UIViewController? {
            var currentViewController = topMostController()
            while currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil  {
                currentViewController = (currentViewController as! UINavigationController).topViewController!
            }
            return currentViewController
        }
}
