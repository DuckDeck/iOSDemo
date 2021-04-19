//
//  File.swift
//  
//
//  Created by chen liang on 2021/4/19.
//

import Foundation
public extension Array{
    mutating func removeWith(condition:(_ item:Element)->Bool)  {
        var index = [Int]()
        for i in 0..<self.count{
            if condition(self[i]){
                index.append(i)
            }
        }
        self.removeAtIndexs(indexs: index)
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
    
    mutating func mergeWithUnique(array:[Element],condition:((_ item:Element)->Int))  {
        let a = self.map(condition)
        let b = array.map(condition)
        var c = [Int]()
        for s in b{
            if !a.contains(s){
                c.append(s)
            }
        }
        for s in array{
            if c.contains(condition(s)){
                self.append(s)
            }
        }
    }
    
    mutating func insertItems(array:[Element],index:Int){
        if index < 0 || index > self.count{
            return
        }
        var i = index
        for item in array{
            insert(item, at: i)
            i += 1
        }
    }
    
    mutating func removeAtIndexs(indexs:[Int])  {
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
    
    func isExistRepeatElement(condition:((_ item:Element)->Int)) -> Bool {
        var m = [Int:Int]()
        let res = self.map(condition)
        for r in res {
            if !m.keys.contains(r){
                m[r] = 0
            }
            else{
                m[r] = m[r]! + 1
                return true
            }
        }
        return false
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

extension Array:JsonValue{
    public var jsonValue:String{
        //这里需要判断
        let strs = map{($0 as! DictionaryValue).value}
        let data = try? JSONSerialization.data(withJSONObject: strs, options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}
