//
//  SectionListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
final class SectionListViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }

      var tb = UITableView()
    
}
extension SectionListViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
        guard let novel = navigation.navigationContext as? NovelInfo else { return nil }
        Log(message: novel)
        self.init()
        
    }
}
