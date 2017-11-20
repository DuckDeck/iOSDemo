//
//  AnimationVIew.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class AnimationVIew: UIView {
    var lblName:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    var lineWidth:CGFloat = 8.0
    var animationDuration:TimeInterval = 1.0
    var isSquare = false
    
    var photoLayer = CALayer()
    var maskLayer = CAShapeLayer()
    var circleLayer = CAShapeLayer()
    @IBInspectable
    var image:UIImage{
        didSet{
            photoLayer.contents = image.cgImage
        }
    }
    
    override init(frame: CGRect) {
        image = UIImage()
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        layer.addSublayer(photoLayer)
        photoLayer.mask = maskLayer
        layer.addSublayer(circleLayer)
        addSubview(lblName)
    }
    
    override func layoutSubviews() {
        photoLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        maskLayer.path = circleLayer.path
        maskLayer.position = CGPoint(x: 0, y: 0)
        lblName.frame = CGRect(x: 0, y: bounds.size.height + 10, width: bounds.size.width, height: 24)
    }
    
    
    func boundsOffset(_ boundsOffset:CGFloat, morphSize: CGSize) {
        layoutSubviews()
        
        let originalCenter = center
        
        // 前进
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
            self.frame.origin.x = boundsOffset
        }, completion: {_ in
            // 将圆角图片变成方角图片
            self.animateToSquare()
        })
        
        // 后退
        UIView.animate(withDuration: animationDuration, delay: animationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [], animations: {
            self.center = originalCenter
        }, completion: {_ in
          _ =  delay(time: 0.1) {
                if !self.isSquare {
                    self.boundsOffset(boundsOffset, morphSize: morphSize)
                }
            }
            
        })
        
        //碰撞效果
        let morphedFrame = (originalCenter.x > boundsOffset) ? CGRect(x: 0.0, y: bounds.height - morphSize.height, width: morphSize.width, height: morphSize.height) : CGRect(x: bounds.width - morphSize.width, y: bounds.height - morphSize.height, width: morphSize.width, height: morphSize.height)
        
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.duration = animationDuration
        morphAnimation.toValue = UIBezierPath(ovalIn: morphedFrame).cgPath
        morphAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        circleLayer.add(morphAnimation, forKey: nil)
        maskLayer.add(morphAnimation, forKey: nil)
    }
    
    func animateToSquare()  {
        isSquare = true
        
        let squarePath = UIBezierPath(rect: bounds).cgPath
        let morph = CABasicAnimation(keyPath: "path")
        morph.duration = 2.5
        morph.fromValue = circleLayer.path
        morph.toValue = circleLayer.path
        morph.toValue = squarePath
        
        circleLayer.add(morph, forKey: nil)
        maskLayer.add(morph, forKey: nil)
        circleLayer.path = squarePath
        maskLayer.path = squarePath
    }

}
