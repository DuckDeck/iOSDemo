
//
//  Foundation+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

extension NSObject{
    func addDispose()  {
        
    }
}

extension String{
    func sub(start:Int,length:Int) ->String {
        let len = (self as NSString).length
        assert(start >= 0, "start must bingger zero")
        assert(start < len, "start must small  length")
        assert(length > 0, "length must bigger zero")
        assert(length <= len, "length must small this length ")
        let st = self.index(self.startIndex, offsetBy: start)
        let end = self.index(self.endIndex,offsetBy: start + length - len)
        return self.substring(with: st..<end)
    }
    
    func subRange(start:Int,end:Int) ->String {
        let len = (self as NSString).length
        assert(start >= 0, "start must bingger zero")
        assert(start < len, "start must small  length")
        assert(end > start, "length must bigger start")
        assert(end < len, "length must small this length ")
        return  sub(start: start, length: end - start)
    }
    
    func subToEnd(start:Int) -> String {
        let len = (self as NSString).length
        assert(start >= 0, "start must bingger zero")
        assert(start < len, "start must small  length")
        return subRange(start: start, end: len - 1)
    }

    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    
}

extension Array{
    mutating func exchangeObjectAdIndex(IndexA:Int,atIndexB:Int)
    {
        if IndexA >= self.count || IndexA < 0{
            return
        }
        if atIndexB >= self.count || atIndexB < 0{
            return
        }
        let objA = self[IndexA]
        let objB = self[atIndexB]
        self.replaceObject(obj: objA, adIndex: atIndexB)
        self.replaceObject(obj: objB, adIndex: IndexA)
    }
    
    mutating func replaceObject(obj:Element,adIndex:Int){
        if adIndex >= self.count || adIndex < 0{
            return
        }
        self.remove(at: adIndex)
        self.insert(obj, at: adIndex)
    }
    
    mutating func merge(newArray:Array){
        for obj in newArray
        {
            self.append(obj)
        }
    }
    
    
    mutating func removeAdIndexs(indexs:[Int])  {
        if indexs.count <= 0{
            return
        }
        if indexs.first! < 0 {
            return
        }
        if indexs.last! > self.count{
            return
        }
        let sortedIndex =  indexs.sorted()
        var s = 0
        
        for i in sortedIndex{
            self.remove(at: i - s)
            s = s + 1
        }
    }
}

extension Dictionary{
    mutating func merge(newDict:Dictionary){
        for (k,v) in newDict{
            self[k] = v
        }
    }
}

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
}


