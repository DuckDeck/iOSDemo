//
//  TwoSideView.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

enum TurnStatus:Int {
    case Front = 0, Back
}

class TwoSideView: UIView {
    
    var turnStatus = TurnStatus.Front
    
    var frontView :UIView?{
        didSet{
            if frontView == nil{
                return
            }
            addSubview(frontView!)
            bringSubviewToFront(frontView!)
            let transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0, 1, 0)
            frontView!.layer.transform = transform
        }
    }
    var backView:UIView?{
        didSet{
            if  backView == nil {
                return
            }
            addSubview(backView!)
            sendSubviewToBack(backView!)
            let transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0, 1, 0)
            backView!.layer.transform = transform
        }
    }
  
    
    
    
    func turn(duration:TimeInterval,completed:(()->Void)?) {
        if frontView == nil || backView == nil {
            assert(true, "you should set frontView or backView")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            if self.turnStatus == .Front{
                self.bringSubviewToFront(self.backView!)
                self.turnStatus = .Back
            }
            else{
                self.bringSubviewToFront(self.frontView!)
                self.turnStatus = .Front
            }
        }
        UIView.animate(withDuration: duration, animations: {
            if self.turnStatus == .Front{
                let transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0, 1, 0)
                self.layer.transform = transform
            }
            else{
                let transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0, -1, 0)   //为什么没有用？
                self.layer.transform = transform
            }
           
        }) { (finish:Bool) in
            completed?()
        }
    }
    
    deinit {
        print("TwoSideView deinit")
    }
    
}
