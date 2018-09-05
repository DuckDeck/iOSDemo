

//
//  ShadowDownloader.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
enum RangeInfoRequestType:Int{
    case RequestFromCache = 0,RequestFromNet
}

class ShadowDownloader {
    
    init?(LoadingRequest:AVAssetResourceLoadingRequest,rangeModelArray:[ShadowRangeInfo],dataManager:ShadowDataManager) {
        
       
    }
    
    func cancel()  {
        
    }
    
}

struct  ShadowRangeInfo {
    var requestType = RangeInfoRequestType.RequestFromCache
    var requestRange:NSRange
    init(requestType:RangeInfoRequestType,requestRange:NSRange) {
        self.requestType = requestType
        self.requestRange = requestRange
    }
}
