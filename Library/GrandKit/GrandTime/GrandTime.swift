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
//下面有个定义， Timestamp是指格林威治时间1970年01月01日00时00分00秒(北京时间1970年01月01日08时00分00秒)起至现在的总秒数
//              ticks 表示0001 年 1 月 1 日午夜 00:00:00 以来所经历的 1000 微秒数，即Ticks的属性 1Ticks表示1毫秒
// 所以这个要重写
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
//public let TickTo1970 = -62167219200 //这个时间戳是 0000-01-01 00:00:00的时间戳
//public let TickTo1970 = -2197208776 //这个时间戳是 1900-01-01 00:00:00的时间戳。//从这个时间算吧，没办法
//Issue 点
// 用这个版本来发布到Cocoapods发现报错，但是我用模拟器完全OK，就是因为这个数，超出32位的大小了，当跑在真机上或者模拟
//器上时，是可以用64位的，但是当选择generic ios device 来编译代码时，会出现可能是32位的情况，32位是不能放下这么大的数的，
//所以就出错了
//这个会有点难，要算的东西有点多
//不行。这个问题还是得修复，因为打包时还是得有32位，会报错的
public func -(left:DateTime,right:DateTime) -> TimeSpan? {
    let ms = left.dateTime.timeIntervalSince(right.dateTime)
    if ms < 0 {
        print("DateTime warning: left time must bigger then right time")
        return nil
    }
    return TimeSpan(ticks: Int(ms) * 1000)
}

public func +(left:DateTime,right:TimeSpan) -> DateTime {
    let ms = left.timestamp + right.seconds
    return DateTime(timestamp: ms)!
}

public func -(left:DateTime,right:TimeSpan) -> DateTime {
    var ms = left.timestamp - right.seconds
    if ms < 0 {
        ms = 0
    }
    return DateTime(timestamp: ms)!
    
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
    
    //最小是0001 年 1 月 1 日午夜 00:00:00 不用这个了，没有任何意义
    //open static let minDateTime = DateTime(ticks: 0)
    //这里最大值一直不明确，但是我已经试过了，iOS里面最大的NSDate是一个非常大有年份，我可以保证没有人可以用到的
    public static let maxDateTime = DateTime(date: Date(timeIntervalSince1970: TimeInterval(Int.max) / 100000))
    
   
    
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
    
    
    public convenience init(date:Date) {
        self.init()
        dateTime = date
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
    }
    
    public convenience init?(timestamp:Int){
        self.init()
//        if timestamp < TickTo1970 {
//            print("DateTime warning: timestamp can not less than -62167219200")
//            return nil
//        }
        if timestamp > Int.max / 100000{
            print("DateTime warning: timestamp can not bigger than Int.max / 100000")
            return nil
        }
        dateTime = Date(timeIntervalSince1970: TimeInterval(timestamp))
        internalDateComponent =  (Calendar.current as NSCalendar).components([.weekday,.weekOfYear,.year,.month,.day,.hour,.minute,.second,.nanosecond,.quarter,.weekOfMonth,.weekOfYear], from: dateTime)
    }
    
    public convenience init?(year:Int,month:Int,day:Int) {
        self.init()
        if year < 0 {
            print("DateTime warning: year can not less than 0")
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
    
    public static var  now:DateTime{
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
            return internalDateComponent.nanosecond! / 1000000
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
    
    open var nanosecond:Int{
        get{
            return internalDateComponent.nanosecond!
        }
        set{
            internalDateComponent.nanosecond = newValue
            if let date = Calendar.current.date(from: internalDateComponent){
                dateTime = date
            }
            else{
                print("DateTime warning: millisecond have issue")
            }
        }
    }
    
    open var date:DateTime{
        return DateTime(year: year, month: month, day: day)!
    }
    
    open var weekDay:DayOfWeek{
        return DayOfWeek(rawValue: internalDateComponent.weekday! - 1)!
    }
    
    open var quarter:Int{
        return  internalDateComponent.quarter! + 1 //系统是从0开始的，这里我们一般从1开始
    }
    
    open var weekOfMonth:Int{
        return internalDateComponent.weekOfMonth!
    }
    
    open var weekOfYear:Int{
        return internalDateComponent.weekOfYear!
    }
    
    
    open var timestamp:Int{
        return Int(dateTime.timeIntervalSince1970)
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
    
    public static func isLeapYeay(_ year:Int)->Bool{
        return year % 4 == 0 && year % 100 != 0
    }
    
    
    
    open func toOCDate()->Date{
        return dateTime
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
    
    
    public static func compare(_ left:DateTime,right:DateTime)->Int{
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
    
    public static  func daysInMonth(_ year:Int,month:Int) -> Int? {
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
    
    open  func daysInMonth() -> Int {
        
        if DateTime.isLeapYeay(self.year) {
            return LeapYearMonth[self.month]
        }
        else{
            return NotLeapYearMonth[self.month]
        }
    }
    
    public static func equals(_ left:DateTime,right:DateTime)->Bool{
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
    
    open  var timeString:String{
        return format("HH:mm:ss")
    }
    
    open var time:DateTime{
        return DateTime(year: 0, month: 0, day: 0, hour: hour, minute: minute, second: second)!
    }
    
    var secondsToZeroTime:Int{
        return hour * 3600 + minute * 60 + second
    }
    
    //这里还需要各种转化为时间的Style，需要补上
    
    
    public static func parse(_ time:String) -> DateTime? {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: time){
            return DateTime(date: date)
        }
        else{
            return nil
        }
    }
    
    public  static func parse(_ time:String,format:String) -> DateTime? {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: time){
            return DateTime(date: date)
        }
        else{
            return nil
        }
    }
    
    open override var hash: Int{
        return timestamp.hashValue
    }

    
    open override func copy() -> Any {
        return DateTime(date: dateTime)
    }
    
    struct RegexTool {
        let regex:NSRegularExpression?
        init(_ pattern:String){
            regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        }
        func match(input:String)->Bool{
            if let matches = regex?.matches(in: input, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, (input as NSString).length)) {
                return matches.count > 0
            }
            else{
                return false
            }
        }
    }

}
