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
        Navigator.map(Routers.bookmark, BookmarkViewController.self)
        Navigator.map(Routers.sectionList, SectionListViewController.self)
        Navigator.map(Routers.novelContent, NovelContentViewController.self)
        Navigator.map("navigator://alert", self.alert)

//        Navigator.map("", {(url,values)->Bool in
//            return true
//        })

    }
    
    private static func alert(URL: URLConvertible, values: [String: Any]) -> Bool {
        let title = URL.queryParameters["title"]
        let message = URL.queryParameters["message"]
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        Navigator.present(alertController)
        return true
    }

}
