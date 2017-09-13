//
//  NovelInfo.swift
//  iOSDemo
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
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
    
    static func searchNovel(key:String, index:Int,cb:@escaping ((_ novels:[NovelInfo])->Void)){
        var arrVovels = [NovelInfo]()
        guard let url = URL(string: "http://zhannei.baidu.com/cse/search?s=2041213923836881982&q=\( key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&p=\(index)&isNeedCheckDomain=1&jump=1") else{
            cb(arrVovels)
            return
        }
        Alamofire.request(url).response { (res) in
            guard let doc =  HTML(html: res.data!, encoding: .utf8) else{
                cb(arrVovels)
                return
            }
            let divs = doc.xpath("//div[@class='result-item result-game-item']")
            if divs.count <= 0{
                cb(arrVovels)
                return
            }
            //issue 不能用乱用xpath，因为xpath无论从哪获取，都是获取全局的，要想获取子类型一定要用css
            for link in divs{
                let novel = NovelInfo()
                let title = link.css("div > h3 > a").first
                novel.title = title?["title"] ?? ""
                novel.img = link.css("div > a > img").first?["src"] ?? ""
                novel.Intro = link.css("div > p").first?.text ?? ""
                novel.url = title?["href"] ?? ""
                let tags = link.css("div > div > p")
                novel.author = tags[0].css("span")[1].text ?? ""
                novel.author = novel.author.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
                novel.novelType = tags[1].css("span")[1].text ?? ""
                novel.updateTimeStr = tags[2].css("span")[1].text ?? ""
                novel.id = novel.url.hashValue
                arrVovels.append(novel)
            }
            cb(arrVovels)
        }
    }
    
//    static func getNocelSection(url:String,cb:@escaping ((_ sections:[SectionInfo])->Void)){
//        var arrSections = [SectionInfo]()
//        guard let url = URL(string: url) else{
//            cb(arrSections)
//            return
//        }
//        
//        
//        Alamofire.request(url).response { (res) in
//            let code  = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
//            let str = String(data: res.data!, encoding: String.Encoding(rawValue: code))
//            guard let doc =  HTML(html: str!, encoding: .utf8) else{
//                cb(arrSections)
//                return
//            }
//            let dds = doc.xpath("//div[@id='list']").first!.css("dl > dd")
//            if dds.count <= 0{
//                cb(arrSections)
//                return
//            }
//            for d in dds{
//                let section = SectionInfo()
//                section.sectionName = d.css("a").first?.text ?? ""
//                section.sectionUrl = d.css("a").first?["href"] ?? ""
//                section.id = section.sectionUrl.hash
//                arrSections.append(section)
//            }
//            cb(arrSections)
//        }
//    }



}
