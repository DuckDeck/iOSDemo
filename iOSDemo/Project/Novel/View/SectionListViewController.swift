//
//  SectionListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
import SnapKit
import RxSwift
final class SectionListViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
    
    var tb = UITableView()
    var vm:SectionListViewModel?
    var novelInfo:NovelInfo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = novelInfo?.title ?? "" + "的章节"
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        vm = SectionListViewModel(input: (tb,Variable<NovelInfo>(novelInfo!)))
    }
}

