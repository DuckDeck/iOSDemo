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
        vm.tb = tb
        vm.bind()
        
        tb.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.vm.requestNewDataCommond.onNext(true)
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



class NovelTbCell: UITableViewCell {
    let imgNovel = UIImageView()
    let lblTitle = UILabel()
    let lblIntro = UILabel()
    let lblAuthor = UILabel()
    let lblType = UILabel()
    let lblUpdateTime = UILabel()
    var novelIndo:NovelInfo?{
        didSet{
            imgNovel.kf.setImage(with: URL(string: novelIndo!.img)!)
            lblTitle.text = novelIndo?.title
            lblIntro.text = novelIndo?.Intro
            lblAuthor.text = novelIndo?.author
            lblType.text = novelIndo?.novelType
            lblUpdateTime.text = novelIndo?.updateTimeStr
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imgNovel.frame = CGRect(x: 10, y: 10, width: 100, height: 140)
        contentView.addSubview(imgNovel)
        lblTitle.setFont(font: 16).setFrame(frame: CGRect(x: 120, y: 12, width: ScreenWidth - 130, height: 20)).addTo(view: contentView).completed()
        lblIntro.lineNum(num: 3).setFont(font: 13).setFrame(frame: CGRect(x: lblTitle.frame.origin.x, y: lblTitle.frame.origin.y + 25, width: lblTitle.frame.size.width, height: 45)).addTo(view: contentView).completed()
        lblAuthor.setFont(font: 13).setFrame(frame: CGRect(x: lblTitle.frame.origin.x, y: lblIntro.frame.origin.y + 48, width: lblTitle.frame.size.width, height: 20)).addTo(view: contentView).completed()
        lblType.setFont(font: 13).setFrame(frame: CGRect(x: lblTitle.frame.origin.x, y: lblAuthor.frame.origin.y + 22, width: lblTitle.frame.size.width, height: 20)).addTo(view: contentView).completed()
        lblUpdateTime.setFont(font: 13).setFrame(frame: CGRect(x: lblTitle.frame.origin.x, y: lblType.frame.origin.y + 22, width: lblTitle.frame.size.width, height: 20)).addTo(view: contentView).completed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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


