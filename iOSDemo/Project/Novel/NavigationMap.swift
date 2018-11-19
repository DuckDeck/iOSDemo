//
//  NavigationMap.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
struct  NavigationMap{
    static func initialize(){
        let nav = Navigator()
        nav.register(Routers.bookmark) { (url, values, context) -> UIViewController? in
            return BookmarkViewController()
        }
        
        nav.register(Routers.sectionList) { (url, values, context) -> UIViewController? in
            let vc = SectionListViewController()
            if let novel = context as? NovelInfo{
                vc.novelInfo = novel
            }
           return  SectionListViewController()
        }
        
        nav.register(Routers.novelContent) { (url, values, context) -> UIViewController? in
            let vc = NovelContentViewController()
            if let dict = context as? [String:Any] {
                vc.novelInfo = dict["novelInfo"] as? NovelInfo
                vc.currentSection = dict["currentSection"] as? SectionInfo
                vc.arrSectionUrl = dict["arrSectionUrl"] as? [SectionInfo]
            }
            return vc
        }

    }
    private static func alert(navigator: NavigatorType) -> URLOpenHandlerFactory {
        return { url, values, context in
            guard let title = url.queryParameters["title"] else { return false }
            let message = url.queryParameters["message"]
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            navigator.present(alertController)
            return true
        }
    }



}
