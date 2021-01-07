//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/6.
//

import UIKit
private var touchAreaEdgeInsets: UIEdgeInsets = .zero
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
}

