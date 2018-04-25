//
//  #iOS开发技巧系列---打造强大的BaseModel(篇四：使用Swift反射).swift
//  ConsoleSwift
//
//  Created by Stan Hu on 09/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

/*
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
print(tranGroup) //打印出   TranGroup 相关信息
print(mirrorTran.subjectType) //打印出  TranGroup
print(mirrorTran.displayStyle) //Optional(Swift.Mirror.DisplayStyle.Struct)，是个Struct类型
print(mirrorTran.superclassMirror) //nil，因为没有父类
for (key,value) in mirrorTran.children{
    print("\(key) : \(value)")
}


extension Mirror{
    func printMirror(){
        print("mirror:\(self) type:\(self.subjectType) displayStyle \(self.displayStyle) superClassMirror \(self.superclassMirror) ")
        for (key,value) in self.children{
            print("\(key) : \(value)")
        }
    }
}


var s = {(i:Int) -> Int in  return i + i }
let mir = Mirror(reflecting: s)
mir.printMirror()
typealias item = (key:String,value:Any)
let a:item = ("111",222)
let mirty = Mirror(reflecting: a)
mirty.printMirror()
Mirror(reflecting: "1").printMirror()
Mirror(reflecting: 1.1).printMirror()
Mirror(reflecting: NSData()).printMirror()
Mirror(reflecting: NSNull()).printMirror()
enum week:Int{
    case Mon = 1,Thu,Wed,Tur,Fri,Sat,Sun
}
Mirror(reflecting: week.Fri).printMirror()

*/

/*
 class GrandModel: NSObject {
 func getSelfProperty()->[String]{
 var dict = [String:Any]()
 
 let mir = Mirror(reflecting: self)
 for (key,value) in mir.children{
 dict[key!] = value
 }
 return ["\(type(of: self)):\(dict)"]
 }
 
 required override init() {
 }
 
 }
 
 class DemoClass: GrandModel {
 var demoString:String? = ""
 var demoInt = 0
 var demoFloat:Float = 0.0
 var demoDate = NSDate()
 var demoRect = CGRect(x: 1, y: 1, width: 1, height: 1)
 var demoSelf:DemoClass?
 }
 
 let demo = DemoClass()
 demo.demoString = "this is a test"
 let demo2 = DemoClass()
 demo2.demoString = "this is a test2test2test2test2test2test2"
 demo.demoSelf = demo2
 print(demo.getSelfProperty())
 */
