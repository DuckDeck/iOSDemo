//
//  NovelInfo.swift
//  iOSDemo
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
class NovelInfo: GrandModel {
    var id = 0
    var img = ""
    var url = ""
    var title = ""
    var Intro = ""
    var author = ""
    var novelType = ""
    var updateTimeStr = ""
    var sectionIds:[Int]?
//    var arrBookMark:[SectionInfo]?
    
    public static func ==(lhs: NovelInfo, rhs: NovelInfo) -> Bool{
        return lhs.url == rhs.url
    }
}


