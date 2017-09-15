//
//  NovelContentViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
import TangramKit
final class NovelContentViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
    var tb = UITableView()
    var novelInfo:NovelInfo?
    var currentSection : SectionInfo?
    var arrSectionUrl : [SectionInfo]?
    var vm:NovelContentViewModel?
    
    override func loadView() {
        super.loadView()
        self.view = TGFrameLayout(frame: self.view.bounds)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tb.tg_width.equal(.fill)
        tb.tg_height.equal(.fill)
        tb.tg_left.equal(0)
        tb.tg_top.equal(0)
        tb.delegate = self
        tb.estimatedRowHeight = 8000
        tb.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tb)

        
        let buttonSaveBoookmark = UIBarButtonItem(title: "添加书签", style: .plain, target: self, action: #selector(NovelContentViewController.saveBookmark))
        navigationItem.rightBarButtonItem = buttonSaveBoookmark
        
        vm = NovelContentViewModel(input: (tb,novelInfo!,currentSection!,arrSectionUrl!))
        weak var weakself = self
        tb.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            if  !weakself!.vm!.isLoading {
                weakself?.vm?.getNovelContent()
            }
        })
        
        
    }

    func saveBookmark()  {
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

extension NovelContentViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
        guard let dict = navigation.navigationContext as? [String:Any] else { return nil }
        self.init()
       novelInfo = dict["novelInfo"] as? NovelInfo
       currentSection = dict["currentSection"] as? SectionInfo
       arrSectionUrl = dict["arrSectionUrl"] as? [SectionInfo]
    }
}


