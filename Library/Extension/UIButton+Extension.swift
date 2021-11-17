//
//  UIButton+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/8/1.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
private var touchAreaEdgeInsets: UIEdgeInsets = .zero
typealias buttonAction = (UIButton)->()

extension UIButton{
    public var touchInsets:UIEdgeInsets{
        get{
            if let value = objc_getAssociatedObject(self, &touchAreaEdgeInsets) as? NSValue{
                var edgeInsets:UIEdgeInsets = .zero
                value.getValue(&edgeInsets)
                return edgeInsets
            }
            else{
                return .zero
            }
        }
        set{
            var newValueCopy = newValue
            let objcType = NSValue(uiEdgeInsets: .zero).objCType
            let value = NSValue(bytes: &newValueCopy, objCType: objcType)
            objc_setAssociatedObject(self, &touchAreaEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.touchInsets == .zero || !self.isEnabled || self.isHidden{
            return super.point(inside: point, with: event)
        }
        let relativeFramt = self.bounds
        
        let hitFrame = relativeFramt.inset(by: self.touchInsets)
        return hitFrame.contains(point)
    }
    
    
    private struct butKeys{
       static var action = "click"
   }
   
   @objc dynamic var click: buttonAction? {
       set{
           objc_setAssociatedObject(self,&butKeys.action, newValue, .OBJC_ASSOCIATION_COPY)
       }
       get{
           if let action = objc_getAssociatedObject(self, &butKeys.action) as? buttonAction{
               return action
           }
           return nil
       }
   }
   
   func addClickEvent(click:@escaping  buttonAction) {
       self.click = click
       self.addTarget(self, action: #selector(touchUpInSideFun), for: UIButton.Event.touchUpInside)
       
   }
   
   @objc func touchUpInSideFun(but: UIButton) {
       if let click = self.click {
           click(but)
       }
   }
}
