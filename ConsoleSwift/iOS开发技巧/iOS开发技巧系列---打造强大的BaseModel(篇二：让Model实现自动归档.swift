
//
//  ViewController.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 29/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//


 /*-------------定义GrandModel

//这里不定义任何属性，所有用的属性都在子类，直接重写description
internal override var description:String{
        get{
            var dict = [String:AnyObject]()
            var count:UInt32 =  0
            let vars = class_copyIvarList(type(of: self), &count)//获取所有的字段
            for i in 0..<count {
                let t = ivar_getName((vars?[Int(i)])!)
                if let n = NSString(cString: t!, encoding: String.Encoding.utf8.rawValue) as String?
                {
                    let v = self.value(forKey: n ) ?? "nil"  //在Swift4会出错：this class is not key value coding-compliant for the key
                    //原因是因为在Swift 4中继承 NSObject 的 swift class 不再默认全部 bridge 到 OC。也就是说如果我们想要使用KVC的话我们就需要加上@objcMembers 这么一个关键字
                    dict[n] = v as AnyObject?
                }
    }
    free(vars) //释放vars
            return "\(type(of: self)):\(dict)"
    }
}

func getSelfProperty()->[String]{  //和description属性一样
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

required override init() {
}
}

//归档方法

func encode(with aCoder: NSCoder) {
        let item = type(of: self).init()
    let properties = item.getSelfProperty()
    for propertyName in properties{
            let value = self.value(forKey: propertyName)
        aCoder.encode(value, forKey: propertyName)
    }
}


//解档方法
required init?(coder aDecoder: NSCoder) {
        super.init()
    let item = type(of: self).init()
    let properties = item.getSelfProperty()
    for propertyName in properties{
            let value = aDecoder.decodeObject(forKey: propertyName)
        self.setValue(value, forKey: propertyName)
    }
}
}
*/



/*   
 
 @objcMembers class DemoArchiver:GrandModel,NSCoding {
 var demoString:String?
 var demoInt = 100
 var demoFloat:Float = 0.0
 var demoDate = Date()
 override init() { }
 
 func encode(with aCoder: NSCoder) {//归档需要实现的方法
 aCoder.encode(demoString, forKey: "demoString")
 aCoder.encode(demoInt, forKey: "demoInt")
 aCoder.encode(demoFloat, forKey: "demoFloat")
 aCoder.encode(demoDate, forKey: "demoDate")
 }
 
 @objc required init?(coder aDecoder: NSCoder) {//解档需要实现的构造器
 demoString = aDecoder.decodeObject(forKey: "demoString") as? String
 demoInt = aDecoder.decodeInteger(forKey: "demoInt")
 demoFloat = aDecoder.decodeFloat(forKey: "demoFloat")
 demoDate = aDecoder.decodeObject(forKey: "demoDate") as! Date //存在强制转换情况
 }
 }
 
 
 
 let demoTest = DemoArchiver()
 demoTest.demoString = "ABCDEFG"
 demoTest.demoFloat = 11.11
 print(demoTest)
 let a = NSKeyedArchiver.archivedData(withRootObject: demoTest)
 let b = NSKeyedUnarchiver.unarchiveObject(with: a)
 print(b)
 */
/*     -------------测试归档1
@objcMembers class demoArc:GrandModel {
    var daString:String? = "default"
    var daInt:Int = 0
}

@objcMembers class DemoArchiver:GrandModel {
    var demoString:String? = ""
    var demoInt = 0
    var demoFloat:Float = 0.0
    var demoDate = NSDate()
    var demoRect = CGRect(x: 1, y: 1, width: 1, height: 1)
    var demoClass:demoArc?
    var demoArray:[demoArc]?
    var demoDict:[String:demoArc]?
}

print(DemoArchiver().getSelfProperty())
 */
/*     -------------测试归档2
 let demoTest = DemoArchiver()
 demoTest.demoString = "ABCDEFG"
 demoTest.demoFloat = 11.11
 print(demoTest)
 let a = NSKeyedArchiver.archivedData(withRootObject: demoTest)
 let b = NSKeyedUnarchiver.unarchiveObject(with: a)
 print("------------归档后的数据------------")
 print(b)
 */
/*     -------------测试归档3
let demoTest = DemoArchiver()
demoTest.demoFloat = 11.11
demoTest.demoClass = demoArc()
demoTest.demoClass?.daInt = 8
demoTest.demoClass?.daString = "demoArc"
let a1 = demoArc()
let a2 = demoArc()
a1.daString = "a1"
a1.daInt = 1
a2.daInt = 2
a2.daString = "a2"
demoTest.demoArray = [a1,a2]
demoTest.demoDict  = ["demo1":a1,"demo2":a2]
print(demoTest)
let a = NSKeyedArchiver.archivedData(withRootObject: demoTest)
let b = NSKeyedUnarchiver.unarchiveObject(with: a)
print("------------归档后的数据------------")
print(b)
这个类没有父类,所以不需要加上override
*/
