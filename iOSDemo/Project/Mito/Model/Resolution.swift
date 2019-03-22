//
//  Resolution.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

struct Resolution {
    var pixelX = 0
    var pixelY = 0
    var device = ""
    var resolutionCode = ""
    
    init() {
        
    }
    
    init(resolution:String) {
        var res = resolution.split("x")
        if (resolution.contains("x")){
            res = resolution.split("x") // it's rediculous, because x and × is not the same
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
    
    func toUrlPara() ->String {
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
        else if(pixelX == 1024 && pixelY == 768){
            return  "3427"
        }
        return "0"
    }
    
}
