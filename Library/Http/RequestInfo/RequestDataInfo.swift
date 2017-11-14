//
//  RequestDataInfo.swift
//  HttpClientDemo
//
//  Created by HuStan on 6/15/16.
//  Copyright © 2016 Qfq. All rights reserved.
//


import UIKit

class RequestDataInfo:NSObject,NSCoding {
    var postDataSize:NSInteger = 0 //
   // var postDataType = "" //
    var postDataMimeType = "" //specific type like: image/jpg,image/png, rar,pdf,text some thing like that
    var responseDataSize:NSInteger = 0
    var reponseDataMimeType = ""
    override init() {
        super.init()
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(postDataSize, forKey: "postDataSize")
        aCoder.encode(postDataMimeType, forKey: "postDataMimeType")
        aCoder.encode(responseDataSize, forKey: "responseDataSize")
        aCoder.encode(reponseDataMimeType, forKey: "reponseDataMimeType")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        postDataSize =  aDecoder.decodeInteger(forKey: "postDataSize")
        responseDataSize =  aDecoder.decodeInteger(forKey: "responseDataSize")
        reponseDataMimeType = aDecoder.decodeObject(forKey: "reponseDataMimeType") as! String
        postDataMimeType = aDecoder.decodeObject(forKey: "postDataMimeType") as! String
    }
    

    func toDict() -> [String:String] {
        var dict = [String:String]()
        dict["postDataSize"] = "\(postDataSize)"
        dict["postDataMimeType"] = postDataMimeType
        dict["responseDataSize"] = "\(responseDataSize)"
        dict["reponseDataMimeType"] = reponseDataMimeType
        return dict
    }
    
}
