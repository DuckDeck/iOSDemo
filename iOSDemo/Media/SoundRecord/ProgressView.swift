//
//  ProgressView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/25.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
class ProgressView: UIImageView {
    
    //MARK: - Private Properties
    /// 进度条
    private var progressLayer: CAShapeLayer!
    /// 进度动画
    private var animation: CABasicAnimation!
    /// 高斯模糊层
    private var blurView: UIVisualEffectView!
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 38
        clipsToBounds = true
        setUpBlurView()
        configAnimate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Animation
extension ProgressView {
    
    /// 开始计时动画
    public func countingAnimate() {
        progressLayer.add(animation, forKey: nil)
    }
    
    /// 停止计时动画
    public func stopAnimate() {
        progressLayer.removeAllAnimations()
    }
}

// MARK: - Setup
extension ProgressView {
    
    private func configAnimate() {
        let maskPath = UIBezierPath(roundedRect: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: 38)
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = maskPath.cgPath
        maskLayer.frame = bounds
        
        // 进度路径
        /*
         路径的中心为HUD的中心，宽度为HUD的高度，从左往右绘制
         */
        let progressPath = CGMutablePath()
        progressPath.move(to: CGPoint(x: 0, y: frame.height / 2))
        progressPath.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
        
        progressLayer = CAShapeLayer()
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor //图层背景颜色
        progressLayer.strokeColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 0.90).cgColor   //图层绘制颜色
        progressLayer.lineCap = kCALineCapButt
        progressLayer.lineWidth = 78
        progressLayer.path = progressPath
        progressLayer.mask = maskLayer
        
        blurView.contentView.layer.addSublayer(progressLayer)
        
        animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 60 //最大录音时长
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)    //匀速前进
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.autoreverses = false
        animation.repeatCount = 1
    }
    
    private func setUpBlurView() {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.black.withAlphaComponent(0.8).cgColor)
        context?.fill(rect)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        image = transparentImage
        
        if #available(iOS 10.0, *) {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        } else {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = layer.cornerRadius
        blurView.clipsToBounds = true
        addSubview(blurView)
    }
    
}
