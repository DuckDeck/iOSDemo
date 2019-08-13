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


/*
let test = [23,112,3,4,5]
for x in test.dropLast(){  //不要最后一个
    print(x)
}

for x in test.dropFirst(){  //不要第一个
    print(x)
}
for x in test.dropLast(3){
    print(x)
}

for (index,value) in test.enumerated(){//这样就有了index
    print("\(index) : \(value)")
}
*/
//“想要寻找一个指定元素的位置” 这个index真没有


let k = (1..<20).map{$0*$0}.filter{$0%2==0}
print(k)


let testdict = ["a":"123","v":"123","b":"123","n":"123",]
let res = testdict.mapValues { (s) -> String in
    return s + "123123"
}
print(res)

var testdict1 = testdict

print(testdict as NSDictionary == testdict1 as NSDictionary)
print(testdict1)
testdict1["a"] = "aaa123"
print(testdict1)
print(testdict1.hashValue == testdict.hashValue)


let txt = "知识小集是由几位志同道合的伙伴组成。你了解这个团队吗？我们在一起相处了 1 年多的时光！我想说：“我们是最棒的！”"
let sss = txt.count

extension String {
    func toRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
}

let t = txt.toRange(NSRange(location: 0, length: sss))

txt.enumerateSubstrings(in: t!, options: String.EnumerationOptions.bySentences) { (str, r1, r2, stop) in
    print("sentence\(str)")
}




RegexTest.testRegex1()
RegexTest.testRegex2()
RegexTest.testRegex3()
RegexTest.testRegex4()
RegexTest.testRegex5()

//ThreadTest.ThreadName1()
ThreadTest.ThreadName2()
