//
//  SectionTableInfo.swift
//  iOSDemo
//
//  Created by Stan Hu on 18/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import RxDataSources

struct SectionTableInfo {
    var header: String
    var items: [Item]
}

extension SectionTableInfo : AnimatableSectionModelType {
    typealias Item = SectionInfo
    
    var identity: String {
        return header
    }
    
    init(original: SectionTableInfo, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SectionInfo:IdentifiableType{
    var identity: String {
        return sectionName
    }
}

