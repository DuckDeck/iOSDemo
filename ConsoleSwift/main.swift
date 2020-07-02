//
//  main.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 14/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
import ObjectiveC


let sss = [1,2,3,4,5,1,2,1,2]
for a in sss{
    print(a)
}
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

/*
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


class Delegate<Input,Output>{
    private var block:((Input)->Output?)?
    func delegate<T:AnyObject>(on target: T,block:((T,Input)->Output)?){
        self.block = {[weak target] input in
            guard let target = target  else {
                return nil
            }
            return block?(target,input)
        }
    }
    
    func call(_ input : Input)->Output{
        return (block?(input))!
    }
}


*/

enum VendingMachineType {
    case InvalidGoods//!< 商品无效
    case StockInsufficient//!< 库存不足
    case CoinInsufficient(coinNeeded:Int,caseDes:String)
}

let enumArray = [VendingMachineType.CoinInsufficient(coinNeeded: 4, caseDes: "自动售货机，硬币不足，请补充"),
                 .InvalidGoods,
                 .StockInsufficient,
                 .CoinInsufficient(coinNeeded: 6, caseDes: "自动售货机，硬币不足，超过限额")]
for patternCase in enumArray {
    switch patternCase {
    case .CoinInsufficient(coinNeeded: let x, caseDes: let y) where x > 5:
        print("这个是过了5个的")
        print(x,y)
    case let .CoinInsufficient(coinNeeded: x, caseDes: y):
        print(x,y)
    case .InvalidGoods:
        print("商品无效")
    default:
        print("未匹配到")
    }
}

enum SomeEnum { case left, right,top,down}
let array : Array<SomeEnum?> = [.left,nil,.right,.top,.down]



array.forEach { (item) in
    switch item {
    case .left?:
        print("左")
    case SomeEnum.right?:
        print("右")
    case .down?:
        print("下")
    case .top?:
        print("上")
    default:
        print("没有值")
    }
}

array.forEach { (item) in
    switch item {
    case .some(let x):
        print("对可选项item进行解包得到:\(x)")//!< left,right,top,down
    case .none:
        print("没有值") //nil
    }
}
let point = (9,14)
switch point {
case (9,14):
    print("表达式模式使用`~=`精准匹配::(\(point.0),\(point.1))")
    fallthrough //我以为是不执行后面的，没想到是要继续执行
case (5..<10,0...20):
    print("表达式模式使用`~=`范围匹配:(\(point.0),\(point.1))")
default:
    print("未匹配")
}




func ~= (pattern: String, value: Int) -> Bool {
    return pattern == "\(value)"
}

switch point {
case ("9","14")://若不重载则会报错
    print("表达式模式使用`~=`精准匹配:(\(point.0),\(point.1))")
   
case (5..<10,0...20):
    print("表达式模式使用`~=`范围匹配:(\(point.0),\(point.1))")
default:
    print("未匹配")
}
class Cat {
    func hairColor() -> String {
        return "五颜六色"
    }
}
class WhiteCat: Cat {
    override func hairColor() -> String {
        return "白色"
    }
}
class BlackCat: Cat {
    override func hairColor() -> String {
        return "黑色"
    }
}

var things : [Any] = [0, 0.0, 42, 3.14159, "hello", (3.0, 5.0),
                      WhiteCat(),{ (name: String) -> String in "Hello, \(name)" } ]
for thing in things {
    switch thing {
    case 0 as Int:
        print("`as`模式匹配两部分，pattern:表达式模式(`0`)，type:匹配类型(`Int`),匹配结果：0")
    case (0) as Double:
        print("`as`模式匹配两部分，pattern:表达式模式(`0`)，type:匹配类型(`Double`),匹配结果：0.0")
    case is Double:
        print("`is`模式匹配`Double`类型的值，值类型与`is`右侧类型及子类相同时，执行此句")
    case let someInt as Int:
        print("`as`模式匹配两部分，pattern:值绑定模式(`let someInt`)，type:匹配类型(`Int`),匹配结果：\(someInt)")
    case _ as Int:
        print("`as`模式匹配两部分，pattern:通配符模式(`_`)，type:匹配类型(`Int`),匹配结果被忽略")
    case let someDouble as Double where someDouble > 0:
        print("`as`模式匹配两部分，pattern:值绑定模式(`let someDouble`)，type:匹配类型(`Double`),匹配结果：\(someDouble)")
    case let someString as String:
        print("`as`模式匹配两部分，pattern:值绑定模式(`let someString`)，type:匹配类型(`String`),匹配结果：\(someString)")
    case let (x, y) as (Double, Double):
        print("`as`模式匹配两部分，pattern:元组模式(`let (x, y) `)，type:匹配类型(元组`(Double, Double)`),匹配结果：\((x, y))")
        fallthrough
    case (2.0...4.0, 3.0...6.0) as (Double, Double):
        print("`as`模式匹配两部分，pattern:表达式模式(`(2.0...4.0, 3.0...6.0) `)，type:匹配类型(元组`(Double, Double)`))")
    case let cat as WhiteCat:
        print("`as`模式匹配两部分，pattern:值绑定模式(`let cat`)，type:匹配类型(对象`WhiteCat`),匹配结果：\(cat)")
    case let sayHelloFunc as (String) -> String:
        print("`as`模式匹配两部分，pattern:值绑定模式(`let sayHelloFunc`)，type:匹配类型(函数`(String) -> String`),匹配结果：\(sayHelloFunc("QiShare"))")
    default:
        print("其他结果，未匹配到")
    }
}
