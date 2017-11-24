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



func ChineseToPinyin(chinese:String)->String{
    let py = NSMutableString(string: chinese)
    CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
    CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
    return py as String
}

func handleResult(result:ResultInfo) -> Bool {
    return handleResult(result: result, needHideWait: true)
}

func handleResult(result:ResultInfo,needHideWait:Bool) -> Bool {
    if needHideWait {
        GrandCue.dismissLoading()
    }
    
    if result.code != 0 {
        GrandCue.showToast(msg: result.msg)
        return false
    }
    return true
}
