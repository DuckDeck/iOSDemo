//
//  UIColor+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

extension UIColor{
    
    static func Hex(hexString : String) -> UIColor {
        let r, g, b: CGFloat
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16)
                    g = CGFloat((hexNumber & 0x00ff00) >> 8)
                    b = CGFloat(hexNumber & 0x0000ff)
                    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
                }
            }
        }
        return UIColor.white;
    }
    
    open class var random: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0,
                       green: CGFloat(arc4random_uniform(256))/255.0,
                       blue: CGFloat(arc4random_uniform(256))/255.0,
                       alpha: 1.0)
    }
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
    
    public convenience init(gray: CGFloat, alpha: CGFloat = 1) {
        self.init(red: gray/255, green: gray/255, blue: gray/255, alpha: alpha)
    }
    
    public var redComponent: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }
    
    public var greenComponent: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }
    
    public var blueComponent: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }
    
    public var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }

}


extension UIColor{
    static var pink:UIColor{
        get{
            return UIColor.init(red: 1, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1)
        }
    }
    static var silver:UIColor{
        get{
            return UIColor.init(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1)
        }
    }
}
