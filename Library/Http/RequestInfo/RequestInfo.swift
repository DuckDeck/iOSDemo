//
//  RequestInfo.swift
//  HttpClientDemo
//
//  Created by HuStan on 6/15/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import UIKit
//import OHHTTPStubs

enum RequestResult:Int {
    
    
    
    
    case success = 0,timeout,fail
    
    var discription:String{
        get{
            switch self {
            case RequestResult.success:
                return "Success"
            case RequestResult.timeout:
                return "Timeout"
            case RequestResult.fail:
                return "Fail"
            }
        }
    }
}

class RequestInfo :NSObject,NSCoding{
    var requestId = 0
    var deviceInfo = ""
    var osVersion = ""
    var apiInfo:APIInfo?
    var requestTimeLine:RequestTimelineInfo?
    var requestDataInfo:RequestDataInfo?
    var requestResult = RequestResult.success
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(requestId, forKey: "requestId")
        aCoder.encode(apiInfo, forKey: "apiInfo")
        aCoder.encode(deviceInfo,forKey: "deviceInfo")
        aCoder.encode(osVersion,forKey: "osVersion")
        aCoder.encode(requestTimeLine, forKey: "requestTimeLine")
        aCoder.encode(requestDataInfo, forKey: "requestDataInfo")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        requestId =  aDecoder.decodeInteger(forKey: "requestId")
        deviceInfo = aDecoder.decodeObject(forKey: "deviceInfo") as! String
        osVersion = aDecoder.decodeObject(forKey: "osVersion") as! String
        apiInfo =  aDecoder.decodeObject(forKey: "apiInfo") as? APIInfo
        requestTimeLine = aDecoder.decodeObject(forKey: "RequestTimelineInfo") as? RequestTimelineInfo
        requestDataInfo = aDecoder.decodeObject(forKey: "requestDataInfo") as? RequestDataInfo
    }
    
    func toDict() -> [String:String] {
        var dict = [String:String]()
        dict["requestId"] = "\(requestId)"
        dict["deviceInfo"] = deviceInfo
        dict["osVersion"] = osVersion
        dict["apiInfo"] = apiInfo == nil ? "" : apiInfo!.toDict().description
        dict["requestTimeLine"] = requestTimeLine == nil ? "" : requestTimeLine!.toDict().description
        dict["requestDataInfo"] = requestDataInfo == nil ? "" : requestDataInfo!.toDict().description
        dict["requestResult"] = requestResult.discription
        return dict
    }
    
    

    
    internal static func storeFilePath(_ url:String)->String{
        var cachePath: AnyObject? = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first as AnyObject?
        cachePath = (cachePath as! NSString).appendingPathComponent("HttpClientRequestInfo") as String as AnyObject?
        if !FileManager.default.fileExists(atPath: cachePath as! String) {
            do {
                try FileManager.default.createDirectory(atPath: cachePath as! String , withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        let path = (cachePath as! NSString).appendingPathComponent(url)
        return path as String
    }
    
    static var apiInfos:[String:APIInfo]{
        get{
            
            return [String:APIInfo]()
        }
    }
}
