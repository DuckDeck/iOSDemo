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
    
}
