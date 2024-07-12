//
//  LogTool.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/11/17.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import Foundation
class LogTool{
//    static let db = Database(withPath: "\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, .userDomainMask, true).first!)/log.db")
    
    init() {

    }
    
    
}

enum logLevel:Int{
    case debug = 0
    case info
    case warn
    case error
    case fatal
}


struct log{
    var time:Date = Date()
    var level = logLevel.info
    var content = ""
    
}


var logs = Logs()

struct Logs{
    static let mar = JinkeyMarsBridge()
    static func log(type:XloggerType, tag:String,content:String){
        mar.log(type, tag: tag, content: content)
    }
}
