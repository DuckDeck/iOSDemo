//
//  NovelContentViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
import RxSwift
import MJRefresh
import SnapKit
final class NovelContentViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
    var tb = UITableView()
    var novelInfo:NovelInfo?
    var currentSection : SectionInfo?
    var arrSectionUrl : [SectionInfo]?
    var vm:NovelContentViewModel?
    fileprivate let bag = DisposeBag()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        tb.delegate = self
        tb.estimatedRowHeight = 8000
        tb.separatorStyle = .none
        tb.allowsSelection = false
        tb.rowHeight = UITableView.automaticDimension
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        let buttonSaveBoookmark = UIBarButtonItem(title: "添加书签", style: .plain, target: self, action: #selector(NovelContentViewController.saveBookmark))
        navigationItem.rightBarButtonItem = buttonSaveBoookmark
        
        vm = NovelContentViewModel(input: (tb,novelInfo!,currentSection!,arrSectionUrl)) //暂时没想出以构造函数的方式绑定
        vm?.sectionTitle.asDriver().drive(navigationItem.rx.title).disposed(by: bag)
        weak var weakself = self
        tb.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            if  !weakself!.vm!.isLoading {
                weakself?.vm?.getNovelContent()
            }
        })
        
    }

    @objc func saveBookmark()  {
        vm?.saveBookmark()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}


extension NovelContentViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if vm!.isLoadAll {
            return
        }
        if indexPath.row >= vm!.arrSection.value.count - 1 && !vm!.isLoading {
            vm?.getNovelContent()
        }
    }
}

//extension NovelContentViewController:URLNavigable{
//    convenience init?(navigation: Navigation) {
//        guard let dict = navigation.navigationContext as? [String:Any] else { return nil }
//        self.init()
//       novelInfo = dict["novelInfo"] as? NovelInfo
//       currentSection = dict["currentSection"] as? SectionInfo
//       arrSectionUrl = dict["arrSectionUrl"] as? [SectionInfo]
//    }
//}


