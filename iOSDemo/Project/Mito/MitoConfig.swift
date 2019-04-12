//
//  MitoConfig.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/3.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import GrandStore
class MitoConfig  {
    static let CollectedMito = GrandStore(name: "CollectedMito", defaultValue: [ImageSet]())
    static let HotSearchMito = GrandStore(name: "HotSearchMito", defaultValue: [String]())
    
    static func collect(imageSet:ImageSet){
        var items = CollectedMito.Value!
        items.append(imageSet)
        CollectedMito.Value = items
    }
    
    static func remove(imageSet:ImageSet){
        var items = CollectedMito.Value!
        items.removeWith { (item) -> Bool in
            return item.url == imageSet.url
        }
        CollectedMito.Value = items
    }
    
    static func isContain(imageSet:ImageSet) -> Bool {
        return CollectedMito.Value!.contains(where: { (item) -> Bool in
            return item.url == imageSet.url
        })
    }
    
}
