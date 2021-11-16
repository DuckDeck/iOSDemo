//
//  TimeSpan.swift
//  GrandTimeDemo
//
//  Created by HuStan on 6/23/16.
//  Copyright © 2016 StanHu. All rights reserved.
//

import Foundation
let TickPerDay = 86400000
let TickPerHour = 3600000
let TickPerMinute = 60000
let TickPerSecond = 1000

public enum TimeSpanFormat{
    case dayFormat, // "dd HH:mm:ss",
     timeFormat, // "HH:mm:ss",
     msecFormat, // "HH:mm:ss SSS"
     allFormat // "dd HH:mm:ss SSS"
}

public func +(left:TimeSpan,right:TimeSpan) -> TimeSpan {
    let tick = left.ticks + right.ticks
    assert(tick < TimeSpan.Max!.ticks,"two timespan add can not big than max time span")
    return TimeSpan(ticks: tick)
}

public func -(left:TimeSpan,right:TimeSpan) -> TimeSpan {
    let tick = left.ticks - right.ticks
    assert(tick > 0,"two timespan subtruct can not less than 0")
    return TimeSpan(ticks: tick)
}
 public func <(lhs: TimeSpan, rhs: TimeSpan) -> Bool
{
    return lhs.compareTo(rhs) < 0
}
public func <=(lhs: TimeSpan, rhs: TimeSpan) -> Bool
{
    return lhs.compareTo(rhs) <= 0
}

public func >(lhs: TimeSpan, rhs: TimeSpan) -> Bool
{
    return lhs.compareTo(rhs) > 0
}
public func >=(lhs: TimeSpan, rhs: TimeSpan) -> Bool
{
    return lhs.compareTo(rhs) >= 0
}

public func == (lhs: TimeSpan, rhs: TimeSpan) -> Bool
{
    return lhs.compareTo(rhs) == 0
}


open class TimeSpan: NSObject,Comparable {
    
    
  public  static let Max = TimeSpan(days: 100000, hours: 23, minutes: 59, seconds: 59, milliseconds: 999)
  public  static let Zero = TimeSpan(days: 0, hours: 0, minutes: 0, seconds: 0, milliseconds: 0)
  fileprivate  var _day = 0
  fileprivate  var _hour = 0
  fileprivate  var _minute = 0
  fileprivate var _second = 0
  fileprivate  var _millisecond = 0
  fileprivate  var _ticks = 0
  public  override init() {
        super.init()
    }
    
   public  convenience init(ticks:Int) {
        self.init()
        assert(ticks >= 0, "ticks must >= 0")
        _ticks = ticks
        setTimes()
    }
    
  public  convenience init?(hours:Int,minutes:Int,seconds:Int) {
        self.init()
        if hours < 0 {
            print("TimeSpan warning: hours can not less than 0")
            return nil
        }
        else if hours > 23 {
            print("TimeSpan warning: hours can not bigger than 23")
            return nil
        }
        else if minutes < 0 {
            print("TimeSpan warning: minutes can not less than 0")
            return nil
        }
        else if minutes > 59 {
            print("TimeSpan warning: minutes can not bigger than 59")
            return nil
        }
        else if seconds < 0 {
            print("TimeSpan warning: seconds can not  less than 0")
            return nil
        }
        else if seconds > 59{
            print("TimeSpan warning: seconds can not  bigger than 59")
            return nil
        }
        _hour = hours
        _minute = minutes
        _second = seconds
        _ticks = hours * TickPerHour + _minute * TickPerMinute + _second * TickPerSecond
    }
    
   public convenience init?(days:Int,hours:Int,minutes:Int,seconds:Int) {
        if days < 0 {
            print("TimeSpan warning: days can not  less than 0")
            return nil
        }
        self.init(hours:hours,minutes: minutes,seconds: seconds)
        _day = days
        _ticks = _ticks + _day * TickPerDay
    }
    
   public convenience init?(days:Int,hours:Int,minutes:Int,seconds:Int,milliseconds:Int) {
        if milliseconds < 0 {
            print("TimeSpan warning: milliseconds can not  less than 0")
            return nil
        }
        else if milliseconds > 999{
            print("TimeSpan warning: milliseconds can not  bigger than 999")
            return nil
        }
        self.init(days:days,hours:hours,minutes: minutes,seconds: seconds)
        _millisecond = milliseconds
        _ticks = _ticks + milliseconds
    }
    
    open var days:Int{
        get{
            return _day
        }
        set{
            assert(newValue > 0, "days must > 0")
            _ticks = _ticks - _day * TickPerDay
            _day = newValue
            _ticks = _ticks + _day * TickPerDay
        }
    }
    
    open var hours:Int{
        get{
            return _hour
        }
        set{
            assert(newValue > 0 && newValue < 24, "hours must > 0 and < 24")
            _ticks = _ticks - _hour * TickPerHour
            _hour = newValue
            _ticks = _ticks + _hour * TickPerHour
        }
    }
    
    open var minutes:Int{
        get{
            return _minute
        }
        set{
            assert(newValue > 0 && newValue < 60, "minutes must > 0 and < 60")
            _ticks = _ticks - _minute * TickPerMinute
            _minute = newValue
            _ticks = _ticks + _minute * TickPerMinute
        }
    }
    
    open var seconds:Int{
        get{
            return _second
        }
        set{
            assert(newValue > 0 && newValue < 60, "seconds must > 0 and < 60")
            _ticks = _ticks - _second * TickPerSecond
            _second = newValue
            _ticks = _ticks + _minute * TickPerMinute

        }
    }
    
    open var milliseconds:Int{
        get{
            return _millisecond
        }
        set{
            assert(newValue > 0 && newValue < 999, "milliseconds must > 0 and < 999")
            _ticks = _ticks - _millisecond
            _millisecond = newValue
            _ticks = _ticks - _millisecond
        }
    }
    
    open var ticks:Int{
        get{
            return _ticks
        }
        set{
            _ticks = newValue
            setTimes()
        }
    }
    
    open var totalDays:Double{
        return Double(_ticks) / Double(TickPerDay)
    }
    
    open var totalHours:Double{
        return Double(_ticks) / Double(TickPerHour)
    }
    
    open var totalMinutes:Double{
        return Double(_ticks) / Double(TickPerMinute)
    }
    
    open var totalSeconds:Double{
        return Double(_ticks) / Double(TickPerSecond)
    }
    
    public static func compare(_ t1:TimeSpan,t2:TimeSpan)->Int{
        if t1.ticks > t2.ticks {
            return 1
        }
        else if t1.ticks < t2.ticks{
            return -1
        }
        return 0
    }
    
    public static func equl(_ t1:TimeSpan,t2:TimeSpan)->Bool{
       return t1.ticks == t2.ticks
    }

    public static func fromDays(_ days:Double)->TimeSpan{
        assert(days >= 0, "days must >= 0")
        return TimeSpan(ticks: Int(days * Double(TickPerDay)))
    }
    
    public static func fromHours(_ hours:Double)->TimeSpan{
        assert(hours >= 0, "hours must >= 0") //这里就不需要<24了
        return TimeSpan(ticks: Int(hours * Double(TickPerHour)))
    }
    
    public static func fromMinuts(_ minutes:Double)->TimeSpan{
        assert(minutes >= 0, "minutes must >= 0")//这里就不需要<60了
        return TimeSpan(ticks: Int(minutes * Double(TickPerMinute)))
    }
    
    public static func fromSeconds(_ seconds:Double)->TimeSpan{
        assert(seconds >= 0, "minutes must >= 0")//这里就不需要<60了
        return TimeSpan(ticks: Int(seconds * Double(TickPerSecond)))
    }
    public static func fromTicks(_ ticks:Int)->TimeSpan{
        assert(ticks >= 0, "minutes must >= 0")//这里就不需要<60了
        return TimeSpan(ticks: ticks)
    }
    
    //默认格式： day hors:minutes:seconds:milliseconds
    //这个地方不太好处理
    //这里可能要用正则，字符單解析一直是个大难题，这就是为什么编译器这么难写
    //C#里面有-的TimeSpan 我觉得没有必要
    //这个还是要做一做的
    // 默认和格式是 dd HH:mm:ss
    //这时用个枚举就好了，只支持三种格式，选择太多其实并不好
    public static func parse(_ time:String,format:TimeSpanFormat)->TimeSpan?{
        let t = time.trimmingCharacters(in: .whitespaces)
        switch format {
        case .dayFormat:
            if !DateTime.RegexTool.init("^\\d+\\s\\d{2}:\\d{2}:\\d{2}$").match(input: t){
                print("you time \(time) did not comfirm the timespan format dd HH:mm:ss")
                return nil
            }
            let day = Int(t.split(separator: " ").first!)!
            let time = String(t.split(separator: " ").last!)
            let hour = Int(time.split(separator: ":")[0])!
            let min = Int(time.split(separator: ":")[1])!
            let sec = Int(time.split(separator: ":")[2])!
            return TimeSpan(days: day, hours: hour, minutes: min, seconds: sec)
        case .timeFormat:
            if !DateTime.RegexTool.init("^\\d{2}:\\d{2}:\\d{2}$").match(input: t){
                print("you time \(time) did not comfirm the timespan format HH:mm:ss")
                return nil
            }
            let hour = Int(t.split(separator: ":")[0])!
            let min = Int(t.split(separator: ":")[1])!
            let sec = Int(t.split(separator: ":")[2])!
            return TimeSpan(days: 0, hours: hour, minutes: min, seconds: sec)
        case .msecFormat:
            if !DateTime.RegexTool.init("^\\d{2}:\\d{2}:\\d{2}:\\d{3}$").match(input: t){
                print("you time \(time) did not comfirm the timespan format HH:mm:ss:SSS")
                return nil
            }
            let hour = Int(t.split(separator: ":")[0])!
            let min = Int(t.split(separator: ":")[1])!
            let sec = Int(t.split(separator: ":")[2])!
            let msec = Int(t.split(separator: ":")[3])!
            return TimeSpan(days: 0, hours: hour, minutes: min, seconds: sec, milliseconds: msec)
        case .allFormat:
            if !DateTime.RegexTool.init("^\\d+\\s\\d{2}:\\d{2}:\\d{2}:\\d{3}$").match(input: t){
                print("you time \(time) did not comfirm the timespan format dd HH:mm:ss:SSS")
                return nil
            }
            let day = Int(t.split(separator: " ").first!)!
            let time = String(t.split(separator: " ").last!)
            let hour = Int(time.split(separator: ":")[0])!
            let min = Int(time.split(separator: ":")[1])!
            let sec = Int(time.split(separator: ":")[2])!
            let msec = Int(time.split(separator: ":")[3])!
            return TimeSpan(days: day, hours: hour, minutes: min, seconds: sec, milliseconds: msec)
        }
    }
    
 
    
    open func add(_ time:TimeSpan)->TimeSpan{
        let tick = time.ticks + ticks
        assert(ticks < TimeSpan.Max!.ticks,"the added value must < max")
        return TimeSpan(ticks: tick)
    }
    
    
  open  func compareTo(_ time:TimeSpan) -> Int {
        return TimeSpan.compare(self, t2: time)
    }
    
//    public override var hash: Int{
//        return
//    }
    
//    public override func isEqual(object: AnyObject?) -> Bool {
//        if let time = object as TimeSpan{
//            return time == self
//        }
//        return false
//    }
    

   open func subtract(_ time:TimeSpan) -> TimeSpan {
        let tick = ticks - time.ticks
        assert(ticks > 0,"tick must > 0")
        return TimeSpan(ticks: tick)
    }
    

    open  override var description: String{
        get{
            let hour = String(format: "%02d", hours)
            let minute = String(format: "%02d", minutes)
            let second = String(format: "%02d", seconds)
            let millisecond = String(format: "%03d", milliseconds)
            if days > 0{
                return "\(days) \(hour):\(minute):\(second):\(millisecond)"
            }
            else {
                return "\(hours):\(minute):\(second):\(millisecond)"
            }
        }
    }
    
  
   //这里有前面补0的问题，其实可以用格式的大小写来解决
   open func format(format:String = "dd HH:mm:ss") -> String {
        let minute = String(format: "%02d", minutes)
        let second = String(format: "%02d", seconds)
        let millisecond = String(format: "%03d", milliseconds)
        var result = format
        if format.contains("dd"){
            result = result.replacingOccurrences(of: "dd", with: String(days))
        }
        if format.contains("HH") {
            result = result.replacingOccurrences(of: "HH", with: String(format: "%02d", hours))
        }
        if format.contains("mm") {
            result = result.replacingOccurrences(of: "mm", with: String(minute))
        }
        if format.contains("ss") {
            result = result.replacingOccurrences(of: "ss", with: String(second))
        }
        if format.contains("SSS") {
            result = result.replacingOccurrences(of: "SSS", with: String(millisecond))
        }
        return result
    }
    
    fileprivate func setTimes(){
        if _ticks > 0 {
            _day = _ticks / TickPerDay
            _hour = (_ticks - _day * TickPerDay) / TickPerHour
            _minute = (_ticks - _day * TickPerDay - _hour * TickPerHour) / TickPerMinute
            _second = (_ticks - _day * TickPerDay - _hour * TickPerHour - _minute * TickPerMinute)  / TickPerSecond
            _millisecond = _ticks - _day * TickPerDay - _hour * TickPerHour - _minute * TickPerMinute - _second * TickPerSecond
        }
    }
}
