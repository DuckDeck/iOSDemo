//
//  BookmarkViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
final class BookmarkViewController: UIViewController {

    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }


}

extension BookmarkViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
        guard let URLVaue = navigation.url.urlValue else { return nil }
        self.init()

    }
}
