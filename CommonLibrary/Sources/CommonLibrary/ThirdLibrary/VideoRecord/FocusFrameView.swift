//
//  FocusFrameView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/6/4.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FocusFrameView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        layer.borderWidth = 2
        layer.borderColor = UIColor.blue.cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startToFocus(point:CGPoint,view:UIView) {
        
        view.addSubview(self)
        self.center = point
        let scaleAn = CABasicAnimation(keyPath: "transform.scale")
        scaleAn.isRemovedOnCompletion = false
        scaleAn.fromValue = 2
        scaleAn.toValue = 1
        scaleAn.setValue("scale", forKey: "name")
        scaleAn.delegate = self
        layer.add(scaleAn, forKey: nil)
        
        //再来个闪
        
    }
}
extension FocusFrameView:CAAnimationDelegate{
    func animationDidStart(_ anim: CAAnimation) {
        print("动画开始调用")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print("动画完成调用")
            let name = anim.value(forKey: "name") as! String
            if name == "fade"{
                removeFromSuperview()
            }
            else{
                let fade = CABasicAnimation(keyPath: "opacity")
                fade.fromValue = 1
                fade.toValue = 0
                fade.repeatCount = 2
                fade.delegate = self
                fade.setValue("fade", forKey: "name")
                layer.add(fade, forKey: nil)//结束后来一个动画
            }
        }
        else{
            print("动画没有完成调用")
            
        }
    }
}
