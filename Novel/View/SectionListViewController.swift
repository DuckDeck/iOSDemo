//
//  SectionListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
import TangramKit
import RxSwift
final class SectionListViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
    
    var tb = UITableView()
    var vm:SectionListViewModel?
    var novelInfo:NovelInfo?
    
    override func loadView() {
        super.loadView()
        self.view = TGFrameLayout(frame: self.view.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = novelInfo?.title ?? "" + "的章节"
        tb.tg_width.equal(.fill)
        tb.tg_height.equal(.fill)
        tb.tg_left.equal(0)
        tb.tg_top.equal(0)
        view.addSubview(tb)
      
        vm = SectionListViewModel(input: (tb,Variable<NovelInfo>(novelInfo!)))
        
    }
}
extension SectionListViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
        guard let novel = navigation.navigationContext as? NovelInfo else { return nil }
        self.init()
        novelInfo = novel
    }
}
