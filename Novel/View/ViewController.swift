//
//  ViewController.swift
//  Novel
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import URLNavigator
import MJRefresh
class ViewController: UIViewController {
    let txtSearch = UITextField()
    let btnSearch = UIButton()
    let tb = UITableView()
    
    var vm : NovelSearchViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         weak var wkself = self
        view.backgroundColor = UIColor.white
        navigationItem.title = "搜索小说"
        
        txtSearch.setFrame(frame:  CGRect(x: 5, y: NavigationBarHeight + 5, width: ScreenWidth - 60, height: 30)).borderColor(color: UIColor.lightGray).borderWidth(width: 1).addTo(view: view).completed()
        txtSearch.placeholder = "输入书名搜索"
        txtSearch.addOffsetView(value: 10)
        btnSearch.setFrame(frame:  CGRect(x: ScreenWidth - 55, y: NavigationBarHeight + 5, width: 55, height: 30)).title(title: "搜索").color(color: UIColor.blue).setFont(font: 16).addTo(view: view).completed()
        txtSearch.text = "星辰变"
        txtSearch.returnKeyType = .search
        tb.setFrame(frame: CGRect(x: 0, y: NavigationBarHeight + 40, width: ScreenWidth, height: ScreenHeight - 40 - NavigationBarHeight)).addTo(view: view).completed()
        tb.estimatedRowHeight = 160
        tb.rowHeight = UITableViewAutomaticDimension
        vm = NovelSearchViewModel(input: (tb,txtSearch.rx.text.orEmpty.asDriver(),btnSearch.rx.tap.asDriver()))
        
        txtSearch.rx.controlEvent([.editingDidEndOnExit]).subscribe(onNext: {
            wkself?.tb.mj_header.beginRefreshing()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: vm!.bag)
        
        
       
        
        tb.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            wkself?.vm?.requestNewDataCommond.onNext(true)
        })
        
        tb.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            wkself?.vm?.requestNewDataCommond.onNext(false)
        })
        
       tb.mj_header.beginRefreshing()
        
//        let buttonSaveBoookmark = UIBarButtonItem(title: "查看书签", style: .plain, target: self, action: #selector(ViewController.checkBookmark))
//        navigationItem.rightBarButtonItem = buttonSaveBoookmark
        
    }


//    @objc func checkBookmark() {
//       _ =  (UIApplication.shared.delegate as! AppDelegate).navigator?.push(Routers.bookmark, context: nil, from: nil, animated: true)
//    }
}


