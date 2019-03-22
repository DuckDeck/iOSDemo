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
    
    static func getImageSet(type:Int,cat:String,resolution:Resolution, theme:String, index:Int,size:Int,complated:((_ result:ResultInfo)->Void)){
        var baseUrl = PCImage
        switch type {
        case 1:
            baseUrl = PadImage
        case 2:
            baseUrl = PhoneImage
        case 3:
            baseUrl = EssentialImage
        default:
            break
        }
        let url = "\(baseUrl)-\(ImageSet.themeToUrlPara(str: theme))-\(ImageSet.catToUrlPara(str: cat))-0-"
    }
    
    static func catToUrlPara(str:String)->Int{
        switch str {
            case "全部": return 0
            case "美女": return 3365
            case "性感": return 3437
            case "明星": return 3366
            case "风光": return 3367
            case "卡通": return 3368
            case "创意": return 3370
            case "汽车": return 3371
            case "游戏": return 3372
            case "建筑": return 3373
            case "影视": return 3374
            case "植物": return 3376
            case "动物": return 3377
            case "节庆": return 3378
            case "可爱": return 3379
            case "静物": return 3369
            case "体育": return 3380
            case "日历": return 3424
            case "唯美": return 3430
            case "其它": return 3431
            case "系统": return 3434
            case "动漫": return 3444
            case "非主流": return 3375
            case "小清新": return 3381
        default:
            return 0
        }
    }
    
    static func themeToUrlPara(str:String)->Int{
        switch str {
         case "全部": return 0
         case "红色": return 3383
         case "橙色": return 3384
         case "黄色": return 3385
         case "绿色": return 3386
         case "紫色": return 3387
         case "粉色": return 3388
         case "青色": return 3389
         case "蓝色": return 3390
         case "棕色": return 3391
         case "白色": return 3392
         case "黑色": return 3393
         case "银色": return 3394
         case "灰色": return 3395
        default:
            return 0
        }
    }
}
