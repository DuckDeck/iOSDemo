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

public extension URL{
    func getScaleImage(to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        if !self.isFileURL{
            return nil
        }
        let sourceOpt = [kCGImageSourceShouldCache : false] as CFDictionary
        /**<
         这里有两个注意事项
         
         设置kCGImageSourceShouldCache为false，避免缓存解码后的数据，64位设置上默认是开启缓存的，（很好理解，因为下次使用该图片的时候，可能场景不同，需要生成的缩略图大小是不同的，显然不能做缓存处理）
         设置kCGImageSourceShouldCacheImmediately为true，避免在需要渲染的时候才做解码，默认选项是false
         */
        // 其他场景可以用createwithdata (data并未decode,所占内存没那么大),
        if let source = CGImageSourceCreateWithURL(self as CFURL, sourceOpt){
            let maxDimension = max(pointSize.width, pointSize.height) * scale
            let downsampleOpt = [kCGImageSourceCreateThumbnailFromImageAlways : true,
                                 kCGImageSourceShouldCacheImmediately : true ,
                                 kCGImageSourceCreateThumbnailWithTransform : true,
                                 kCGImageSourceThumbnailMaxPixelSize : maxDimension] as CFDictionary
            let downsampleImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOpt)!
            return UIImage(cgImage: downsampleImage)

        }
        return nil
    }
}
