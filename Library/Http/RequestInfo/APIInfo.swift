//
//  APIInfo.swift
//  HttpClientDemo
//
//  Created by HuStan on 6/15/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import UIKit

internal enum HttpMethod:Int{
    case get = 0
    case post
    case put
    case delete
    case head
    
    var discription:String{
        get{
            switch self {
            case HttpMethod.get:
                return "Get"
            case HttpMethod.post:
                return "Post"
            case HttpMethod.put:
                return "Put"
            case HttpMethod.head:
                return "Head"
            case HttpMethod.delete:
                return "Delete"
            }
        }
    }
   static func parse(method:String) -> HttpMethod {
        switch method.lowercased() {
        case "get":
           return HttpMethod.get
        case "post":
            return HttpMethod.post
        case "put":
            return HttpMethod.put
        case "head":
            return HttpMethod.head
        case "delete":
            return HttpMethod.delete
        default:
            return HttpMethod.get;
        }
    }
}

class APIInfo:NSObject,NSCoding {
    var author = ""
    var name = ""
    var apiDescription = ""
    var url:URL?
    var getParameters:[String:String]?
    //var postParameters:[String:String]? //以String的方式收集吧
    var httpMethod:HttpMethod = HttpMethod.get
    
    override init() {
        super.init()
    }
    
    
    static var apis:[String:APIInfo] {
        get{
            let messageAPI = APIInfo()
            messageAPI.author = "容树"
            messageAPI.name = "企图信息"
            var ps = [String:APIInfo]()
            ps["qitumessageAction"] = messageAPI
            return ps
        }
    }
    
//    static func getAPIWithUrl(_ url:String)->APIInfo?{
//        if let range = regexTool("/\\w+.php").match(input: url).rangeAt(0)
//         {
//            let action = (url as NSString).substring(with: NSMakeRange(range.location + 1, range.length - 1))
//            return APIInfo.apis[action]
//        }
//        return nil
//    }
    
    
    //action和description放另一个地方
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(author, forKey: "author")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(description, forKey: "apiDescription")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(getParameters, forKey: "getParameters")
     //   aCoder.encodeObject(postParameters, forKey: "postParameters")
        aCoder.encode(httpMethod.rawValue, forKey: "httpMethod")

    }
    
    required init?(coder aDecoder: NSCoder) {
        author = aDecoder.decodeObject(forKey: "author") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        apiDescription = aDecoder.decodeObject(forKey: "apiDescription") as! String
        url = aDecoder.decodeObject(forKey: "url") as? URL
        getParameters = aDecoder.decodeObject(forKey: "getParameters") as? [String:String]
   //     postParameters = aDecoder.decodeObjectForKey("postParameters") as? [String:String]
        httpMethod = HttpMethod(rawValue: aDecoder.decodeInteger(forKey: "httpMethod") )!
    }
    

    
    func getPara() -> [String:String]?{
        if let u = url {
            var s = u.absoluteString
            if s.contains("?") {
                s = s.components(separatedBy: "?").last!
                let strs = s.components(separatedBy: "&")
                var dict = [String:String]()
                for str in strs{
                    let pair = str.components(separatedBy: "=")
                    dict[pair.first!] = pair.last!
                }
                return dict
            }
            
        }
        return nil
    }
    
    
    func toDict() -> [String:String] {
        var dict = [String:String]()
        dict["author"] = author
        dict["name"] = name
        dict["apiDescription"] = apiDescription
        dict["url"] = url?.absoluteString ?? ""
        dict["getParameters"] = getParameters?.description ?? ""
        dict["httpMethod"] = httpMethod.discription
        return dict
    }
    
}
