
//
//  Foundation+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import Foundation

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
}

extension Dictionary{
    mutating func merge(newDict:Dictionary){
        for (k,v) in newDict{
            self[k] = v
        }
    }
}


