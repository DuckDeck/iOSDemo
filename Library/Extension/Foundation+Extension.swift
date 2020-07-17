
//
//  Foundation+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import Foundation
import GrandTime
import AVKit
import CommonCrypto
//ForwardFilter从最前面开始,出现数字后一直到没有数字为止
//BackwordFilter从最后面开始,出现数字后一直到没有数字为止
//AllFilter获取所的数字
public enum FilterToInt{
    case ForwardFilter,BackwordFilter,AllFilter
}

extension NSObject{
    func addDispose()  {
        
    }
    
    func getProperty()->[String]{  //和description属性一样
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
}

extension String{
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }


    func insertString(indexs:[Int],str:String) -> String {
        assert(indexs.count > 0, "count must bigger zero")
        assert(indexs.count <= count, "count must small length")
        assert(indexs.first! >= 0, "fist element must bingger or equal zero")
        //assert(indexs.last! < length, "start must bingger zero")
        assert(count > 0,"length must bigger 0")
        var arr =  [String]()
        for c in self{
            arr.append(String(c))
        }
        var j = 0
        for i in indexs{
            if i + j > count{
                break
            }
            arr.insert(str, at: i + j)
            j += str.count
        }
        return arr.joined(separator: "")
    }
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }

    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if size.equalTo(CGSize.zero) {
            
            textSize = self.size(withAttributes: [NSAttributedString.Key.font:font])
        } else {
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            let stringRect = self.boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font:font], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }

    public func split(_ separator: String) -> [String] {
        return self.components(separatedBy: separator).filter {
            !$0.trimmed().isEmpty
        }
    }
    
    public func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    var md5:String{
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce(""){$0 + String(format:"%02x",$1)}
    }
    
    var MD5:String{
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce(""){$0 + String(format:"%02X",$1)}
    }
    
    public func hmac(key:String)->String{
        let utf8 = cString(using: .utf8)
        let keyData = key.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), keyData, strlen(keyData!), utf8, strlen(utf8!), &digest)
        return digest.reduce(""){$0 + String(format:"%02X",$1)}
    }
    
    public func filteToInt(filter:FilterToInt)->Int?{
        let enu = self.enumerated()
        var tmp = ""
       
        //用正则更好,也不一定
        for item in enu{
            if item.element.isNumber{
                tmp.append(item.element)
            }
            else{
                if tmp.last != nil && tmp.last! != "|"{
                    tmp.append("|")
                }
            }
            
        }
        let numFragment = tmp.split("|")
        if numFragment.count <= 0{
            return nil
        }
        if numFragment.count == 1{
            return numFragment[0].toInt()
        }
        switch filter {
            case .ForwardFilter:
                return numFragment.first?.toInt()
            
            case .BackwordFilter:
                return numFragment.last?.toInt()
            
            case .AllFilter:
                return numFragment.joined().toInt()
        }
       
    }
    
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
    func toUrlFileName() -> String {
        return self.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "#", with: "_").replacingOccurrences(of: "&", with: "_").replacingOccurrences(of: "?", with: "_")
    }
}

extension NSMutableAttributedString{
    func addColor(color:UIColor,range:NSRange)  {
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    func addFont(font:UIFont,range:NSRange) {
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
}

extension Array{
    
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

extension Dictionary{
    mutating func merge(newDict:Dictionary){
        for (k,v) in newDict{
            self[k] = v
        }
    }
}


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

extension CGSize{
    func ratioSize(scale:CGFloat) -> CGSize {
        return CGSize(width: scale * self.width, height: scale * self.height)
    }
}

extension CGRect {
    public init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
}

extension URL{
    func getfileSize() -> CLongLong {
        let manager = FileManager.default
        if manager.fileExists(atPath: self.path) {
            do {
                let item = try manager.attributesOfItem(atPath: self.path)
                return item[FileAttributeKey.size] as! CLongLong
            } catch {
                print("File not exist")
            }
        }
        return 0;
    }
    
    
    
    func getFileCreateTime() -> Int?{
        if let attr = try? FileManager.default.attributesOfItem(atPath: self.path){
            return DateTime.parse("\(attr[FileAttributeKey.creationDate]!)")?.timestamp
        }
        return 0
    }
    
    func getMediaDuration(mediaType:AVMediaType) -> Int {
        let assert = AVURLAsset(url: self)
        if let track = assert.tracks(withMediaType: mediaType).first {
            return Int(CMTimeGetSeconds(track.timeRange.duration))
        }
        return 0
    }

    var directory:URL? {
        get{
            if self.isFileURL{
                if self.lastPathComponent.count > 0{
                    var str = self.path
                    str.removeLast(self.lastPathComponent.count)
                    return URL(fileURLWithPath: str)
                }
            }
            return nil
        }
    }
    
    var isFlod:Bool{
        get{
            var i = ObjCBool.init(false)
            FileManager.default.fileExists(atPath: self.absoluteString, isDirectory: &i)
            return i.boolValue
        }
    }
    
    func changeSchema(targetSchema:String) -> URL? {
        var com = URLComponents(url: self, resolvingAgainstBaseURL: false)
        com?.scheme = targetSchema
        return com?.url
    }
}


extension Sequence where Element:Hashable{
    
    //如果集合中所有元素都满足要求就返回true
    public func all(matching predicate:(Element)->Bool)->Bool{
        return !contains{!predicate($0)}
    }
    //返回该集合中所有唯一的元素
    public func unique()->[Element]{
        var seen:Set<Element> = []
        return filter({ (element) -> Bool in
            if seen.contains(element){
                return false
            }
            else{
                seen.insert(element)
                return true
            }
        })
    }
}
