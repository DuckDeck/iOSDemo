//
//  RippleAnimtaionView.swift
//  iOSDemo
//
//  Created by Stan Hu on 20/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class RippleAnimtaionView: UIView {

    var multiple:Double = 1.423
    let pulsingCount = 4
    let animationDuration = 2.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let animationLayer = CALayer()
        // 新建缩放动画
        //let animation = scaleAnimation
        // 新建一个动画 Layer，将动画添加上去
        //let layer = pulsingLayer(rect: rect, animation: animation)
        //animationLayer.addSublayer(layer)
        //将动画 Layer 添加到 animationLayer
        
        
        
        // 这里同时创建[缩放动画、背景色渐变、边框色渐变]三个简单动画
//        let arrAnimations = groupAnimations(arr: arrAnimraion)
//        let layer = pulsingLayer(rect: rect, animationGroup: arrAnimations)
//        animationLayer.addSublayer(layer)
        
        // 利用 for 循环创建三个动画 Layer
        for i in 0..<pulsingCount{
            let group = groupAnimations(arr: arrAnimraion, index: i)
            let layer = pulsingLayer(rect: rect, animationGroup: group)
            layer.borderColor = UIColor.clear.cgColor
            animationLayer.addSublayer(layer)
        }
        
        self.layer.addSublayer(animationLayer)
    }
    
    
    var arrAnimraion:[CAAnimation]{
        get{
            
            let scale = scaleAnimation
            let backgroundColor = backgroundColorAnimation
            let borderColor = borderColorAnimation
            let arr:[CAAnimation] = [scale,backgroundColor,borderColor]
            return arr
        }
    }
    
    func groupAnimations(arr:[CAAnimation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 3
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
        return group
    }
    
    func groupAnimations(arr:[CAAnimation],index:Int) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime() + index * animationDuration / pulsingCount
        group.duration = CFTimeInterval(animationDuration)
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
         // 添加动画曲线。关于其他的动画曲线，也可以自行尝试
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        return group
    }
    
    var scaleAnimation:CABasicAnimation{
        get{
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = 1
            scale.toValue = multiple
//            scale.beginTime = CACurrentMediaTime()
//            scale.duration = 3
//            scale.repeatCount = Float.infinity
            return scale
        }
    }
    
    var backgroundColorAnimation:CAKeyframeAnimation{
        get{
            let ani = CAKeyframeAnimation()
            ani.keyPath = "backgroundColor"
            let color1 = UIColor(red: 255.0/255.0, green: 216.0/255.0, blue: 87.0/255.0, alpha: 0.5).cgColor
            let color2 = UIColor(red: 255.0/255.0, green: 231.0/255.0, blue: 152.0/255.0, alpha: 0.5).cgColor
            let color3 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0.5).cgColor
            let color4 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0).cgColor
            ani.values = [color1,color2,color3,color4]
            ani.keyTimes = [0.3,0.6,0.9,1]
            return ani
        }
    }
    
    var borderColorAnimation:CAKeyframeAnimation{
        get{
            let ani = CAKeyframeAnimation()
            ani.keyPath = "borderColor"
            let color1 = UIColor(red: 255.0/255.0, green: 216.0/255.0, blue: 87.0/255.0, alpha: 0.5).cgColor
            let color2 = UIColor(red: 255.0/255.0, green: 231.0/255.0, blue: 152.0/255.0, alpha: 0.5).cgColor
            let color3 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0.5).cgColor
            let color4 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0).cgColor
            ani.values = [color1,color2,color3,color4]
            ani.keyTimes = [0.3,0.6,0.9,1]
            return ani
        }
    }
    
    func pulsingLayer(rect:CGRect,animation:CABasicAnimation) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animation, forKey: "pulsing")
        return pulsingLayer
    }
    
    func pulsingLayer(rect:CGRect,animationGroup:CAAnimationGroup) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animationGroup, forKey: "pulsing")
        return pulsingLayer
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class RippleAnimtaionView2: UIView {
    
    var multiple:Double = 1.423
    let pulsingCount = 4
    let animationDuration = 2.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let animationLayer = CALayer()
        // 新建缩放动画
        //let animation = scaleAnimation
        // 新建一个动画 Layer，将动画添加上去
        //let layer = pulsingLayer(rect: rect, animation: animation)
        //animationLayer.addSublayer(layer)
        //将动画 Layer 添加到 animationLayer
        
        
        
        // 这里同时创建[缩放动画、背景色渐变、边框色渐变]三个简单动画
        //        let arrAnimations = groupAnimations(arr: arrAnimraion)
        //        let layer = pulsingLayer(rect: rect, animationGroup: arrAnimations)
        //        animationLayer.addSublayer(layer)
        
        // 利用 for 循环创建三个动画 Layer
        for i in 0..<pulsingCount{
            let group = groupAnimations(arr: arrAnimraion, index: i)
            let layer = pulsingLayer(rect: rect, animationGroup: group)
            layer.borderColor = UIColor.clear.cgColor
            animationLayer.addSublayer(layer)
        }
        
        self.layer.addSublayer(animationLayer)
    }
    
    
    var arrAnimraion:[CAAnimation]{
        get{
            
            let scale = scaleAnimation
            let borderColor = borderColorAnimation
            let arr:[CAAnimation] = [scale,borderColor]
            return arr
        }
    }
    
    func groupAnimations(arr:[CAAnimation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 3
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
        return group
    }
    
    func groupAnimations(arr:[CAAnimation],index:Int) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime() + index * animationDuration / pulsingCount
        group.duration = CFTimeInterval(animationDuration)
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
        // 添加动画曲线。关于其他的动画曲线，也可以自行尝试
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        return group
    }
    
    var scaleAnimation:CABasicAnimation{
        get{
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = 1
            scale.toValue = multiple
            //            scale.beginTime = CACurrentMediaTime()
            //            scale.duration = 3
            //            scale.repeatCount = Float.infinity
            return scale
        }
    }
    
    
    var borderColorAnimation:CAKeyframeAnimation{
        get{
            let ani = CAKeyframeAnimation()
            ani.keyPath = "borderColor"
            let color1 = UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 0.5).cgColor
            let color2 = UIColor(red: 99.0/255.0, green: 99.0/255.0, blue: 99.0/255.0, alpha: 0.5).cgColor
            let color3 = UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 145.0/255.0, alpha: 0.5).cgColor
            let color4 = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 0).cgColor
            ani.values = [color1,color2,color3,color4]
            ani.keyTimes = [0.3,0.6,0.9,1]
            return ani
        }
    }
    
    func pulsingLayer(rect:CGRect,animation:CABasicAnimation) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animation, forKey: "pulsing")
        return pulsingLayer
    }
    
    func pulsingLayer(rect:CGRect,animationGroup:CAAnimationGroup) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animationGroup, forKey: "pulsing")
        return pulsingLayer
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
