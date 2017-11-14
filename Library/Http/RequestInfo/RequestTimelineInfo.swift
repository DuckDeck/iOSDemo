//
//  RequestTimelineInfo.swift
//  HttpClientDemo
//
//  Created by HuStan on 6/14/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import Foundation

class RequestTimelineInfo:NSObject, NSCoding {
    var sendRequestTime:Date?                     //开始发送请求时间
    var sendRequestBodyStartTime:Date?    //开始发送请求体时间
    var sendRequestBodyEndTime:Date?      //结束发送体请求时间
    var receiveResponseStartTime:Date?             //开始接收回应时间
     var receiveResponseEndTime:Date?             //结束接收回应时间
    var reveiceResponseBodyStartTime:Date?//开始接收回应体时间
    var reveiceResponseBodyEndTime:Date?//结束接收回应体时间
    var requestFileTime:Date?                     //？？这是什么来着
    var timeoutTime:Date?                             //超时时间
    var sendRequestBodyTime:Int?{  //毫秒为单位
        if let start = sendRequestBodyStartTime {
            if let end = sendRequestBodyEndTime{
                   return Int(end.timeIntervalSince(start))
            }
        }
        return 0
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sendRequestTime, forKey: "sendRequestTime")
        aCoder.encode(sendRequestBodyStartTime, forKey: "sendRequestBodyStartTime")
        aCoder.encode(sendRequestBodyEndTime, forKey: "sendRequestBodyEndTime")
        aCoder.encode(receiveResponseStartTime, forKey: "receiveResponseStartTime")
        aCoder.encode(receiveResponseEndTime, forKey: "receiveResponseEndTime")
        aCoder.encode(reveiceResponseBodyStartTime, forKey: "reveiceResponseBodyStartTime")
        aCoder.encode(reveiceResponseBodyEndTime, forKey: "reveiceResponseBodyEndTime")
        aCoder.encode(requestFileTime, forKey: "requestFileTime")
        aCoder.encode(timeoutTime, forKey: "timeoutTime")

        
    }
    required init?(coder aDecoder: NSCoder) {
        sendRequestTime = aDecoder.decodeObject(forKey: "sendRequestTime") as? Date
        sendRequestBodyStartTime = aDecoder.decodeObject(forKey: "sendRequestBodyStartTime") as? Date
        sendRequestBodyEndTime = aDecoder.decodeObject(forKey: "sendRequestBodyEndTime") as? Date
        receiveResponseStartTime = aDecoder.decodeObject(forKey: "receiveResponseStartTime") as? Date
        receiveResponseEndTime = aDecoder.decodeObject(forKey: "receiveResponseEndTime") as? Date
        reveiceResponseBodyStartTime = aDecoder.decodeObject(forKey: "reveiceResponseBodyStartTime") as? Date
        reveiceResponseBodyEndTime = aDecoder.decodeObject(forKey: "reveiceResponseBodyEndTime") as? Date
        requestFileTime = aDecoder.decodeObject(forKey: "requestFileTime") as? Date
        timeoutTime = aDecoder.decodeObject(forKey: "timeoutTime") as? Date
    }
    
     internal static let msDataFormatter:DateFormatter = DateFormatter()
    
    static var MsDataFormatter:DateFormatter{
        get{
                msDataFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss:SSS"
                return msDataFormatter
            }

    }
    
    func toDict() -> [String:String] {
        var dict = [String:String]()
        dict["sendRequestTime"] = sendRequestTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: sendRequestTime!)
        dict["sendRequestBodyStartTime"] = sendRequestBodyStartTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: sendRequestBodyStartTime!)
        dict["sendRequestBodyEndTime"] = sendRequestBodyEndTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: sendRequestBodyEndTime!)
        dict["receiveResponseStartTime"] = receiveResponseStartTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: receiveResponseStartTime!)
        dict["receiveResponseEndTime"] = receiveResponseEndTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: receiveResponseEndTime!)
        dict["reveiceResponseBodyStartTime"] = reveiceResponseBodyStartTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: reveiceResponseBodyStartTime!)
        dict["reveiceResponseBodyEndTime"] = reveiceResponseBodyEndTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: reveiceResponseBodyEndTime!)
        dict["timeoutTime"] = timeoutTime ==  nil ? "" : RequestTimelineInfo.MsDataFormatter.string(from: timeoutTime!)
        dict["sendRequestBodyTime"] = sendRequestBodyTime ==  nil ? "" : "\(sendRequestBodyTime!)"
        return dict
    }
    
}
