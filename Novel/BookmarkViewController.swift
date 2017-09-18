//
//  BookmarkViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
import TangramKit

final class BookmarkViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }

    var tb = UITableView()
    var vm:BookMarkViewModel?
    override func loadView() {
        super.loadView()
        self.view = TGFrameLayout(frame: self.view.bounds)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "书签"
        tb.tg_width.equal(.fill)
        tb.tg_height.equal(.fill)
        tb.tg_left.equal(0)
        tb.tg_top.equal(0)
        tb.tableFooterView = UIView()
        
        tb.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tb)
        vm = BookMarkViewModel(tb: tb)
    }
}

extension BookmarkViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
//        guard let _ = navigation.url.urlValue else { return nil }
        self.init()
    }
}


