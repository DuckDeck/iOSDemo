//
//  LockView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/27.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

protocol LockViewDelegate:class {
    func comparePassword(lockView:LockView,password:String) -> Bool
    func outputResult(lockView:LockView,image:UIImage,result:Bool)
}

class LockView: UIView {
    weak var delegate:LockViewDelegate?
    var arrBtn:[UIButton]={
       var arr = [UIButton]()
        for i in 0..<9{
            let btn = UIButton()
            btn.setImage(UIImage.createEllipse(size: CGSize(width: 10, height: 10), color: UIColor.blue), for: .normal)
            btn.setImage(UIImage.createEllipse(size: CGSize(width: 10, height: 10), color: UIColor.green), for: .selected)
            btn.setImage(UIImage.createEllipse(size: CGSize(width: 10, height: 10), color: UIColor.red), for: .highlighted)
            btn.tag = i
            arr.append(btn)
        }
        return arr
    }()
    var arrSelectedBtn = [UIButton]()
    var currentPoint = CGPoint()
    var result = false
    var con:PointLockViewController?
    var currentPassword = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let column = 3
        let btnw:CGFloat = 74
        let btnH:CGFloat = 74
        var btnX:CGFloat = 0
        var btnY:CGFloat = 0
        let margin = (frame.size.width - column * btnw) / CGFloat(column + 1)
        for i in 0..<9{
            btnX = margin + (i%column) * (margin + btnw)
            btnY = margin + (i/column) * (margin + btnH)
            let btn = arrBtn[i]
            btn.frame = CGRect(x: btnX, y: btnY, w: btnw, h: btnH)
            btn.isUserInteractionEnabled = false
            addSubview(btn)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let p = touch.location(in: touch.view!)
        for i in 0 ..< arrBtn.count{
            if arrBtn[i].frame.contains(p){
                arrBtn[i].isSelected = true//
                if !arrSelectedBtn.contains(arrBtn[i]){
                    arrSelectedBtn.append(arrBtn[i])
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let p = touch.location(in: touch.view!)
        currentPoint = p
        for i in 0..<arrBtn.count{
            if arrBtn[i].frame.contains(p){
                arrBtn[i].isSelected = true//
                if !arrSelectedBtn.contains(arrBtn[i]){
                    arrSelectedBtn.append(arrBtn[i])
                }
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPoint = arrSelectedBtn.last!.center
        setNeedsDisplay()
        var password = ""
        for btn in arrSelectedBtn{
            password = password + btn.tag.toString
        }
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.clear()
            self.isUserInteractionEnabled = true
        }
        
        if let res = delegate?.comparePassword(lockView: self, password: password){
            result = res
            if result{
                print("password OK")
                for btn in arrSelectedBtn{
                    btn.isSelected = false
                }
                printScreen(result: true)
            }
            else{
                print("password wront")
                for btn in arrSelectedBtn{
                    btn.isHighlighted = true
                    btn.isSelected = false
                }
                printScreen(result: false)
            }
        }
        
    }
    
    func printScreen(result:Bool) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        delegate?.outputResult(lockView: self, image: img!, result: result)
    }
    
    func clear() {
        for btn in arrSelectedBtn{
            btn.isHighlighted = false
            btn.isSelected = false
        }
        arrSelectedBtn.removeAll()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        for i in 0..<arrSelectedBtn.count{
            if i == 0{
                path.move(to: arrSelectedBtn[i].center)
            }
            else{
                path.addLine(to: arrSelectedBtn[i].center)
            }
        }
        if arrSelectedBtn.count > 0{
            path.addLine(to: currentPoint)
        }
        UIColor.white.set()
        path.stroke()
    }
}
