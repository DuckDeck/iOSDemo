//
//  Number+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import GrandTime
extension Int{
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
    public var isEven: Bool { return (self % 2 == 0) }
    
    /// EZSE: Checks if the integer is odd.
    public var isOdd: Bool { return (self % 2 != 0) }
    
    /// EZSE: Checks if the integer is positive.
    public var isPositive: Bool { return (self > 0) }
    
    /// EZSE: Checks if the integer is negative.
    public var isNegative: Bool { return (self < 0) }
    
    /// EZSE: Converts integer value to Double.
    public var toDouble: Double { return Double(self) }
    
    /// EZSE: Converts integer value to Float.
    public var toFloat: Float { return Float(self) }
    
    /// EZSE: Converts integer value to CGFloat.
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    /// EZSE: Converts integer value to String.
    public var toString: String { return String(self) }
    
    /// EZSE: Converts integer value to UInt.
    public var toUInt: UInt { return UInt(self) }
    
    /// EZSE: Converts integer value to Int32.
    public var toInt32: Int32 { return Int32(self) }
    
    /// EZSE: Converts integer value to a 0..<Int range. Useful in for loops.
    public var range: CountableRange<Int> { return 0..<self }
    
    /// EZSE: Returns number of digits in the integer. //多少位
    public var digits: Int {
        if self == 0 {
            return 1
        }
        return Int(log10(fabs(Double(self)))) + 1
       
    }
    
    /// EZSE: The digits of an integer represented in an array(from most significant to least).
    /// This method ignores leading zeros and sign
    public var digitArray: [Int] {
        var digits = [Int]()
        for char in self.toString {
            if let digit = Int(String(char)) {
                digits.append(digit)
            }
        }
        return digits
    }
    
    /// EZSE: Returns a random integer number in the range min...max, inclusive.
    public static func random(within: Range<Int>) -> Int {
        let delta = within.upperBound - within.lowerBound
        return within.lowerBound + Int(arc4random_uniform(UInt32(delta)))
    }
    
    func random()->Int  {
        return numericCast(arc4random_uniform(numericCast(range.count)))
            + range.lowerBound
    }
}

extension Float{
    func inRange(target:Float,range:Float) -> Bool {
        if self <= target + range && self > target - range{
            return true
        }
        return false
    }
}
