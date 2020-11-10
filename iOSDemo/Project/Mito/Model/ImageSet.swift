//
//  ImageSet.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import Kanna
let PCImage = "http://www.tuyiam.com/forum"



class ImageSet:NSObject, NSCoding {
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
    var cellHeight:Float = 0
    var imageType = 0  //0 普通壁纸  1动态壁纸
    var size = 0.0     //文件大小
    var sizeStr = ""     //文件大小
    var duration = 0   //时长
    var durationStr = ""   //时长
    var videoLink = ""
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(resolutionStr, forKey: "resolutionStr")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(theme, forKey: "theme")
        aCoder.encode(mainImage, forKey: "mainImage")
        aCoder.encode(cellHeight, forKey: "cellHeight")
        aCoder.encode(imageType, forKey: "imageType")
        aCoder.encode(size, forKey: "size")
        aCoder.encode(sizeStr, forKey: "sizeStr")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(videoLink, forKey: "videoLink")
        aCoder.encode(durationStr, forKey: "durationStr")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        url = aDecoder.decodeObject(forKey: "url") as! String
        resolutionStr = aDecoder.decodeObject(forKey: "resolutionStr") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String
        theme = aDecoder.decodeObject(forKey: "theme") as! String
        mainImage = aDecoder.decodeObject(forKey: "mainImage") as! String
        cellHeight = aDecoder.decodeFloat(forKey: "cellHeight")
        imageType = Int(aDecoder.decodeInt64(forKey: "imageType"))
        size = aDecoder.decodeDouble(forKey: "size")
        sizeStr = aDecoder.decodeObject(forKey: "sizeStr") as! String
        duration = Int(aDecoder.decodeInt64(forKey: "duration"))
        videoLink = aDecoder.decodeObject(forKey: "videoLink") as! String
        durationStr =  aDecoder.decodeObject(forKey: "durationStr") as! String
    }
    
    static func getImageSet(type:Int,cat:String,resolution:Resolution, theme:String, index:Int,completed:@escaping ((_ result:ResultInfo)->Void)){
       
       
        let url = "\(PCImage)-\(ImageSet.catToUrlPara(str: cat))-\(index).html"
      
     
        HttpClient.get(url).completion { (data, err) in
            var result = ResultInfo()
            if err != nil{
                result.code = -1
                result.message = err!.localizedDescription
                completed(result)
                return
            }
            var doc:HTMLDocument?
            do {
                let codeing = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                let str = NSString(data: data!, encoding: codeing)
                doc = try HTML(html: str! as! String, encoding: .utf8)
            }
            catch{
                result.code = 10
                result.message = error.localizedDescription
                completed(result)
                return

            }

           
            let uls = doc!.xpath("//li//div//a")
            if uls.count <= 0{
                result.data = [ImageSet]()
                completed(result)
                return
            }
           
            var arrImageSets = [ImageSet]()
       
            for ul in uls{
                let img = ImageSet()
                if let imgHtml = ul.css("img").first{
                    img.mainImage = imgHtml["src"] ?? ""
                    img.title = ul["title"] ?? ""
                    img.url = ul["href"] ?? ""
                    if !img.url.hasPrefix("http"){
                        img.url = "http://www.tuyiam.com/" + img.url
                    }
                 
                    img.cellHeight = Float(ScreenWidth / 2 - 10)  * 2

                    arrImageSets.append(img)
                }
                
            }
            
            result.data = arrImageSets
            completed(result)
        }
    }
    
    static func getImageSetList(url:String,completed:@escaping ((_ result:ResultInfo)->Void))  {
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
            if url.contain(subStr: "pic"){ //精选一图
                guard let oneImage = doc.xpath("//a[@class='photo-a']").first else{
                    result.data = [ImageSet]()
                    completed(result)
                    return
                }
                let imgSrc = oneImage.css("img").first!["src"]!
                result.data = [imgSrc]
                completed(result)
                
            }
            else{
                guard let oneImage = doc.xpath("//div[@class='img-box']").first else{
                    result.data = [ImageSet]()
                    completed(result)
                    return
                }
                let imgs = oneImage.css("div >a")
                var arrImgs = [String]()
                for img in imgs{
                    var url = img.css("img").first!["src"]!
                    if !url.contain(subStr: "wechatpc")
                    {
                        if url.hasPrefix("//"){
                            url = "http:" + url
                        }
                        arrImgs.append(url)
                    }
                }
                result.data = arrImgs
                completed(result)
            }
           
            
            
        }
    }
    
  
    
    static func searchMito(key:String,index:Int,completed:@escaping ((_ result:ResultInfo)->Void)){     
        let url = "http://www.5857.com/index.php?m=search&c=index&a=init&typeid=3&q=\(key)&page=\(index)".urlEncoded()
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
                if img.mainImage.hasPrefix("//"){
                    img.mainImage = "http:" + img.mainImage
                }
                img.title = ul.css("div > a > span")[0].text ?? ""
                img.url = ul.css("div > a")[0]["href"] ?? ""
                if img.url.hasPrefix("//"){
                    img.url = "http:" + img.url
                }
                img.resolution = Resolution(resolution: ul.css("div > span > a")[0].text ?? "")
                if img.resolution.isEmpty{
                   img.resolution = Resolution.StandardPhoneResolution
                }
                img.resolutionStr = img.resolution.toString()
                img.theme = ul.css("div > span")[1].text ?? ""
                img.cellHeight = Float(ScreenWidth / 2 - 10) / Float(img.resolution.ratio) + 70.0
                arrImageSets.append(img)
            }
            let mitoCount = doc.xpath("//a[@class='a1']")
            if mitoCount.count <= 0{
                result.count = arrImageSets.count
            }
            else{
                if let count = mitoCount.first!.text?.filteToInt(filter: .ForwardFilter){
                    result.count = count
                }
                else{
                    result.count = arrImageSets.count
                }
            }
            result.data = arrImageSets
            completed(result)
        }
    }
    
  
    

    
    static func catToUrlPara(str:String)->Int{
        switch str {
            case "秀人网": return 31
            case "美嫒錧": return 35
            case "兔几盟": return 32
            case "魅妍社": return 37
        default:
            return 0
        }
    }
    

    

}

extension String{
    func toColor() -> UIColor {
        switch self {
            case "红色": return UIColor.red
             case "橙色": return UIColor.orange
             case "黄色": return UIColor.yellow
             case "绿色": return UIColor.green
             case "紫色": return UIColor.purple
             case "粉色": return UIColor.red
             case "青色": return UIColor.cyan
             case "蓝色": return UIColor.blue
             case "棕色": return UIColor.brown
            case "白色": return UIColor.white
            case "银色": return UIColor.silver
            case "灰色": return UIColor.gray
        default:
            return UIColor.white
        }
    }
}


