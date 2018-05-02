//
//  SectionInfo.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class SectionInfo: GrandModel {

    var novelId = 0
    var id = 0
    var sectionUrl = ""
    var sectionName = ""
    var sectionContent = ""
    public static func ==(lhs: SectionInfo, rhs: SectionInfo) -> Bool{
        return lhs.sectionUrl == rhs.sectionUrl
    }
    var _sectionAttributeContent:NSAttributedString?
    var sectionAttributeContent:NSAttributedString {
        get{
            if _sectionAttributeContent == nil {
                do{
                    
                    let fontContent = "<p style=\"font-size:\(fontsize)px\" >\(sectionContent)</p>"
                    try? _sectionAttributeContent =   NSAttributedString(data: fontContent.data(using: .unicode)!, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil)
                }
                catch{
                    _sectionAttributeContent = NSAttributedString()
                }
            }
            return _sectionAttributeContent!
        }
    }

}
