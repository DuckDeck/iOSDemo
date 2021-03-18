//
//  File.swift
//  
//
//  Created by chen liang on 2021/3/17.
//

import UIKit

fileprivate let StartAngle = CGFloat(Double.pi / 2)

public struct CircleConfig{
    var circleFillColor = UIColor.blue
    var circleBackgroundColor = UIColor.gray
    var textColor = UIColor.blue
}

public class CircleProgressView:UIView{
    private lazy var bgLayer = CAShapeLayer()
    
    private lazy var progressLayer = CAShapeLayer()
    
    public var progress = 0.0{
        didSet{
            if progress > 1 || progress < 0 {
                return
            }
            lblTitle.text = "\(progress)"
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.1
            animation.fromValue = 0
            animation.toValue = 1
            progressLayer.add(animation, forKey: nil)
        }
    }
    
    private lazy var lblTitle = UILabel()
    
    private var config = CircleConfig()
    
    public var circleConfig:CircleConfig?{
        didSet{
            if let c = circleConfig{
                config = c
                setNeedsDisplay()
            }
           
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func initView(){
        bgLayer.fillColor = config.circleBackgroundColor.cgColor
        layer.addSublayer(bgLayer)
        
        progressLayer.fillColor = nil
        progressLayer.strokeColor = config.circleFillColor.cgColor
        progressLayer.lineWidth = 4
        layer.addSublayer(progressLayer)
        
        lblTitle.textColor = config.textColor
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lblTitle)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = bounds.height / 2
        bgLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        
        let end = CGFloat(Double.pi * 2 * progress) - StartAngle
        progressLayer.path = UIBezierPath(arcCenter: CGPoint(rect: bounds), radius: radius, startAngle: -StartAngle, endAngle: end, clockwise: true).cgPath
        NSLayoutConstraint.activate([lblTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor),lblTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
    }
}

extension CGPoint{
    init(rect:CGRect) {
        self.init(x: rect.width / 2, y: rect.height / 2)
    }
}


















