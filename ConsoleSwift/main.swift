//
//  main.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 14/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
protocol DictionaryValue{
    var value:Any{ get }
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

struct Cat:Codable,DictionaryValue{
    let name:String
    let age:Int
}

let kit = Cat(name: "Kitten", age: 12)
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


extension Int:DictionaryValue{    var value: Any {        return self    }}

extension Float:DictionaryValue{    var value: Any {        return self    }}

extension String:DictionaryValue{    var value: Any {        return self    }}

extension Bool:DictionaryValue{    var value: Any {        return self    }}



struct Wizard:DictionaryValue{
    let name:String
    let cat:Cat
}
let wizard =  Wizard(name: "Hermione", cat: kit)
print(wizard.value)

/*
 extension Array:DictionaryValue where Element:DictionaryValue{
 var value:Any{
 return map($0.value)
 }
 }
 */

extension Array:DictionaryValue{
    var value : Any{
        //这里需要判断
        return map{($0 as! DictionaryValue).value}
    }
}

extension Dictionary:DictionaryValue{
    var value : Any{
        return mapValues{($0 as! DictionaryValue).value}
    }
}

struct Gryffindor:DictionaryValue{
    let wizards:[Wizard]
}

let crooks = Cat(name: "Crookshanks", age: 22)
let hermione = Wizard(name: "Hermione", cat: crooks)
let hedwig = Cat(name: "Hedwig", age: 12)
let Harry = Wizard(name: "Harry", cat: hedwig)
let graffindor = Gryffindor(wizards: [Harry,hermione])
print(graffindor.value)

//Mirror 都可以对其进行探索。强大的运行时特性，也意味着额外的开销。Mirror 的文档明确告诉我们，
//这个类型更多是用来在 Playground 和调试器中进行输出和观察用的。如果我们想要以高效的方式来处理字典转换问题，也许应该试试看其他思路
