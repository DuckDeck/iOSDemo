//
//  ViewController.swift
//  Novel
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
class ViewController: UIViewController {
    let txtSearch = UITextField()
    let btnSearch = UIButton()
    let tb = UITableView()

    var index = 0
    var key = ""
    var isLoadAll = false
    var isLoading = false
    
    let vm = NovelSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.title = "搜索小说"
        
        txtSearch.setFrame(frame:  CGRect(x: 5, y: NavigationBarHeight + 5, width: ScreenWidth - 60, height: 30)).borderColor(color: UIColor.lightGray).borderWidth(width: 1).addTo(view: view).completed()
        txtSearch.placeholder = "输入书名搜索"
        txtSearch.addOffsetView(value: 10)
        btnSearch.setFrame(frame:  CGRect(x: ScreenWidth - 55, y: NavigationBarHeight + 5, width: 55, height: 30)).title(title: "搜索").color(color: UIColor.blue).setFont(font: 16).addTo(view: view).completed()
        txtSearch.text = "星辰变"
        tb.setFrame(frame: CGRect(x: 0, y: NavigationBarHeight + 40, width: ScreenWidth, height: ScreenHeight - 40 - NavigationBarHeight)).addTo(view: view).completed()
        tb.estimatedRowHeight = 60
        tb.rowHeight = UITableViewAutomaticDimension
        vm.tb = tb
        vm.key = "完美"
        vm.bind()
        
        tb.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.vm.requestNewDataCommond.onNext(true)
        })
        
        tb.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.vm.requestNewDataCommond.onNext(false)
        })
        
       tb.mj_header.beginRefreshing()
        
        
        let buttonSaveBoookmark = UIBarButtonItem(title: "查看书签", style: .plain, target: self, action: #selector(ViewController.checkBBookmark))
        navigationItem.rightBarButtonItem = buttonSaveBoookmark
        
    }


    


    
    func checkBBookmark() {
//        let vc = BookmarkViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }
    


}



class LoadMoreCell: UITableViewCell {
    var spin = UIActivityIndicatorView()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        spin.center = contentView.center
        contentView.addSubview(spin)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


