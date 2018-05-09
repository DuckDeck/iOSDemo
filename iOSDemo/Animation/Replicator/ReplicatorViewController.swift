//
//  ReplicatorViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class ReplicatorViewController: UIViewController {
    var viewDeme = UIView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 100))
    var viewDemo2 = UIView(frame: CGRect(x: 0, y: 220, width: UIScreen.main.bounds.size.width, height: 100))
    var viewDemo3 = UIView(frame: CGRect(x: 0, y: 380, width: UIScreen.main.bounds.size.width, height: 100))
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        
        setupView1()
        setupView2()
        setupView3()
    }

    
    
    func setupView1()  {
        view.addSubview(viewDeme)
        // Do any additional setup after loading the view.
        
        //CALayer的子类CAReplicatorLayer通过它可以对其创建的对象进行复制,从而做出复杂的效果.
        let replicator = CAReplicatorLayer()
        let dot = CALayer()
        let dotLength:CGFloat = 6.0
        let dotOffset:CGFloat = 8.0
        replicator.frame = viewDeme.bounds
        viewDeme.layer.addSublayer(replicator)
        
        dot.frame = CGRect(x: replicator.frame.size.width - dotLength, y: replicator.position.y, width: dotLength, height: dotLength)
        dot.backgroundColor = UIColor.lightGray.cgColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        dot.borderWidth = 0.5
        dot.cornerRadius = 1.5
        replicator.addSublayer(dot)
        
        replicator.instanceCount = Int(viewDeme.frame.size.width / dotOffset)
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0.0, 0.0)
        
        //2 . 让它动起来,并且让每一个dot做一点延迟.
        //        let move = CABasicAnimation(keyPath: "position.y")
        //        move.fromValue = dot.position.y
        //        move.toValue = dot.position.y - 50
        //        move.duration  = 1.0
        //        move.repeatCount = 10
        //        dot.addAnimation(move, forKey: nil)
        //        replicator.instanceDelay = 0.02
        
        //加个更大的动画效果
        
        replicator.instanceDelay = 0.02
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D:CATransform3DIdentity)
        scale.toValue = NSValue(caTransform3D:CATransform3DMakeScale(1.4, 15, 1.0))
        scale.duration = 0.33
        scale.repeatCount = Float.infinity
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(scale, forKey: "dotScale")
        
        //4 .添加一个渐变色
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.2
        fade.duration = 0.33
        fade.beginTime = CACurrentMediaTime() + 0.33
        fade.repeatCount = Float.infinity
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(fade, forKey: "dotOpacity")
        //5 . 添加渐变的颜色
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = UIColor.magenta.cgColor
        tint.toValue = UIColor.cyan.cgColor
        tint.duration = 0.66
        tint.beginTime = CACurrentMediaTime() + 0.28
        tint.fillMode = kCAFillModeBackwards
        tint.repeatCount = Float.infinity
        tint.autoreverses = true
        tint.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(tint, forKey: "dotColor")
        
        //设置成上下摇摆
        let initialRotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        initialRotation.fromValue = 0.0
        initialRotation.toValue = 0.01
        initialRotation.duration = 0.33
        initialRotation.isRemovedOnCompletion = false
        initialRotation.fillMode = kCAFillModeBackwards
        initialRotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        replicator.add(initialRotation, forKey: "initialRocation")
        
        let rotation = CABasicAnimation(keyPath: "instanceTransform.rotation")
        rotation.fromValue = 0.01
        rotation.toValue = -0.01
        rotation.duration = 0.99
        rotation.beginTime = CACurrentMediaTime() + 0.33
        rotation.repeatCount = Float.infinity
        rotation.autoreverses = true
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        replicator.add(rotation, forKey: "replicatorRotation")
    }
    
    func setupView2()  {
        view.addSubview(viewDemo2)
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 10, height: 80)
        layer.backgroundColor = UIColor.white.cgColor
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.add(scaleYAnimation(), forKey: "scaleAnimation")
        
       
        let replicator = CAReplicatorLayer()
        replicator.instanceCount = 10  //        设置复制层里面包含子层的个数
        replicator.instanceTransform = CATransform3DMakeTranslation(45, 10, 0) //        设置子层相对于前一个层的偏移量
        replicator.instanceDelay = 0.2 //        设置子层相对于前一个层的延迟时间
        replicator.instanceColor = UIColor.green.cgColor //        设置层的颜色，(前提是要设置层的背景颜色，如果没有设置背景颜色，默认是透明的，再设置这个属性不会有效果。
        replicator.instanceGreenOffset = -0.2 //        颜色的渐变，相对于前一个层的渐变（取值-1~+1）.RGB有三种颜色，所以这里也是绿红蓝三种。
        replicator.instanceRedOffset = -0.2
        replicator.instanceBlueOffset = -0.2
        replicator.addSublayer(layer) //        需要把子层加入到复制层中，复制层按照前面设置的参数自动复制
        
        viewDemo2.layer.addSublayer(replicator)
    }
    
    func setupView3() {
        view.addSubview(viewDemo3)
        //CALayer的子类CAReplicatorLayer通过它可以对其创建的对象进行复制,从而做出复杂的效果.
        let replicator = CAReplicatorLayer()
        let dot = CALayer()
        let dotLength:CGFloat = 6.0
        let dotOffset:CGFloat = 8.0
        replicator.frame = viewDemo3.bounds
        viewDemo3.layer.addSublayer(replicator)
        
        dot.frame = CGRect(x: replicator.frame.size.width - dotLength, y: replicator.position.y, width: dotLength, height: dotLength)
        dot.backgroundColor = UIColor.lightGray.cgColor
        dot.borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        dot.borderWidth = 0.5
        dot.cornerRadius = 1.5
        replicator.addSublayer(dot)
        
        replicator.instanceCount = Int(viewDemo3.frame.size.width / dotOffset)
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0.0, 0.0)
        
        //2 . 让它动起来,并且让每一个dot做一点延迟.
        //        let move = CABasicAnimation(keyPath: "position.y")
        //        move.fromValue = dot.position.y
        //        move.toValue = dot.position.y - 50
        //        move.duration  = 1.0
        //        move.repeatCount = 10
        //        dot.addAnimation(move, forKey: nil)
        //        replicator.instanceDelay = 0.02
        
        //加个更大的动画效果
        
        replicator.instanceDelay = 0.02
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D:CATransform3DIdentity)
        scale.toValue = NSValue(caTransform3D:CATransform3DMakeScale(1.4, 15, 1.0))
        scale.duration = 0.33
        scale.repeatCount = Float.infinity
        scale.autoreverses = true
        scale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(scale, forKey: "dotScale")
        
        //4 .添加一个渐变色
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.2
        fade.duration = 0.33
        fade.beginTime = CACurrentMediaTime() + 0.33
        fade.repeatCount = Float.infinity
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(fade, forKey: "dotOpacity")
        //5 . 添加渐变的颜色
        let tint = CABasicAnimation(keyPath: "backgroundColor")
        tint.fromValue = UIColor.magenta.cgColor
        tint.toValue = UIColor.cyan.cgColor
        tint.duration = 0.66
        tint.beginTime = CACurrentMediaTime() + 0.28
        tint.fillMode = kCAFillModeBackwards
        tint.repeatCount = Float.infinity
        tint.autoreverses = true
        tint.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        dot.add(tint, forKey: "dotColor")
     
    }


    func scaleYAnimation() -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "transform.scale.y")
        anim.toValue = 0.1
        anim.duration = 0.4
        anim.autoreverses = true
        anim.repeatCount = MAXFLOAT
        return anim
    }
}
