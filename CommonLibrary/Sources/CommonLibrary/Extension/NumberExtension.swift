//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/5.
//

import UIKit
import GrandTime
public extension Int{
    func toTime(format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        var t = self
        if String(t).count > 11{
            t = t / 1000
        }
        let time = DateTime(timestamp: t)
        return time?.format(format) ?? ""
    }
    
    func toTimeSpan(format:String = "HH:mm:ss") -> String {
        let t = TimeSpan.fromSeconds(Double(self))
        return  t.format(format:format)
    }
    
    func createRandomNums(max:Int)->[Int] {
        var nums = [Int]()
        for _ in 0..<self {
            nums.append(Int(arc4random()) % max)
        }
        return nums
    }
    
    
    func toChinese() -> String {
        switch self {
        case 0:
            return "零"
        case 1:
            return "一"
        case 2:
            return "两"
        case 3:
            return "三"
        case 4:
            return "四"
        case 5:
            return "五"
        case 6:
            return "六"
        case 7:
            return "七"
        case 8:
            return "八"
        case 9:
            return "九"
        case 10:
            return "十"
        default:
            return "零"
        }
    }
    
    /// EZSE: Checks if the integer is even.
     var isEven: Bool { return (self % 2 == 0) }
    
    /// EZSE: Checks if the integer is odd.
     var isOdd: Bool { return (self % 2 != 0) }
    
    /// EZSE: Checks if the integer is positive.
     var isPositive: Bool { return (self > 0) }
    
    /// EZSE: Checks if the integer is negative.
     var isNegative: Bool { return (self < 0) }
    
    /// EZSE: Converts integer value to Double.
     var toDouble: Double { return Double(self) }
    
    /// EZSE: Converts integer value to Float.
     var toFloat: Float { return Float(self) }
    
    /// EZSE: Converts integer value to CGFloat.
     var toCGFloat: CGFloat { return CGFloat(self) }
    
    /// EZSE: Converts integer value to String.
     var toString: String { return String(self) }
    
    /// EZSE: Converts integer value to UInt.
     var toUInt: UInt { return UInt(self) }
    
    /// EZSE: Converts integer value to Int32.
     var toInt32: Int32 { return Int32(self) }
    
    /// EZSE: Converts integer value to a 0..<Int range. Useful in for loops.
     var range: CountableRange<Int> { return 0..<self }
    
    /// EZSE: Returns number of digits in the integer. //多少位
     var digits: Int {
        if self == 0 {
            return 1
        }
        return Int(log10(fabs(Double(self)))) + 1
       
    }
    
    /// EZSE: The digits of an integer represented in an array(from most significant to least).
    /// This method ignores leading zeros and sign
     var digitArray: [Int] {
        var digits = [Int]()
        for char in self.toString {
            if let digit = Int(String(char)) {
                digits.append(digit)
            }
        }
        return digits
    }
    
    /// EZSE: Returns a random integer number in the range min...max, inclusive.
     static func random(within: Range<Int>) -> Int {
        let delta = within.upperBound - within.lowerBound
        return within.lowerBound + Int(arc4random_uniform(UInt32(delta)))
    }
    
    func random()->Int  {
        return numericCast(arc4random_uniform(numericCast(range.count)))
            + range.lowerBound
    }
}

public extension Float{
    func inRange(target:Float,range:Float) -> Bool {
        if self <= target + range && self > target - range{
            return true
        }
        return false
    }
    func roundTo(places:UInt) -> Float {
        let divisor = pow(10.0, Float(places))
        return Float((self * divisor).rounded() / pow(10.0, Double(places)))
    }
}

public extension Double{
    func roundTo(places:UInt) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / pow(10.0, Double(places))
    }
    
    func roundToStr(places:UInt) -> String {
        let divisor = pow(10.0, Double(places))
        let res = (self * divisor).rounded() / pow(10.0, Double(places))
        return String(format:"%.\(places)f",res)
    }
}
