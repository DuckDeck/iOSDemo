//
//  Settings.swift
//  TouchTest
//
//  Created by Tyrant on 6/5/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//
import GrandStore
import UIKit
var scale:Float{
    if UIScreen.main.bounds.width  > 400
    {
        return 2.6
    }
    return 2
}
class Settings {
   static var needShowTrace = GrandStore<Bool>(name: "needShowTrace",defaultValue: true)
   static var needKeepTrace = GrandStore<Bool>(name: "needKeepTrace",defaultValue: true)
   static var needShowCoordinate = GrandStore<Bool>(name: "needShowCoordinate",defaultValue: false)
   static var traceThickness = GrandStore<Float>(name: "traceThickness", defaultValue: 1)
   static var maxSupportTouches = GrandStore<Int>(name: "maxSupportTouches", defaultValue: 1)
}


