//
//  ImageSet.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import Kanna
let PCImage = "http://www.5857.com/list-9"
let PadImage = "http://www.5857.com/list-10"
let PhoneImage = "http://www.5857.com/list-11"
let EssentialImage = "http://www.5857.com/list-37"



class ImageSet:BaseModel {
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
    
    static func getImageSet(type:Int,cat:String,resolution:Resolution, theme:String, index:Int,completed:@escaping ((_ result:ResultInfo)->Void)){
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
        var url = "\(baseUrl)-\(ImageSet.themeToUrlPara(str: theme))-\(ImageSet.catToUrlPara(str: cat))-0-\(resolution.toUrlPara())-0-\(index).html"
        if type == 1{
            url = "\(baseUrl)-\(ImageSet.themeToUrlPara(str: theme))-\(ImageSet.catToUrlPara(str: cat))-\(resolution.toUrlPara())-0-0-\(index).html"
        }
        if type == 2{
            url = "\(baseUrl)-\(ImageSet.themeToUrlPara(str: theme))-\(ImageSet.catToUrlPara(str: cat))-0-0-\(resolution.toUrlPara())-\(index).html"
        }
        Log(message: url)
        HttpClient.get(url).completion { (data, err) in
            var result = ResultInfo()
            if err != nil{
                result.code = -1
                result.message = err!.localizedDescription
                completed(result)
                return
            }
            guard let doc = try? HTML(html: data!, encoding: .utf8) else{
                result.code = 10
                result.message = "解析HTML错误"
                completed(result)
                return
            }
            let uls = doc.xpath("//ul[@class='clearfix']")
            if uls.count <= 0{
                result.data = [ImageSet]()
                completed(result)
                return
            }
            var arrImageSets = [ImageSet]()
            let lis = uls.first!.css("li")
            for ul in lis{
                let img = ImageSet()
                img.category = ul.css("div > em > a")[0].text ?? ""
                img.mainImage = ul.css("div > a > img")[0]["src"] ?? ""
                img.title = ul.css("div > a > span")[0].text ?? ""
                img.url = ul.css("div > a")[0]["href"] ?? ""
                img.resolution = Resolution(resolution: ul.css("div > span > a")[0].text ?? "")
                img.theme = ul.css("div > span")[1].text ?? ""
                img.cellHeight = (ScreenWidth / 2 - 10) / CGFloat(img.resolution.ratio) + 60.0
                arrImageSets.append(img)
            }
            result.data = arrImageSets
            completed(result)
        }
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
