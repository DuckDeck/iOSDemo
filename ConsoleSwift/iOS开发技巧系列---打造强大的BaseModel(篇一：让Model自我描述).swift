//
//  ViewController.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 29/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//



//将代码放在main.swift就可以运行

//--------------------iOS开发技巧系列---打造强大的BaseModel(篇一：让Model自我描述)


/* -------------打印实例类
 class demoClass{ //定义一个demoClass对象
 var a = 1
 var b = "demo"
 }
 print(demoClass())  //打印出来
 class demoClassFromNSObject:NSObject{ //定义一个demoClassFromNSObject对象
 var a = 1
 var b = "demo"
 }
 print(demoClassFromNSObject())  //打印出来
 */

/*   -------------重写description
 class demoClass{
 var demoId:Int = 0
 var demoName:String?
 }
 //实现协议可以在Extension里进行
 extension demoClass:CustomStringConvertible{
 var description:String{        //重写description,注意,因为这个类没有父类,所以不需要加上override
 return "DemoClass: demoId:\(demoId) demoName:\(demoName ?? "nil")"
 }
 }
 extension demoClass:CustomDebugStringConvertible{
 var debugDescription:String{
 return self.description
 }
 }
 
 let demo1 = demoClass()
 print(demo1) //DemoClass: demoId:0 demoName:nil
 demo1.demoName = "this is a demo"
 print(demo1)  //DemoClass: demoId:0 demoName:this is a demo
 
 
 class DemoClassA: NSObject {
 var demoId:Int = 0
 var demoName:String?
 override var description:String{
 return "DemoClassA: demoId:\(demoId) demoName:\(demoName ?? "nil")"
 }
 }
 let demo2 = DemoClassA()
 demo2.demoName = "DemoClassA"
 print(demo2)
 */


/*  -------------定义GrandModel

enum week{
    case Mon,Thu,Wed,Tur,Fri,Sai,Sun
}
 
class GrandModel:NSObject{
    //这里不定义任何属性，所有用的属性都在子类，直接重写description
    internal override var description:String{
        get{
            var dict = [String:AnyObject]()
            var count:UInt32 =  0
            let vars = class_copyIvarList(type(of: self), &count)
            for i in 0..<count {
                let t = ivar_getName((vars?[Int(i)])!)
                if let n = NSString(cString: t!, encoding: String.Encoding.utf8.rawValue) as String?
                {
                    let v = self.value(forKey: n ) ?? "nil"  //在Swift4会出错：this class is not key value coding-compliant for the key
                    //原因是因为在Swift 4中继承 NSObject 的 swift class 不再默认全部 bridge 到 OC。也就是说如果我们想要使用KVC的话我们就需要加上@objcMembers 这么一个关键字
                    dict[n] = v as AnyObject?
                }
            }
            free(vars)
            return "\(type(of: self)):\(dict)"
        }
    }
}
*/

/*   -------------测试GrandModel
 @objcMembers class TestModel: GrandModel {
 var j:Int? = 0
 var i = 0
 var a:String?
 var weeb:week?
 }
 let model = TestModel()
 print(model)
 */

/*  -------------测试复杂类
struct StructDemo {
    var q = 1
    var w = "w"
}
class ClassDemo {
    var q = 1
    var w = "w"
}
@objcMembers class ClassDemoA:GrandModel{
    var q = 1
    var w = "w"
}
@objcMembers class TestModelA: GrandModel {
    var i:Int = 1
    var o:String?
    //var structDemo:StructDemo?
    //var classDemo:ClassDemo?
    var classDemoA:ClassDemoA?
    var classDemoAArray:[ClassDemoA]?
    var classDemoDict:[String:ClassDemoA]?
}
let modelA = TestModelA()
modelA.classDemoAArray = [ClassDemoA]()
modelA.classDemoAArray?.append(ClassDemoA())
modelA.classDemoAArray?.append(ClassDemoA())
modelA.classDemoDict = [String:ClassDemoA]()
modelA.classDemoDict!["1"] = ClassDemoA()
modelA.classDemoDict!["2"] = ClassDemoA()
print(modelA)
*/
/* 打印纟土日木
 TestModelA:["classDemoA": nil, "o": nil, "i": 1, "classDemoDict": {
 1 = "ClassDemoA:[\"q\": 1, \"w\": w]";
 2 = "ClassDemoA:[\"q\": 1, \"w\": w]";
 }, "classDemoAArray": <_TtGCs23_ContiguousArrayStorageC12ConsoleSwift10ClassDemoA_ 0x101a80bc0>(
 ClassDemoA:["q": 1, "w": w],
 ClassDemoA:["q": 1, "w": w]
 )
 ]
 */

