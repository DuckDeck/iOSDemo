
//
//  UIScrollView+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/9.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

extension UIScrollView{
    func addTopTranslucency(height:CGFloat)  {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: height))
        let ly = CAGradientLayer()
        ly.startPoint = CGPoint(x: 0.5, y: 0)
        ly.endPoint = CGPoint(x: 0.5, y: 1)
        ly.colors = [UIColor.white.cgColor,UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor]
        ly.frame = v.bounds
        v.layer.insertSublayer(ly, at: 0)
        self.addSubview(v)
    }
    
    func addBottomTranslucency(height:CGFloat)  {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: height))
        let ly = CAGradientLayer()
        ly.startPoint = CGPoint(x: 0.5, y: 0)
        ly.endPoint = CGPoint(x: 0.5, y: 1)
        ly.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,UIColor.white.cgColor]
        ly.frame = v.bounds
        v.layer.insertSublayer(ly, at: 0)
        self.addSubview(v)
    }
}
