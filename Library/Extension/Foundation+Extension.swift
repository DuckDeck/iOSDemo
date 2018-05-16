
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
    
    func getProperty()->[String]{  //和description属性一样
        var selfProperties = [String]()
        var count:UInt32 =  0
        let vars = class_copyIvarList(type(of: self), &count)
        for i in 0..<count {
            let t = ivar_getName((vars?[Int(i)])!)
            if let n = NSString(cString: t!, encoding: String.Encoding.utf8.rawValue) as String?{
                selfProperties.append(n)
            }
        }
        free(vars)
        return selfProperties
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
    
    mutating func removeWith(condition:(_ item:Element)->Bool)  {
        var index = [Int]()
        for i in 0..<self.count{
            if condition(self[i]){
                index.append(i)
            }
        }
        self.removeAdIndexs(indexs: index)
    }

    
    
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
    
    func uniqueMerge(array:[Element],condition:((_ item:Element)->Int)) -> [Element] {
        let a = self.map(condition)
        let b = array.map(condition)
        var c = [Int]()
        for s in b{
            if !a.contains(s){
                c.append(s)
            }
        }
        var tmp = self
        for s in array{
            if c.contains(condition(s)){
                tmp.append(s)
            }
        }
        return tmp
    }
}

extension Dictionary{
    mutating func merge(newDict:Dictionary){
        for (k,v) in newDict{
            self[k] = v
        }
    }
}


protocol DictionaryValue{
    var value:Any{ get }
}

protocol JsonValue:DictionaryValue {
    var jsonValue:String{get }
}

extension DictionaryValue{
    var value:Any{
        let mirror = Mirror(reflecting: self)
        var result = [String:Any]()
        for c in mirror.children{
            guard let key = c.label else {
                fatalError("Invalid key in child: \(c)")
            }
            if let v = c.value as? DictionaryValue{
                result[key] = v.value
            }
            else{
                fatalError("Invalid value in child: \(c)")
            }
        }
        return result
    }
}

extension JsonValue{
    var jsonValue:String{
        let data = try? JSONSerialization.data(withJSONObject: value as! [String:Any], options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}

extension Int:DictionaryValue{    var value: Any {        return self    }}

extension Float:DictionaryValue{    var value: Any {        return self    }}

extension String:DictionaryValue{    var value: Any {        return self    }}

extension Bool:DictionaryValue{    var value: Any {        return self    }}

extension Array:DictionaryValue{
    var value : Any{
        //这里需要判断
        return map{($0 as! DictionaryValue).value}
    }
}

extension Dictionary:DictionaryValue{
    var value : Any{
        var dict = [String:Any]()
        for (k,v) in self{
            dict[k as! String] = (v as! DictionaryValue).value
        }
        return dict
    }
}
extension Array:JsonValue{
    var jsonValue:String{
        //这里需要判断
        let strs = map{($0 as! DictionaryValue).value}
        let data = try? JSONSerialization.data(withJSONObject: strs, options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}
extension Dictionary:JsonValue{
    var jsonValue:String{
        //for normal dict ,the key always be a stribg
        //so we can do
        var dict = [String:Any]()
        for (k,v) in self{
            dict[k as! String] = (v as! DictionaryValue).value
        }
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}

extension CGSize{
    func ratioSize(scale:CGFloat) -> CGSize {
        return CGSize(width: scale * self.width, height: scale * self.height)
    }
}

extension CGRect {
    public init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
}

