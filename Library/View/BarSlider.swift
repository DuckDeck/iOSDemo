//
//  BarSlider.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/6/21.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class BarSlider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    }

    
    override var value: Float{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(maximumTrackTintColor?.cgColor ?? UIColor.clear.cgColor)
        ctx?.fill(rect)
        ctx?.setFillColor(minimumTrackTintColor?.cgColor ?? tintColor.cgColor)
        let width = CGFloat(value / maximumValue) * rect.size.width
        ctx?.fill(CGRect(x: 0, y: 0, w: width, h: rect.size.height))
    }
   
}
