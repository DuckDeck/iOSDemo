//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/4.
//
import UIKit

public extension UIScrollView{
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
