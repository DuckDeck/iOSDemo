//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/5.
//

import UIKit
import AVKit
import CommonCrypto
import GrandTime
public enum FilterToInt{
    case ForwardFilter,BackwordFilter,AllFilter
}
public enum NumOperate:String{
    case Add = "+",Minus = "-",Multiply = "x", Devided = "/"
    public init?(rawValue: String) {
        switch rawValue {
        case "+": self = .Add
        case "-":self = .Minus
        case "x":self = .Multiply
        case "*":self = .Multiply
        case "/":self = .Devided
        case "%":self = .Devided
        default:
            return nil
        }
    }
}
public extension NSObject{
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

public extension String{
    
    func index(str:Character) -> Int {
        let index = self.firstIndex(of: str)
        if index == nil {
            return -1
        }
        return self.distance(from: startIndex, to: index!)
    }
    
    func replaceRange(start:Int,end:Int,str:String) -> String {
        let s = substring(from: start, to: end)
        return replacingOccurrences(of: s, with: str)
    }
    
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
    
   
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
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

    func split(_ separator: String) -> [String] {
        return self.components(separatedBy: separator).filter {
            !$0.trimmed().isEmpty
        }
    }
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    func toDecimal() -> Decimal?  {
        if let dou = toDouble(){
            return Decimal(dou)
        }
        return nil
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
    
    func hmac(key:String)->String{
        let utf8 = cString(using: .utf8)
        let keyData = key.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgMD5), keyData, strlen(keyData!), utf8, strlen(utf8!), &digest)
        return digest.reduce(""){$0 + String(format:"%02X",$1)}
    }
    
    func filteToInt(filter:FilterToInt)->Int?{
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
    
    
    func getNumbers() -> [NSNumber] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let charset = CharacterSet.init(charactersIn: " ,.")
        return matches(for: "[+-]?([0-9]+([., ][0-9]*)*|[.][0-9]+)").compactMap { string in
            return formatter.number(from: string.trimmingCharacters(in: charset))
        }
    }

    // https://stackoverflow.com/a/54900097/4488252
    func matches(for regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: self) else { return nil }
            return String(self[range])
        }
    }
    

    //g4-g+5/4
    //判断这和串前面那部分是不是数字操作
    func numOperatePart() -> ([Double],[NumOperate])? {
        if !(self.last?.isNumber ?? false){ //最后一位不是数字
            return nil
        }
        let chars = Array(self)
        var nums = [Double]()
        var opera = [NumOperate]()
        var tmp = [String]()
        var previous:Element?
        for item in chars.enumerated().reversed() {
            if item.element.isNumber || item.element == "." {
                tmp.insert(String(item.element), at: 0)
            }
            else if let _ = NumOperate(rawValue: String(item.element)) {
                if previous != nil && previous!.isNumber {
                    tmp.insert(String(item.element), at: 0)
                }
                else if previous != nil && NumOperate(rawValue: String(previous!)) != nil {
                    tmp.removeFirst()
                    break
                }
            }
            else{
                if previous != nil && NumOperate(rawValue: String(previous!)) != nil {
                    tmp.removeFirst()
                    break
                }
                else{
                    break
                }
                
            }
            previous = item.element
        }
        //判断特殊情况
        if tmp.count < 3 {
            return nil
        }
        if tmp.first! == "."{
           tmp.removeFirst()
        }
        if tmp.last! == "."{
            return nil
        }
        var numTmp =  ""
        //下面要重构，这个特难处理，先不处理，比如这样的会出错 4.5.5+5.6.4+4.3.2,先不用管了
        var arrNumTmp = [String]()
        
        
        
        for item in tmp.enumerated()  {
            
            if  item.element.toInt() != nil || item.element == "." {
                numTmp.append(item.element)
            }
            else if let op = NumOperate(rawValue: String(item.element)){
                arrNumTmp.append(numTmp)
                numTmp = ""
                opera.append(op)
            }
            if item.offset == tmp.count - 1 {
                arrNumTmp.append(numTmp)
            }
        }
        
        //判断有多少有效的书 //如果第一个数无效，那么不用看了
        for num in arrNumTmp.enumerated().reversed(){
            //找到最后一个无效的书
            if let n = num.element.toDouble(){
                nums.append(n)
            }
            else{
                //如果是第一个，就直接全部无效
                if num.offset == arrNumTmp.count - 1 {
                    return nil
                }
                else{
                    //不是第一个，保留这个数，获取这个是正确的数值
                    let ns = num.element.split(separator: ".")
                    if ns.count > 2 {
                        nums.append((String(ns[ns.count - 2]) + "." + String(ns[ns.count - 1])).toDouble()!)
                    }
                }
                break //后面不用看了
            }
        }
        let validNumCount = arrNumTmp.count - nums.count
        for _ in 0..<validNumCount {
            opera.removeFirst()
        }
        nums = nums.reversed()
        if opera.count > 0 {
            return(nums,opera)
        }
       return nil
    }

        /**
         * Returns the pointer to stack allocated memory containing this string of the type UnsafePointer<Int8>
         */
    func stackPointer() -> UnsafePointer<Int8>? {
        return (self as NSString).utf8String
    }
    
    /**
     * Returns the pointer to stack allocated memory containing this string of the type UnsafeMutablePointer<Int8>
     */
    func mutableStackPointer() -> UnsafeMutablePointer<Int8>? {
        return UnsafeMutablePointer<Int8>(mutating: self.stackPointer())
    }
    
    /**
     * Calls handle with the pointer to stack allocated memory containing this string of the type UnsafePointer<UInt8>
     */
    func withUnsignedStackPointer(_ handle: (UnsafePointer<UInt8>?) -> Void) {
        return Array(self.utf8).withUnsafeBytes { (p: UnsafeRawBufferPointer) -> Void in
            handle(p.bindMemory(to: UInt8.self).baseAddress!)
        }
    }
    
    /**
     * Calls handle with the pointer to stack allocated memory containing this string of the type UnsafeMutablePointer<UInt8>
     */
    func withUnsignedMutableStackPointer(_ handle: (UnsafeMutablePointer<UInt8>?) -> Void) {
        self.withUnsignedStackPointer { (unsigned: UnsafePointer<UInt8>?) in
            handle(UnsafeMutablePointer<UInt8>(mutating: unsigned))
        }
    }
    
    /**
     * Allocates memory on the heap containing this string of the type UnsafePointer<Int8>
     *
     * You must call .deallocate() on the result of this function when you are done using it.
     */
    func heapPointer() -> UnsafePointer<Int8>? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: data.count)
        bzero(buffer, MemoryLayout<Int8>.size * data.count)
        
        data.withUnsafeBytes { (p: UnsafeRawBufferPointer) -> Void in
            buffer.initialize(from: p.bindMemory(to: Int8.self).baseAddress!, count: data.count)
        }
        
        return UnsafePointer<Int8>(buffer)
    }
    
    /**
     * Allocates memory on the heap containing this string of the type UnsafeMutablePointer<Int8>
     *
     * You must call .deallocate() on the result of this function when you are done using it.
     */
    func mutableHeapPointer() -> UnsafeMutablePointer<Int8>? {
        return UnsafeMutablePointer<Int8>(mutating: self.heapPointer())
    }
    
    /**
     * Allocates memory on the heap containing this string of the type UnsafePointer<UInt8>
     *
     * You must call .deallocate() on the result of this function when you are done using it.
     */
    func unsignedHeapPointer() -> UnsafePointer<UInt8>? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        bzero(buffer, MemoryLayout<UInt8>.size * data.count)
        
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
        stream.open()
        data.withUnsafeBytes { (p: UnsafeRawBufferPointer) -> Void in
            stream.write(p.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
        }
        stream.close()
        return UnsafePointer<UInt8>(buffer)
    }
    
    /**
     * Allocates memory on the heap containing this string of the type UnsafeMutablePointer<UInt8>
     *
     * You must call .deallocate() on the result of this function when you are done using it.
     */
    func unsignedMutableHeapPointer() -> UnsafeMutablePointer<UInt8>? {
        return UnsafeMutablePointer<UInt8>(mutating: self.unsignedHeapPointer())
    }
    

  
    
}

public extension NSMutableAttributedString{
    func addColor(color:UIColor,range:NSRange)  {
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    func addFont(font:UIFont,range:NSRange) {
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
}

public extension Array{
    
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
    
    func isExistRepeatElement(condition:((_ item:Element)->Int)) -> Bool {
        var m = [Int:Int]()
        let res = self.map(condition)
        for r in res {
            if !m.keys.contains(r){
                m[r] = 0
            }
            else{
                m[r] = m[r]! + 1
                return true
            }
        }
        return false
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

public extension Dictionary{
    mutating func merge(newDict:Dictionary){
        for (k,v) in newDict{
            self[k] = v
        }
    }
}


public protocol DictionaryValue{
    var value:Any{ get }
}

public protocol JsonValue:DictionaryValue {
    var jsonValue:String{get }
}

public extension DictionaryValue{
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

public extension JsonValue{
    var jsonValue:String{
        let data = try? JSONSerialization.data(withJSONObject: value as! [String:Any], options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}

extension Int:DictionaryValue{    public var value: Any {        return self    }}

extension Float:DictionaryValue{    public var value: Any {        return self    }}

extension String:DictionaryValue{    public var value: Any {        return self    }}

extension Bool:DictionaryValue{    public var value: Any {        return self    }}

extension Array:DictionaryValue{
    public var value : Any{
        //这里需要判断
        return map{($0 as! DictionaryValue).value}
    }
}

extension Dictionary:DictionaryValue{
    public var value : Any{
        var dict = [String:Any]()
        for (k,v) in self{
            dict[k as! String] = (v as! DictionaryValue).value
        }
        return dict
    }
}
extension Array:JsonValue{
    public var jsonValue:String{
        //这里需要判断
        let strs = map{($0 as! DictionaryValue).value}
        let data = try? JSONSerialization.data(withJSONObject: strs, options: [])
        let jsonStr = String(data: data!, encoding: String.Encoding.utf8)
        return jsonStr ?? ""
    }
}
extension Dictionary:JsonValue{
    public var jsonValue:String{
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

public extension CGSize{
    func ratioSize(scale:CGFloat) -> CGSize {
        return CGSize(width: scale * self.width, height: scale * self.height)
    }
}

public extension CGRect {
    init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
    
   var center:CGPoint{
        get{
            return CGPoint(x: self.origin.x + self.self.width / 2, y: self.origin.y + self.self.height / 2)
        }
    }
}

public extension URL{
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


public extension Sequence where Element:Hashable{
    
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
public extension UIColor{
    
    static func Hex(hexString : String) -> UIColor {
        let r, g, b: CGFloat
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16)
                    g = CGFloat((hexNumber & 0x00ff00) >> 8)
                    b = CGFloat(hexNumber & 0x0000ff)
                    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
                }
            }
        }
        return UIColor.white;
    }
    
    open class var random: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0,
                       green: CGFloat(arc4random_uniform(256))/255.0,
                       blue: CGFloat(arc4random_uniform(256))/255.0,
                       alpha: 1.0)
    }
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
    
    public convenience init(gray: CGFloat, alpha: CGFloat = 1) {
        self.init(red: gray/255, green: gray/255, blue: gray/255, alpha: alpha)
    }
    
    public var redComponent: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }
    
    public var greenComponent: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }
    
    public var blueComponent: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }
    
    public var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }

}


public extension UIColor{
    static var pink:UIColor{
        get{
            return UIColor.init(red: 1, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1)
        }
    }
    static var silver:UIColor{
        get{
            return UIColor.init(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1)
        }
    }
}
