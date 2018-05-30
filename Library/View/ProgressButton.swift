//
//  ProgressButton.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/30.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
class ProgressButton: UIButton {
    
    var maxValue:Double = 1
    var minValue:Double = 0
    
    var value:Double = 0{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var bgTintColor = UIColor.lightGray{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        context.setStrokeColor(bgTintColor.cgColor)
        context.setLineWidth(5)
        context.strokeEllipse(in: rect)
        context.setStrokeColor(tintColor.cgColor)
        if value < (maxValue - minValue) / 4{
            context.addArc(center: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2), radius: rect.size.width / 2, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi * 2 * value / (maxValue - minValue)), clockwise: true)
        }
        
        context.strokePath()
        
    }
    
}
