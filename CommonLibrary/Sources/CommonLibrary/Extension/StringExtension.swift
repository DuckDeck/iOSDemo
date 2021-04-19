//
//  File.swift
//  
//
//  Created by chen liang on 2021/4/19.
//

import UIKit
import CommonCrypto

public extension String{
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil) -> CGSize {
        let attritube = NSMutableAttributedString(string: self)
        let range = NSRange(location: 0, length: attritube.length)
        attritube.addAttributes([NSAttributedString.Key.font: font], range: range)
        if lineSpacing != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing!
            attritube.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        }
        
        let rect = attritube.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        var size = rect.size
        
        if let currentLineSpacing = lineSpacing {
            // 文本的高度减去字体高度小于等于行间距，判断为当前只有1行
            let spacing = size.height - font.lineHeight
            if spacing <= currentLineSpacing && spacing > 0 {
                size = CGSize(width: size.width, height: font.lineHeight)
            }
        }
        
        return size
    }
    
    func boundingRect(with constrainedSize: CGSize, font: UIFont, lineSpacing: CGFloat? = nil, lines: Int) -> CGSize {
        if lines < 0 {
            return .zero
        }
        
        let size = boundingRect(with: constrainedSize, font: font, lineSpacing: lineSpacing)
        if lines == 0 {
            return size
        }
        
        let currentLineSpacing = (lineSpacing == nil) ? (font.lineHeight - font.pointSize) : lineSpacing!
        let maximumHeight = font.lineHeight*CGFloat(lines) + currentLineSpacing*CGFloat(lines - 1)
        if size.height >= maximumHeight {
            return CGSize(width: size.width, height: maximumHeight)
        }
        
        return size
    }
    
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
