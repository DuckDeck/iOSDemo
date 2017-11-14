//
//  HttpManager.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import Alamofire
class HttpManager{

    fileprivate var url:String!
    fileprivate var method:HTTPMethod!
    fileprivate var params:Dictionary<String,AnyObject>?

    fileprivate  var requestOptions:Dictionary<String,AnyObject>?
    fileprivate  var headers:Dictionary<String,AnyObject>?
//    fileprivate var progress:((_ progress:Float)->())?
    fileprivate var completedBlock:((_ data:Data?,_ error:Error?)->Void)?
    open static func get(_ url:String)->HttpManager{
        let m = HttpManager()
        m.url = url
        m.method = .get
        return m
    }
   
    open func addParams(_ params:Dictionary<String,AnyObject>?)->HttpManager{
        self.params = params
        return self
    }
    
    open func addHeaders(_ params:Dictionary<String,AnyObject>?)->HttpManager{
        self.headers = params
        return self
    }
    
    open func completion(_ completion:((_ data:Data?,_ error:Error?)->Void)?){
        self.completedBlock = completion
        Alamofire.request(url, method: method, parameters: params).responseData {  (data) in
            self.completedBlock?(data.data,data.error)
        }
    
    }

    
}


