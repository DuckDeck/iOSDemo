//
//  GrandType.swift
//  GrandModelDemo
//
//  Created by HuStan on 5/15/16.
//  Copyright © 2016 StanHu. All rights reserved.
//


import Foundation

class GrandType {
    
    var typeName: String!
    
    var typeClass: Any.Type!
    
    var displayStyle: Mirror.DisplayStyle!
    
    var displayStyleDesc: String!
    
    var belongType: Any.Type!
    
    var isOptional: Bool = false
    
    var isArray: Bool = false
    
    var isReflect:Bool = false
    
    var realType: RealType = .None
    
    fileprivate var propertyMirrorType: Mirror
    
    init(propertyMirrorType: Mirror, belongType: Any.Type){
        
        self.propertyMirrorType = propertyMirrorType
        
        self.belongType = belongType
        
        parseBegin()
    }
}


extension GrandType{
    
    func parseBegin(){
        
        parseTypeName()
        
        parseTypeClass()
        
        parseTypedisplayStyle()
        
        parseTypedisplayStyleDesc()
    }
    
    func parseTypeName(){
        
        typeName = "\(propertyMirrorType.subjectType)".deleteSpecialStr()
    }
    
    func parseTypeClass(){
        typeClass = propertyMirrorType.subjectType
    }
    
    func parseTypedisplayStyle(){
        
        displayStyle = propertyMirrorType.displayStyle
        
        if displayStyle == nil && basicTypes.contains(typeName) {displayStyle = .struct}
        
        if extraTypes.contains(typeName) {displayStyle = .struct}
        
        //        guard displayStyle != nil else {fatalError("[Charlin Feng]: DisplayStyle Must Have Value")}
    }
    
    func parseTypedisplayStyleDesc(){
        
        if displayStyle == nil {return}
        
        switch displayStyle! {
            
        case .struct: displayStyleDesc = "Struct"
        case .class: displayStyleDesc = "Class"
        case .optional: displayStyleDesc = "Optional"; isOptional = true;
        case .enum: displayStyleDesc = "Enum"
        case .tuple: displayStyleDesc = "Tuple"
        default: displayStyleDesc = "Other: Collection/Dictionary/Set"
            
        }
        fetchRealType()
    }
}



extension GrandType{
    
    enum BasicType: String{
        
        case String
        case Int
        case Float
        case Double
        case Bool
        case NSNumber
    }
    
    
    enum RealType: String{
        
        case None = "None"
        case Int = "Int"
        case Float = "Float"
        case Double = "Double"
        case String = "String"
        case Bool = "Bool"
        case Class = "Class"
    }
}




extension GrandType{
    
    var basicTypes: [String] {return ["String", "Int", "Float", "Double", "Bool"]}
    var extraTypes: [String] {return ["__NSCFNumber", "_NSContiguousString", "NSTaggedPointerString"]}
    var sdkTypes: [String] {return ["__NSCFNumber", "NSNumber", "_NSContiguousString", "UIImage", "_NSZeroData"]}
    
    var aggregateTypes: [String: Any.Type] {return ["String": String.self, "Int": Int.self, "Float": Float.self, "Double": Double.self, "Bool": Bool.self, "NSNumber": NSNumber.self]}
    
    func fetchRealType(){
        
        if typeName.contain(subStr: "Array") {isArray = true}
        if typeName.contain(subStr: "Int") {realType = RealType.Int}
        else if typeName.contain(subStr: "Float") {realType = RealType.Float}
        else if typeName.contain(subStr: "Double") {realType = RealType.Double}
        else if typeName.contain(subStr: "String") {realType = RealType.String}
        else if typeName.contain(subStr: "Bool") {realType = RealType.Bool}
        else {realType = RealType.Class}
        
        if .Class == realType && !sdkTypes.contains(typeName) {
            
            isReflect = true
        }
    }
    
    class func makeClass(_ type: GrandType) -> AnyClass {
        
        let arrayString = type.typeName
        
        let clsString = arrayString?.replacingOccurrencesOfString("Array<", withString: "").replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
        
        var cls: AnyClass? = ClassFromString(clsString!)
        
        if cls == nil && type.isReflect {
            
            let nameSpaceString = "\(String(describing: type.belongType)).\(String(describing: clsString))"
            
            cls = ClassFromString(nameSpaceString)
        }
        
        return cls!
    }
    
    func isAggregate() -> Any!{
        
        var res: Any! = nil
        
        for (typeStr, type) in aggregateTypes {
            
            if typeName.contain(subStr: typeStr) {res = type}
        }
        
        return res
    }
    
    func check() -> Bool{
        
        if isArray {return true}
        
        return self.realType != RealType.Int && self.realType != RealType.Float && self.realType != RealType.Double
    }
}



extension String{
    
    func contain(subStr: String) -> Bool {return (self as NSString).range(of: subStr).length > 0}
    
    func explode (_ separator: Character) -> [String] {
        return self.split(whereSeparator: { (element: Character) -> Bool in
            return element == separator
        }).map { String($0) }
    }
    
    func replacingOccurrencesOfString(_ target: String, withString: String) -> String{
        return (self as NSString).replacingOccurrences(of: target, with: withString)
    }
    
    func deleteSpecialStr()->String{
        
        return self.replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
    }
    
    var floatValue: Float? {return NumberFormatter().number(from: self)?.floatValue}
    var doubleValue: Double? {return NumberFormatter().number(from: self)?.doubleValue}
    
    func repeatTimes(_ times: Int) -> String{
        
        var strM = ""
        
        for _ in 0..<times {
            strM += self
        }
        
        return strM
    }
}


func ClassFromString(_ str: String) -> AnyClass!{
    
    if  var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
        
        if appName == "" {appName = ((Bundle.main.bundleIdentifier!).split{$0 == "."}.map { String($0) }).last ?? ""}
        
        var clsStr = str
        
        if !str.contain(subStr: "\(appName)."){
            clsStr = appName + "." + str
        }
        
        let strArr = clsStr.explode(".")
        
        var className = ""
        
        let num = strArr.count
        
        if num > 2 || strArr.contains(appName) {
            
            var nameStringM = "_TtC" + "C".repeatTimes(num - 2)
            
            for (_, s): (Int, String) in strArr.enumerated(){
                
                nameStringM += "\(s.count)\(s)"
            }
            
            className = nameStringM
            
        }else{
            
            className = clsStr
        }
        
        return NSClassFromString(className)
    }
    
    return nil;
}
