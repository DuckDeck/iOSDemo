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
}
extension APIManager:TargetType{
    var baseURL: URL{
        return URL(string: "http://zhannei.baidu.com/cse/search")!
    }
    
    var path: String{
        switch self {
        case .GetSearch(let key, let index):
            return "q=\( key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&p=\(index)&isNeedCheckDomain=1&jump=1"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Moya.Task {
        return .requestPlain
    }
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
    
    var headers: [String : String]?{
        return nil
    }
}
