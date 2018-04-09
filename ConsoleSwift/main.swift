//
//  main.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 14/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
import ObjectiveC
/*
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


struct Cat:Codable,JsonValue{
    let name:String
    let age:Int
}

let kit = Cat(name: "Kitten", age: 12)
let js = kit.jsonValue
print(js)

let  encoder = JSONEncoder()
do{
    let data = try encoder.encode(kit)
    let dict = try JSONSerialization.jsonObject(with: data, options: [])
    print(dict)
}
catch{
    print(error)
}




let mirror = Mirror(reflecting: kit)
for c in mirror.children{
    print("\(c.label!) - \(c.value)")
}

struct Wizard:JsonValue{
    let name:String
    let cat:Cat
}
let wizard =  Wizard(name: "Hermione", cat: kit)
print(wizard.value)
print(wizard.jsonValue)
/*
 extension Array:DictionaryValue where Element:DictionaryValue{
 var value:Any{
 return map($0.value)
 }
 }
 */
//在swift4 里面，我作们可以用约束来。这城用强转会出错的


struct Gryffindor:JsonValue{
    let wizards:[Wizard]
}

let crooks = Cat(name: "Crookshanks", age: 22)
let hermione = Wizard(name: "Hermione", cat: crooks)
let hedwig = Cat(name: "Hedwig", age: 12)
let Harry = Wizard(name: "Harry", cat: hedwig)
let graffindor = Gryffindor(wizards: [Harry,hermione])
print(graffindor.value)
print(graffindor.jsonValue)
//Mirror 都可以对其进行探索。强大的运行时特性，也意味着额外的开销。Mirror 的文档明确告诉我们，
//这个类型更多是用来在 Playground 和调试器中进行输出和观察用的。如果我们想要以高效的方式来处理字典转换问题，也许应该试试看其他思路


let test1 = ["test1":hedwig,"test2":Harry] as [String : Any]
let test1Dict = test1.value
print(test1Dict)
print(test1.jsonValue)
*/



protocol Drive{
    func run()
}


public  class Tire{ //轮胎
    var brand:String? //品牌
    var size:Float = 0 //大小
}

public class Vehicle:Drive{
    var carType:String?
    var tires:[Tire]?
    var host:String?// 主人
    var brand:String?//汽车品牌
    func run() {
        if let h = host{
            print("\(h)Drive a \(brand) \(carType) car run")
        }
        else{
            print("this car is not selled")
        }
    }
}

public class Trunk:Vehicle{
    public var packintBox:String?
}

public struct TranGroup{ //货运集团
    var trunks = {
        return [Trunk]()
    }()
    
    var country:String?
    var turnover:Float?
}

//一个中国的货运集团
var tranGroup = TranGroup()

tranGroup.country = "天朝"
tranGroup.turnover = 2222
let trunk1 = Trunk()
trunk1.brand = "MAN"
trunk1.host = "Stan"
trunk1.packintBox = "Big And Long"
tranGroup.trunks.append(trunk1)
let mirrorTran = Mirror(reflecting: tranGroup)
print(tranGroup) //打印出  Mirror for TranGroup
print(mirrorTran.subjectType) //打印出  TranGroup
print(mirrorTran.displayStyle) //Optional(Swift.Mirror.DisplayStyle.Struct)，是个Struct类型
print(mirrorTran.superclassMirror) //nil，因为没有父类
for (key,value) in mirrorTran.children{
    print("\(key) : \(value)")
}
