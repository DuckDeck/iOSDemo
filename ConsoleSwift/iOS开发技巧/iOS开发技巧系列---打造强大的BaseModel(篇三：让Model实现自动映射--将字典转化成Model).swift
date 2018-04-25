//
//  iOS开发技巧系列---打造强大的BaseModel(篇三：让Model实现自动映射--将字典转化成Model).swift
//  ConsoleSwift
//
//  Created by Stan Hu on 30/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

//-------------定义MapAble-------------

/*
protocol MapAble{                         //定义一个协议，可以将一个Any转化为自己
    static func mapModel(obj:Any)->Self  //将一个字典转化成自己
}

class GrandModel:NSObject {
    class var selfMapDescription:[String:String]?{   //这是一个映射表。
        return nil
    }
    
    internal override var description:String{
        get{
            var dict = [String:AnyObject]()
            var count:UInt32 =  0
            let vars = class_copyIvarList(type(of: self), &count)
            for i in 0..<count {
                let t = ivar_getName((vars?[Int(i)])!)
                if let n = NSString(cString: t!, encoding: String.Encoding.utf8.rawValue) as String?
                {
                    let v = self.value(forKey: n ) ?? "nil"
                    dict[n] = v as AnyObject?
                }
            }
            free(vars)
            return "\(type(of: self)):\(dict)"
        }
    }
    
    required override init() {
        super.init()
    }
}


extension GrandModel:MapAble{
    static func mapModel(obj:Any)->Self{
        let model = self.init()
        if let mapTable = self.selfMapDescription{  //取出映射表的数据
            if let dict = obj as? [String:Any]      //如果被转化的对像可以正确地转成字典
            {
                for item in dict{
                    if let key = mapTable[item.0]{  //将字典的数据取出来一个一个地再转化成对应的值
                        print("key 为\(item.0)将要被设成\(mapTable[item.0] ?? ""),其值是 \(item.1)")
                        model.setValue(item.1, forKey: key)
                    }
                }
            }
        }
        return model
    }
}
*/

/*
 @objcMembers class DemoClass:GrandModel {
 var name:String?
 var age:Int = 0
 var grade:Int = 0
 //需要重写selfMapDescription
 //    override static var selfMapDescription:[String:String]?{
 //        return ["sName":"name","iAge":"age","iGrade":"grade"]
 //    }
 override static var selfMapDescription:[String:String]?{
 return["sName":"name","iAge":"age","iGrade":"grade","UserName":"userName","sUserName":"userName","userName":"userName"]//将这个三属性名全部映射到userName
 }
 }
 
 let demoDict = ["sName":"Stan","iAge":"12","iGrade":"6"]
 var demo = DemoClass()
 demo = DemoClass.mapModel(obj: demoDict)
 print(demo)
 
 */

//-------------测试功能-------------
/*
@objcMembers class DemoOther: GrandModel {
    var userName:String?
    override static var selfMapDescription:[String:String]?{
        return [ "userName":"userName"]
    }
}

@objcMembers class DemoClass:GrandModel {
    var name:String?
    var age:Int = 0
    var grade:Int = 0
    var userName:String?
    var otherClass:DemoOther?
    var otherClasses:[DemoOther]?
    //需要重写selfMapDescription
    override static var selfMapDescription:[String:String]?{
        return ["sName":"name",
                "iAge":"age",
                "iGrade":"grade",
                "UserName":"userName",
                "sUserName":"userName",
                "userName":"userName",
                "DemoOther":"otherClass",
                "DemoOthers":"otherClasses"]
    }
}

let demoDict:[String : Any] = ["sName":"Stan","iAge":"12","iGrade":"6","UserName":"userName","DemoOther":["userName":"IMOtherUserName"],"DemoOthers":[["userName":"OtherUserName1"],["userName":"OtherUserName2"]]]

let test = DemoClass.mapModel(obj: demoDict)
print(test)
print("------------------print otherClass---------------------")
print(test.otherClass)
 */
