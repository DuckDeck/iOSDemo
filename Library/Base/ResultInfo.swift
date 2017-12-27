//
//  ResultInfo.swift
//  Novel
//
//  Created by Stan Hu on 21/7/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
typealias completed = (_ result:ResultInfo)->Void
struct ResultInfo {
    var code = 0
    var message = ""
    var data:Any?
    var count = 0
}



func handleResult(result:ResultInfo) -> Bool {
    return handleResult(result: result, needHideWait: true)
}

func handleResult(result:ResultInfo,needHideWait:Bool) -> Bool {
    if needHideWait {
        GrandCue.dismissLoading()
    }
    
    if result.code != 0 {
        GrandCue.toast(result.message )
        return false
    }
    return true
}
