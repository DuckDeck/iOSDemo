//
//  GrandTime.swift
//  GrandTimeDemo
//
//  Created by HuStan on 6/23/16.
//  Copyright © 2016 StanHu. All rights reserved.
//

import Foundation
//这个类就完全参考C#的DateTime
//基本功能先这样
public enum  DateTimeKind:Int{
    case unspecified=0,utc,local
}

public enum DayOfWeek:Int{
    case sunday = 0,monday,tuesday,wendesday,thursday,friday,saturday
    public  var description:String{
        switch self {
        case .monday:
            return "星期一"
        case .tuesday:
            return "星期二"
        case .wendesday:
            return "星期三"
        case .thursday:
            return "星期四"
        case .friday:
            return "星期五"
        case .saturday:
            return "星期六"
        case .sunday:
            return "星期天"
        }
    }
}



enum DisplayDateTimeStyleLanguage {
    case cn,us
}

public let LeapYearMonth = [31,29,31,30,31,30,31,31,30,31,30,31]
public let NotLeapYearMonth  = [31,28,31,30,31,30,31,31,30,31,30,31]

//这个会有点难，要算的东西有点多
public func -(left:DateTime,right:DateTime) -> TimeSpan? {
    let ms = left.dateTime.timeIntervalSince(right.dateTime)
    if ms < 0 {
        print("DateTime warning: left time must bigger then right time")
        return nil
    }
    return TimeSpan(ticks: Int(ms) * 1000)
}

public func +(left:DateTime,right:TimeSpan) -> DateTime {
    let ms = Int(left.dateTime.timeIntervalSince1970 * 1000) + right.ticks
    return DateTime(tick: ms)!
}

public func -(left:DateTime,right:TimeSpan) -> DateTime {
    var ms = Int(left.dateTime.timeIntervalSince1970 * 1000) - right.ticks
    if ms < 0 {
        ms = 0
    }
    return DateTime(tick: ms)!
    
}

public func >(lhs: DateTime, rhs: DateTime) -> Bool {
    let ms = lhs.dateTime.timeIntervalSince(rhs.dateTime)
    return ms > 0
}

public func >=(lhs: DateTime, rhs: DateTime) -> Bool {
    let ms = lhs.dateTime.timeIntervalSince(rhs.dateTime)
    return ms >= 0
}

public func <(lhs: DateTime, rhs: DateTime) -> Bool {
    let ms = lhs.dateTime.timeIntervalSince(rhs.dateTime)
    return ms < 0
}


public func <=(lhs: DateTime, rhs: DateTime) -> Bool {
    let ms = lhs.dateTime.timeIntervalSince(rhs.dateTime)
    return ms <= 0
}


open class DateTime: NSObject,Comparable {
    
    //最小是1970年1月1号上午8点整
    open static let minDateTime = DateTime(tick: 0)
    //这里最大值一直不明确，但是我已经试过了，iOS里面最大的NSDate是一个非常大有年份，我可以保证没有人可以用到的
    open static let maxDateTime = DateTime(date: Date(timeIntervalSince1970: TimeInterval(Int.max) / 100000))
    
    fileprivate static let dateFormatter = DateFormatter()
    
    fileprivate  static var  dateComponent = DateComponents()
    
    static var timeZone = NSTimeZone.system{
        didSet{
            DateTime.dateFormatter.timeZone = timeZone
        }
    }
    let offSetInterval = DateTime.timeZone.secondsFromGMT()
    
   fileprivate var dateTime:Date{
        // issue1 when in the init func .the disSet perocess do not work. this indeed not word. but it affect
        didSet{
            internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
        }
    }
    open  var timeZone = TimeZone.current  //这个要不要自己封装？ 先用系统的吧
    open  var dateTImeKind = DateTimeKind.unspecified
    fileprivate var internalDateComponent:DateComponents
    public  override init() {
        internalDateComponent = DateComponents()
        dateTime = Date()
        DateTime.dateFormatter.timeZone = DateTime.timeZone
        super.init()
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
    }
    
    
    
    public convenience init?(tick:Int) {
        self.init()
        if ticks < 0 {
            print("DateTime warning: tick can not less than 0")
            return nil
        }
        else if ticks >= Int.max / 100000{
            print("DateTime warning: tick can not bigger than Int.max / 100000")
            return nil
        }
        dateTime = Date(timeIntervalSince1970: Double(tick) / 1000.0)
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
        
    }
    //暂时不要这个
    //  public  convenience init(tick:Int,kind:DateTimeKind) {
    //        self.init()
    //        assert(tick >= 0 && tick <= Int.max / 100000, "wrong tick")
    //        //这个是以秒为单体，DateTime都是100纳秒为单位
    //        dateTImeKind = kind
    //        dateTime = NSDate(timeIntervalSince1970: Double(tick) / 1000.0)
    //    }
    
    public convenience init(date:Date) {
        self.init()
        dateTime = date
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
    }
    
    public   convenience init?(tickSinceNow:Int) {
        self.init()
        //这个是以秒为单体，DateTime都是100纳秒为单位
        if ticks >= Int.max / 100000{
            print("DateTime warning: tickSinceNow can not bigger than Int.max / 100000")
            return nil
        }
        let interval = Int(Date().timeIntervalSince1970)
        if tickSinceNow < -(interval * 1000) {
            print("DateTime warning: tickSinceNow can not less than now to 1970 ticks")
            return nil
        }
        dateTime = Date(timeIntervalSinceNow: Double(tickSinceNow) / 1000.0)
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
    }
    
    
    public convenience init?(timestamp:Int){
        self.init()
        if timestamp < 0 {
            print("DateTime warning: timestamp can not less than 0")
            return nil
        }
        else if timestamp > Int.max / 100000{
            print("DateTime warning: timestamp can not bigger than Int.max / 100000")
            return nil
        }
        dateTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
    }
    public convenience init?(year:Int,month:Int,day:Int) {
        self.init()
        if year < 1970 {
            print("DateTime warning: year can not less than 1970")
            return nil
        }
        else if year > 1000000 {
            print("DateTime warning: year can not bigger than 1000000")
            return nil
        }
        else if month < 1 {
            print("DateTime warning: month can not less than 1")
            return nil
        }
        else if month > 12 {
            print("DateTime warning: month can not bigger than 12")
            return nil
        }
        else if day < 1 {
            print("DateTime warning: day can not less than 0")
            return nil
        }
        else{
            var maxDays = 30
            if DateTime.isLeapYeay(year){
                maxDays = LeapYearMonth[month-1]
            }
            else{
                maxDays = NotLeapYearMonth[month-1]
            }
            if day > maxDays {
                print("DateTime warning: day can not  bigger than \(maxDays)")
                return nil
            }
        }
        DateTime.dateComponent.year = year
        DateTime.dateComponent.month = month
        DateTime.dateComponent.day = day
        if let date = Calendar.current.date(from: DateTime.dateComponent){
            dateTime = date
            internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
        }
        else{
            print("DateTime warning: time Component data have issue")
            return nil
        }
    }
    
    public convenience init?(year:Int,month:Int,day:Int,hour:Int,minute:Int,second:Int) {
        self.init(year:year,month:month,day:day)
        if hour < 0 {
            print("DateTime warning: hour can not less than 0")
            return nil
        }
        else if hour > 23 {
            print("DateTime warning: hour can not bigger than 23")
            return nil
        }
        else if minute < 0 {
            print("DateTime warning: minute can not less than 0")
            return nil
        }
        else if minute > 59 {
            print("DateTime warning: minute can not bigger than 59")
            return nil
        }
        else if second < 0 {
            print("DateTime warning: second can not  less than 0")
            return nil
        }
        else if second > 59{
            print("DateTime warning: second can not  bigger than 59")
            return nil
        }
        DateTime.dateComponent.hour = hour
        DateTime.dateComponent.minute = minute
        DateTime.dateComponent.second = second
        if let date = Calendar.current.date(from: DateTime.dateComponent){
            dateTime = date
            internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
        }
        else{
            print("DateTime warning: time Component data have issue")
            return nil
        }
    }
    
    public convenience init?(year:Int,month:Int,day:Int,hour:Int,minute:Int,second:Int,millisecond:Int) {
        self.init(year:year,month:month,day:day,hour: hour,minute: minute,second: second)
        if millisecond < 0 {
            print("DateTime warning: millisecond can not less than 0")
            return nil
        }
        else if millisecond > 999{
            print("DateTime warning: millisecond can not bigger than 999")
            return nil
        }
        DateTime.dateComponent.nanosecond = millisecond
        if let date = Calendar.current.date(from: DateTime.dateComponent){
            dateTime = date
            internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
        }
        else{
            print("DateTime warning: time Component data have issue")
            return nil
        }
    }
    
    open var local = Locale(identifier: "zh_CN")
    
    open static var  now:DateTime{
        return DateTime()
    }
    
    open var dayOfWeek:DayOfWeek{
        get{
            let cal = Calendar.current
            let cmp = (cal as NSCalendar).component([.weekday], from: dateTime)
            return DayOfWeek(rawValue: cmp - 1)!
        }
    }
    
    
    
    open var year:Int{
        get{
            return internalDateComponent.year!
        }
        set{
            internalDateComponent.year = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: year have issue")
            }
        }
    }
    
    open var month:Int{
        get{
            return internalDateComponent.month!
        }
        set{
            internalDateComponent.month = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: month have issue")
            }
        }
    }
    
    
    open var day:Int{
        get{
            return internalDateComponent.day!
        }
        set{
            internalDateComponent.day = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: day have issue")
            }
        }
    }
    
    open var hour:Int{
        get{
            return internalDateComponent.hour!
        }
        set{
            internalDateComponent.hour = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: hore have issue")
            }
        }
    }
    
    open var minute:Int{
        get{
            return internalDateComponent.minute!
        }
        set{
            internalDateComponent.minute = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: minute have issue")
            }
        }
    }
    
    open var second:Int{
        get{
            return internalDateComponent.second!
        }
        set{
            internalDateComponent.second = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: second have issue")
            }
        }
    }
    
    open var millisecond:Int{
        get{
            return internalDateComponent.nanosecond!
        }
        set{
            internalDateComponent.nanosecond = newValue * 1000000
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: millisecond have issue")
            }
        }
    }
    
    open var date:Date{
        return (dateTime as NSDate).copy() as! Date
    }
    
    open var weekDay:DayOfWeek{
        return DayOfWeek(rawValue: internalDateComponent.weekday! - 1)!
    }
    
    open var quarter:Int{
        return  internalDateComponent.quarter!
    }
    
    open var weekOfMonth:Int{
        return internalDateComponent.weekOfMonth!
    }
    
    open var weekOfYear:Int{
        return internalDateComponent.weekOfYear!
    }
    
    open var ticks:Int{
        return Int(dateTime.timeIntervalSince1970 * Double(1000))
    }
    
    //以后再做
    //    public var utcDateTime:Date{
    //        return NSTimeZone
    //    }
    
    
    open override var description: String{
        return format()
    }
    
    open override var debugDescription: String{
        return description
    }
    
    open var dayOfYear:Int{
        get{
            let month = self.month
            let day = self.day
            var days = 0
            if DateTime.isLeapYeay(self.year) {
                var i = 0
                while i < month {
                    days += LeapYearMonth[i]
                    i = i + 1
                }
                return days + day
            }
            else{
                var i = 0
                while i < month {
                    days += NotLeapYearMonth[i]
                    i = i + 1
                }
                return days + day
            }
        }
    }
    
    open static func isLeapYeay(_ year:Int)->Bool{
        return year % 4 == 0 && year % 100 != 0
    }
    
    // 这里目前不能传负数，但是如果是Int，类型，是应该可以接受负数的
    //这个地方有争议。很大有问题，不建议使用
    open func selfAddMonth(_ months:Int)  {
        var i = month
        var currentYear = year
        //可以将month转化成day
        var  days = 0
        if months > 0 {
            while i < months + month{
                if DateTime.isLeapYeay(currentYear) {
                    days = days + LeapYearMonth[i % 12]
                }
                else{
                    days = days + NotLeapYearMonth[i % 12]
                }
                if i % 12 == 0 {
                    currentYear = currentYear + 1
                }
                i = i + 1
            }
            selfAddDays(Double(days))
        }
        
        if months < 0 {
                i = month - 1
                while i >= months + month{
                if DateTime.isLeapYeay(currentYear) {
                    days = days + LeapYearMonth[abs(i) % 12]
                }
                else{
                    days = days + NotLeapYearMonth[abs(i) % 12]
                }
                if abs(i) % 12 == 0 {
                    currentYear = currentYear - 1
                }
                i = i - 1
            }
            selfAddDays(Double(-days))
        }
    }
    
    open func selfAddYears(_ years:Int){
        if year + years > 1000000 {
            print("DateTime warning: years is too big")
            return
        }
        selfAddMonth(years * 12) //这样应该要吧
    }
    
    open func selfAddDays(_ days:Double)  {
        selfAddMilliSeconds(days * Double(TickPerDay))
    }
    
    open func selfAddHours(_ hours:Double)  {
         selfAddMilliSeconds(hours * Double(TickPerHour))
    }
    
    open func selfAddMinutes(_ minutes:Double) {
        selfAddMilliSeconds(minutes * Double(TickPerMinute))
    }
    
    open func selfAddSeconds(_ seconds:Double)  {
        selfAddMilliSeconds(seconds * Double(TickPerSecond))
    }
    
    open func selfAddMilliSeconds(_ milliSeconds:Double){
        dateTime = dateTime.addingTimeInterval(milliSeconds / 1000)
    }
    
    open func addMilliSeconds(_ milliSeconds:Double)->DateTime{
        let copy = self.copy() as! DateTime
        copy.selfAddMilliSeconds(milliSeconds)
        return copy
    }
    
    open func addSeconds(_ seconds:Double) ->DateTime {
        let copy = self.copy() as! DateTime
        copy.selfAddMilliSeconds(seconds * Double(TickPerSecond))
        return copy
    }
    
    open func addMinutes(_ minutes:Double)->DateTime {
        let copy = self.copy() as! DateTime
        copy.selfAddMilliSeconds(minutes * Double(TickPerMinute))
        return copy
    }
    
    open func addHours(_ hours:Double)  -> DateTime{
        let copy = self.copy() as! DateTime
        copy.selfAddMilliSeconds(hours * Double(TickPerHour))
        return copy
    }
    
    open func addDays(_ days:Double)  ->DateTime{
         let copy = self.copy() as! DateTime
        copy.selfAddMilliSeconds(days * Double(TickPerDay))
        return copy
    }
    
    open func addYears(_ years:Int)->DateTime{
         let copy = self.copy() as! DateTime
        copy.selfAddMonth(years * 12) //这样应该要吧
        return copy
    }
    
    open func addMonth(_ months:Int)  ->DateTime{
         let copy = self.copy() as! DateTime
        copy.selfAddMonth(months)
        return copy
    }
    
    
   open static func compare(_ left:DateTime,right:DateTime)->Int{
        let result = left.dateTime.compare(right.dateTime)
        if result == .orderedAscending {
            return -1
        }
        else if result == .orderedDescending{
            return 1
        }
        return 0
    }
    
  open  func compareTo(_ time:DateTime) -> Int {
        return DateTime.compare(self, right: time)
    }
    
 open   func daysInMonth(_ year:Int,month:Int) -> Int? {
         if month < 1 {
            print("DateTime warning: month can not less than 1")
            return nil
        }
        else if month > 12 {
            print("DateTime warning: month can not bigger than 12")
            return nil
        }
        if DateTime.isLeapYeay(year) {
            return LeapYearMonth[month]
        }
        else{
            return NotLeapYearMonth[month]
        }
    }
    
   open static func equals(_ left:DateTime,right:DateTime)->Bool{
        return DateTime.compare(left, right: right) == 0
    }
    
  open  func  equals(_ time:DateTime) -> Bool {
        return DateTime.equals(self, right: time)
    }
    
    //最好用一个单例子来实现NSDateFormatter，因为NSDateFormatter
    //很吃资源
  open  func format(_ format:String = "yyyy-MM-dd HH:mm:ss:SSS") -> String {
        DateTime.dateFormatter.dateFormat = format
        return DateTime.dateFormatter.string(from: dateTime)
    }
    
    open func format(_ dateFormat:DateFormatter.Style,timeFormat:DateFormatter.Style)->String{
        DateTime.dateFormatter.locale = local
        DateTime.dateFormatter.dateStyle = dateFormat
        DateTime.dateFormatter.timeStyle = timeFormat
        return DateTime.dateFormatter.string(from: dateTime)
    }
    

    
  open  var dateString:String{
        return format("yyyy-MM-dd")
    }
    
  open   var timeString:String{
        return format("HH:mm:ss")
    }
    
    
    //这里还需要各种转化为时间的Style，需要补上
    
    
   open static func parse(_ time:String) -> DateTime? {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: time){
            return DateTime(date: date)
        }
        else{
            return nil
        }
    }
    
  open  static func parse(_ time:String,format:String) -> DateTime? {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: time){
            return DateTime(date: date)
        }
        else{
            return nil
        }
    }
    
    open override var hashValue: Int{
        return ticks ^ hash
    }
    
    open override func copy() -> Any {
        return DateTime(date: dateTime)
    }
}


