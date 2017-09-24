//
//  LayerAnimationViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class LayerAnimationViewController: UIViewController,CAAnimationDelegate {
    var imgDemo = UIImageView(image: UIImage(named: "1"))
    var btnMove = UIButton(frame: CGRect(x: 10, y: UIScreen.main.bounds.size.height - 100, width: 80, height: 30))
    var btnStop = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - 40, y: UIScreen.main.bounds.size.height - 150, width: 80, height: 30))
    var btnAnimtaionGroup = UIButton(frame: CGRect(x: 100, y: UIScreen.main.bounds.size.height - 100, width: 80, height: 30))
    var btnSpringAnimation = UIButton(frame: CGRect(x: 200, y: UIScreen.main.bounds.size.height - 100, width: 80, height: 30))
    
    
    var btnKeyframeAimation = UIButton(frame: CGRect(x: 270, y: UIScreen.main.bounds.size.height - 100, width: 80, height: 30))
    var btnAddMusk = UIButton(frame: CGRect(x: 10, y: UIScreen.main.bounds.size.height - 50, width: 80, height: 30))
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        imgDemo.frame = CGRect(x: 0, y: 64, width: 200, height: 300)
        view.addSubview(imgDemo)
        btnMove.setTitle("开始动画", for: UIControlState())
        btnMove.tag = 0
        btnMove.setTitleColor(UIColor.red, for: UIControlState())
        btnMove.addTarget(self, action: #selector(LayerAnimationViewController.click(_:)), for: .touchUpInside)
        view.addSubview(btnMove)
        
        btnStop.setTitle("停止", for: UIControlState())
        btnStop.addTarget(self, action: #selector(LayerAnimationViewController.stopClick(_:)), for: .touchUpInside)
        btnStop.setTitleColor(UIColor.red, for: UIControlState())
        view.addSubview(btnStop)
        
        
        btnAnimtaionGroup.setTitle("动画组", for: UIControlState())
        btnAnimtaionGroup.addTarget(self, action: #selector(LayerAnimationViewController.animationGroupClick(_:)), for: .touchUpInside)
        btnAnimtaionGroup.setTitleColor(UIColor.red, for: UIControlState())
        view.addSubview(btnAnimtaionGroup)
        
        
        btnSpringAnimation.setTitle("弹簧", for: UIControlState())
        btnSpringAnimation.addTarget(self, action: #selector(LayerAnimationViewController.springClick(_:)), for: .touchUpInside)
        btnSpringAnimation.setTitleColor(UIColor.red, for: UIControlState())
        view.addSubview(btnSpringAnimation)
        
        
        btnKeyframeAimation.setTitle("关键帧", for: UIControlState())
        btnKeyframeAimation.addTarget(self, action: #selector(LayerAnimationViewController.keyFrameClick(_:)), for: .touchUpInside)
        btnKeyframeAimation.setTitleColor(UIColor.red, for: UIControlState())
        view.addSubview(btnKeyframeAimation)
        
        btnAddMusk.setTitle("加Mask", for: UIControlState())
        btnAddMusk.tag = 1
        btnAddMusk.addTarget(self, action: #selector(LayerAnimationViewController.click(_:)), for: .touchUpInside)
        btnAddMusk.setTitleColor(UIColor.red, for: UIControlState())
        view.addSubview(btnAddMusk)
        
        
        avatar1.image = UIImage(named: "2")!
        avatar2.image = UIImage(named: "3")!
        avatar1.lblName.text = "FOX"
        avatar2.lblName.text = "DOG"
        
        view.addSubview(avatar1)
        view.addSubview(avatar2)
        
        
    }

    
    
    //    func click(sender:UIButton) {
    //        let flyRight = CABasicAnimation(keyPath: "position.x")
    //        flyRight.fromValue = 20
    //        flyRight.toValue = 200
    //        flyRight.duration = 1
    //        // 延迟0.3执行
    //        flyRight.beginTime = CACurrentMediaTime() + 0.3
    //         // 添加到imgDemo上
    //        imgDemo.layer.addAnimation(flyRight, forKey: nil)
    //    }
    
    
    //那么如果要dogImageView保持在结束状态该怎样做呢?
    
    //    kCAFillModeRemoved : 默认样式 动画结束后会回到layer的开始的状态
    //    kCAFillModeForwards : 动画结束后,layer会保持结束状态
    //    kCAFillModeBackwards : layer跳到fromValue的值处,然后从fromValue到toValue播放动画,最后回到layer的开始的状态
    //    kCAFillModeBoth : kCAFillModeForwards和kCAFillModeBackwards的结合,即动画结束后layer保持在结束状态
    
    
    //    也就是说layer动画并不是真实的,如果要变成真实的需要改变其position,那问题来了这个效果的使用场景是什么?
    //    答:视图不需要交互,且动画的开始和结束需要设置特殊的值.
    
    
    func click(_ sender:UIButton) {
        switch sender.tag {
        case 0:
            moveAnimation()
        case 1:
            addMask()
        default:
            break
        }
    }
    
    
    
    func  moveAnimation()  {
        let flyRight = CABasicAnimation(keyPath: "position.x")
        // 动画结束后,layer会保持结束状态
        flyRight.isRemovedOnCompletion = false
        // 保证fillMode起作用
        flyRight.fillMode = kCAFillModeBoth
        flyRight.fromValue = 100   //position.x是指中心
        flyRight.toValue = 200
        flyRight.duration = 1
        // 延迟0.3执行
        flyRight.beginTime = CACurrentMediaTime() + 1
        // 添加到imgDemo上
        
        //启用代理 ，
        //如果我想在动画开始和结束的时候分别搞点事情该怎样做呢?对的,可以用代理呀!
        
        //    使用Layer Animations可以设置好一个Animation,然后添加到不同的view上面,但这时如果我们设置了flyRight的代理,并将flyRight添加到了很多的view上面,那该怎样才能在代理方法中区分哪个是哪个呢?
        
        
        flyRight.setValue("from", forKey: "name")
        //这里不要忘记设置了
        flyRight.setValue(imgDemo.layer, forKey: "layer")
        
        flyRight.delegate = self
        //设置一个key是哪个动画
        
        //    使用Layer Animations可以设置好一个Animation,然后添加到不同的view上面,但这时如果我们设置了flyRight的代理,并将flyRight添加到了很多的view上面,那该怎样才能在代理方法中区分哪个是哪个呢?
        
        imgDemo.layer.add(flyRight, forKey: "position")
        
    }
    
    func stopClick(_ sender:UIButton)  {
        imgDemo.layer.removeAnimation(forKey: "position")
        imgDemo.layer.removeAllAnimations()
    }
    
    //添加Mask遮罩
    func addMask()  {
        let circleLayer = CAShapeLayer()
        let maskLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: imgDemo.bounds).cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        maskLayer.path = circleLayer.path
        // 超出maskLayer部分裁剪掉
        imgDemo.layer.mask = maskLayer
        imgDemo.layer.addSublayer(circleLayer)
    }
    
    
    func animationGroupClick(_ sender:UIButton){
        let groupAnimation = CAAnimationGroup()
        groupAnimation.beginTime = CACurrentMediaTime() + 1
        groupAnimation.duration = 3
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAScrollBoth
        
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        groupAnimation.repeatCount = 4.5
        groupAnimation.autoreverses = true
        groupAnimation.speed = 2.0
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 1.5
        scaleDown.toValue = 1.0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = CGFloat(M_PI_4)
        rotate.toValue = 0.0
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.5
        fade.toValue = 1.0
        groupAnimation.animations = [scaleDown,rotate,fade]
        imgDemo.layer.add(groupAnimation, forKey: "groupAnimation")
        
    }
    
    
    func springClick(_ sender:UIButton)  {
        let scaleDown = CASpringAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 1.5
        scaleDown.toValue  = 1.0
        // settlingDuration：结算时间（根据动画参数估算弹簧开始运动到停止的时间，动画设置的时间最好根据此时间来设置）
        scaleDown.duration = scaleDown.settlingDuration
        // mass：质量（影响弹簧的惯性，质量越大，弹簧惯性越大，运动的幅度越大) 默认值为1
        scaleDown.mass = 3.0
        // stiffness：弹性系数（弹性系数越大，弹簧的运动越快）默认值为100
        scaleDown.stiffness = 150.0
        // damping：阻尼系数（阻尼系数越大，弹簧的停止越快）默认值为10
        scaleDown.damping = 50
        // initialVelocity：初始速率（弹簧动画的初始速度大小，弹簧运动的初始方向与初始速率的正负一致，若初始速率为0，表示忽略该属性）默认值为0
        scaleDown.initialVelocity = 100
        imgDemo.layer.add(scaleDown, forKey: nil)
    }
    
    
    
    func keyFrameClick(_ sender:UIButton) {
        // 这个是移动位置
        //        let flight = CAKeyframeAnimation(keyPath: "position")
        //        flight.duration = 4.0
        //        // 无限重复
        //        flight.repeatCount = MAXFLOAT
        //        //  注意:不能将CGPoint直接赋值给values需要转换,数组中的元素可以使结构体
        //        // .map { NSValue(CGPoint: $0)}可以将数组中的每一个CGPoint转化为NSValue
        //
        //        flight.values = [CGPointMake(50, 100),
        //            CGPointMake(view.frame.width - 50, 160),
        //            CGPointMake(50, view.center.y),
        //            CGPointMake(50.0, 100.0)].map{NSValue(CGPoint:$0)}
        //
        //        flight.keyTimes = [0.0,0.33,0.66,1.0]
        //        imgDemo.layer.addAnimation(flight, forKey: nil)
        
        let swagger = CAKeyframeAnimation(keyPath: "transform.rotation")
        swagger.duration = 3
        swagger.repeatCount = MAXFLOAT
        swagger.values = [0.0,-M_PI_4 / 4,0.0,M_PI_4 / 3,0.0]
        swagger.keyTimes = [0.0,0.25,0.5,0.75,1.0]
        imgDemo.layer.add(swagger, forKey: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let avaterSize = avatar1.frame.size
        let morphSize = CGSize(width: avaterSize.width * 0.85, height: avaterSize.height * 1.05)
        let bounceXOffset = view.frame.size.width / 2.0 - avatar1.lineWidth * 2 - avatar1.frame.width
        avatar2.boundsOffset(bounceXOffset, morphSize: morphSize)
        avatar1.boundsOffset(avatar1.frame.origin.x - bounceXOffset, morphSize: morphSize)
    }
    
    lazy var avatar1:AnimationVIew = {
        let avaterView = AnimationVIew()
        avaterView.frame = CGRect(x: self.view.frame.width - 90 - 20, y: self.view.center.y, width: 90, height: 90)
        return avaterView
    }()
    
    lazy var avatar2:AnimationVIew = {
        let avaterView = AnimationVIew()
        avaterView.frame = CGRect(x: 20, y: self.view.center.y, width: 90, height: 90)
        return avaterView
    }()

}

extension LayerAnimationViewController{
    func animationDidStart(_ anim: CAAnimation) {
        print("动画开始调用")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print("动画完成调用")
            if let name = anim.value(forKey: "name") as? String{
                if name == "from"{
                    print("name is from")
                    let layer = anim.value(forKey: "layer") as? CALayer
                    anim.setValue(nil, forKey: "layer")
                    let plus = CABasicAnimation(keyPath: "transform.scale")
                    plus.fromValue = 1.25
                    plus.toValue = 1.0
                    plus.duration = 2.2
                    layer?.add(plus, forKey: nil)//结束后来一个动画
                }
            }
        }
        else{
            print("动画没有完成调用")
            
        }
    }

    

}
