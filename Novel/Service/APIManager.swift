//
//  APIManager.swift
//  iOSDemo
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import Foundation
import Moya
enum APIManager {
    case GetSearch(String,Int)
    case GetSection(String)
    case GetNovel(String)
}
extension APIManager:TargetType{
    var baseURL: URL{
        switch self {
        case .GetSearch(_, _):
            return URL(string: "http://zhannei.baidu.com")!
        case .GetSection(_),.GetNovel(_):
            return URL(string: "http://www.37zw.net")!
        }
    }
    
    var path: String{
        switch self {
        case .GetSearch(_, _):
            return "/cse/search"
        case .GetSection(let path),.GetNovel(let path):
            return path
        }
        
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Moya.Task {
        switch self {
         case .GetSearch(let key, let index):
            let params = ["q":key,
                          "p":index,
                          "isNeedCheckDomain":1,
                          "jump":"1",
                          "s":"2041213923836881982"] as [String : Any]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .GetSection(_),.GetNovel(_):
            return .requestPlain
        }
    }
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
    
    var headers: [String : String]?{
        return nil
    }
    
 
}

extension MoyaProvider{
    public final class func myRequestMapping(for endpoint: Endpoint<Target>, closure: RequestResultClosure) {
        if let request = endpoint.urlRequest  {
            Log(message: "\(request.httpMethod!)------\(request.url!)")
        }
       MoyaProvider.defaultRequestMapping(for: endpoint, closure: closure)
    }
}

