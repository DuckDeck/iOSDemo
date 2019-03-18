//
//  ImageSet.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
let PCImage = "http://www.5857.com/list-9"
let PadImage = "http://www.5857.com/list-10"
let PhoneImage = "http://www.5857.com/list-11"
let EssentialImage = "http://www.5857.com/list-37"



class ImageSet {
    var url = ""
    var category = ""
    var title = ""
    var mainTag = ""
    var tags = [String]()
    var resolution:Resolution!
    var resolutionStr:String = ""
    var theme = ""
    var mainImage = ""
    var images = [String]()
    var count = 0
    var imgBelongCat = 0
    var isCollected = false
    var hashId = 0
}
