//
//  Resolution.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

struct Resolution:Equatable,Codable {
    var pixelX = 0
    var pixelY = 0
    var device = ""
    var resolutionCode = ""
    
    static func ==(lhs:Resolution,rhs:Resolution)->Bool{
        return lhs.pixelX == rhs.pixelX && lhs.pixelY == rhs.pixelY
    }
    
    static let ComputorResolutions = [Resolution(resolution: "3840x1200"),
                                        Resolution(resolution: "3200x2400"),
                                        Resolution(resolution: "2880x1800"),
                                        Resolution(resolution: "2560x1600"),
                                        Resolution(resolution: "2560x1440"),
                                        Resolution(resolution: "1920x1200"),
                                        Resolution(resolution: "1920x1080"),
                                        Resolution(resolution: "1680x1050"),
                                        Resolution(resolution: "1600x1200"),
                                        Resolution(resolution: "1600x900"),
                                        Resolution(resolution: "1366x768"),
                                        Resolution(resolution: "1280x1024"),
                                        Resolution(resolution: "1280x800"),
                                        Resolution(resolution: "1024x768"),]
    
    
    static let PadResolutions = [Resolution(resolution: "2048x2048"),
                                      Resolution(resolution: "2048x1536"),
                                      Resolution(resolution: "1024x1024"),
                                      Resolution(resolution: "1024x768"),
                                      Resolution(resolution: "800x600")]
    
    static let PhoneResolutions = [Resolution(resolution: "2436x1125"),
                                      Resolution(resolution: "1080x1920"),
                                      Resolution(resolution: "768x1280"),
                                      Resolution(resolution: "744x1392"),
                                      Resolution(resolution: "720x1280"),
                                      Resolution(resolution: "640x1136"),
                                      Resolution(resolution: "640x960"),
                                      Resolution(resolution: "540x960"),
                                      Resolution(resolution: "480x854"),
                                      Resolution(resolution: "480x800"),
                                      Resolution(resolution: "360x640"),
                                      Resolution(resolution: "320x480"),
                                      Resolution(resolution: "240x320"),
                                      Resolution(resolution: "2160x1920"),
                                      Resolution(resolution: "1600x1280"),
                                      Resolution(resolution: "1440x1280"),
                                      Resolution(resolution: "1080x1800"),
                                      Resolution(resolution: "960x854"),
                                      Resolution(resolution: "960x800"),
                                      Resolution(resolution: "800x1280"),]
    
    var ratio:Double{
        return Double(pixelX) / Double(pixelY)
    }
    
    init() {
        
    }
    
    var isEmpty:Bool{
        return pixelX == 0 || pixelY == 0
    }
    
    static let StandardComputorResolution = Resolution(resolution: "1920x1080")
    static let StandardPhoneResolution = Resolution(resolution: "1080x1920")
    static let StandardPadResolution = Resolution(resolution: "2048x1536")
    
    init(resolution:String) {
        var reso = resolution
        if reso.contain(subStr: "("){
            reso = reso.split("(").first!
        }
        
        var res = reso.split("x")
        if (reso.contains("×")){
            res = resolution.split("×") // it's rediculous, because x and × is not the same
        }
        if (res.count == 1)
        {
            pixelX = res[0].toInt() ?? 0
        }
        else if (res.count == 2) {
            pixelX = res[0].toInt() ?? 0
            pixelY = res[1].toInt() ?? 0
        }
    }
    
    func toString() ->String {
        if pixelX <= 0 && pixelY <= 0 {
            return "全部"
        }
        return "\(pixelX)x\(pixelY)"
    }
    //0电脑 1 平板 2 手机
    func toUrlPara(type:Int = 0) ->String {
        if pixelX == 0 && pixelY == 0 {
            return "0"
        }
        else if pixelX == 3840 && pixelY == 1200{
             return  "3440"
        }
        else if(pixelX == 3200 && pixelY == 2400){
            return  "3441"
        }
        else if(pixelX == 2880 && pixelY == 1800){
            return  "3442"
        }
        else if(pixelX == 2560 && pixelY == 1600){
            return  "3394"
        }
        else if(pixelX == 1920 && pixelY == 1200){
            return  "3395"
        }
        else if(pixelX == 1920 && pixelY == 1080){
            return  "3440"
        }
        else if(pixelX == 1680 && pixelY == 1050){
            return  "3397"
        }
        else if(pixelX == 1600 && pixelY == 1200){
            return  "3432"
        }
        else if(pixelX == 1600 && pixelY == 900){
            return  "3398"
        }
        else if(pixelX == 1440 && pixelY == 900){
            return  "3399"
        }
        else if(pixelX == 1366 && pixelY == 768){
            return  "3400"
        }
        else if(pixelX == 1280 && pixelY == 1024){
            return  "3401"
        }
        else if(pixelX == 1280 && pixelY == 800){
            return  "3402"
        }
        else if(pixelX == 1024 && pixelY == 768 && type == 0){
            return  "3427"
        }
        
        else if(pixelX == 2048 && pixelY == 2048){
            return  "3409"
        }
        else if(pixelX == 1024 && pixelY == 1024){
            return  "3410"
        }
        else if(pixelX == 2048 && pixelY == 1536){
            return  "3438"
        }
        else if(pixelX == 1024 && pixelY == 768 && type == 1){
            return  "3426"
        }
        else if(pixelX == 800 && pixelY == 600){
            return  "3433"
        }
        else if(pixelX == 2436 && pixelY == 1125){
            return  "3454"
        }
        else if(pixelX == 1080 && pixelY == 1920){
            return  "3445"
        }
        else if(pixelX == 768 && pixelY == 1280){
            return  "3412"
        }
        else if(pixelX == 744 && pixelY == 1392){
            return  "3443"
        }
        else if(pixelX == 720 && pixelY == 1280){
            return  "3413"
        }
        else if(pixelX == 640 && pixelY == 1136){
            return  "3414"
        }
        else if(pixelX == 640 && pixelY == 960){
            return  "3415"
        }
        else if(pixelX == 540 && pixelY == 960){
            return  "3417"
        }
        else if(pixelX == 480 && pixelY == 854){
            return  "3418"
        }
        else if(pixelX == 480 && pixelY == 800){
            return  "3454"
        }
        else if(pixelX == 360 && pixelY == 640){
            return  "3416"
        }
        else if(pixelX == 320 && pixelY == 480){
            return  "3420"
        }
        else if(pixelX == 240 && pixelY == 320){
            return  "3421"
        }
        else if(pixelX == 2160 && pixelY == 1920){
            return  "3448"
        }
        else if(pixelX == 1600 && pixelY == 1280){
            return  "3447"
        }
        else if(pixelX == 1440 && pixelY == 1280){
            return  "3449"
        }
        else if(pixelX == 1080 && pixelY == 1800){
            return  "3446"
        }
        else if(pixelX == 960 && pixelY == 854){
            return  "3450"
        }
        else if(pixelX == 960 && pixelY == 800){
            return  "3451"
        }
        else if(pixelX == 800 && pixelY == 1280){
            return  "3411"
        }
        
        
        
        
        return "0"
    }
}
