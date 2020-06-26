//
//  FiveStroke.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/8.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import GrandStore
import SwiftyJSON
import GrandModel
@objcMembers class FiveStroke: GrandModel { //好像GrandModel的自动保存已经失效？一定要加上@objcMembers才行
    var text = ""
    var spell = ""
    var code = ""
    var imgDecodeUrl = ""

    static let FiveStrokeLog = GrandStore(name: "FiveStrokeLog", defaultValue: [FiveStroke]())
    
    static func getFiveStroke(key:String,completed:@escaping ((_ result:ResultInfo)->Void)){
        let url = "https://lovelive.ink:19996/five/\(key)"
        
        HttpClient.get(url.urlEncoded()).completion { (data, err) in
            var result = ResultInfo(rawData: data)
            if result.code != 0{
                completed(result)
                return
            }
            let fives = JSON(result.data!).arrayValue
            
            var arrFiveStrokes = [FiveStroke]()
            for item in fives{
                let five = FiveStroke()
                five.code = item["FiveCode"].stringValue
                five.text = item["Word"].stringValue
                five.spell = item["PinYin"].stringValue
                five.imgDecodeUrl = item["ImgCode"].stringValue
                arrFiveStrokes.append(five)
            }
            result.data = arrFiveStrokes
            completed(result)
            
        }
    }
}
