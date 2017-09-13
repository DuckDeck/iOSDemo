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
    var arrNovel = [NovelInfo]()
    var index = 0
    var key = ""
    var isLoadAll = false
    var isLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.title = "搜索小说"
        
        
        txtSearch.setFrame(frame:  CGRect(x: 5, y: NavigationBarHeight + 5, width: ScreenWidth - 60, height: 30)).borderColor(color: UIColor.lightGray).borderWidth(width: 1).addTo(view: view).completed()
        txtSearch.placeholder = "输入书名搜索"
        txtSearch.addOffsetView(value: 10)
        btnSearch.setFrame(frame:  CGRect(x: ScreenWidth - 55, y: NavigationBarHeight + 5, width: 55, height: 30)).title(title: "搜索").color(color: UIColor.blue).setFont(font: 16).setTarget(self, action: #selector(ViewController.searchNovel(sender:))).addTo(view: view).completed()
        //        txtSearch.text = "星辰变"
        tb.setFrame(frame: CGRect(x: 0, y: NavigationBarHeight + 40, width: ScreenWidth, height: ScreenHeight - 40 - NavigationBarHeight)).addTo(view: view).completed()
        tb.register(NovelTbCell.self, forCellReuseIdentifier: "cell")
        tb.register(LoadMoreCell.self, forCellReuseIdentifier: "moreCell")
        tb.dataSource = self
        tb.delegate = self
        tb.tableFooterView = UIView()
        
        let buttonSaveBoookmark = UIBarButtonItem(title: "查看书签", style: .plain, target: self, action: #selector(ViewController.checkBBookmark))
        navigationItem.rightBarButtonItem = buttonSaveBoookmark
        
    }

    func searchNovel(sender:UIButton)  {
        txtSearch.resignFirstResponder()
        guard let key = txtSearch.text else {
            GrandCue.toast("小说名不能为空")
            return
        }
        if (key as NSString).length <= 0{
            GrandCue.toast("小说名不能为空")
            return
        }
        index = 0
        self.key = key
        isLoadAll = false
        getNovels()
    }
    
    func getNovels() {
        isLoading = true
        GrandCue.showLoading()
        NovelInfo.searchNovel(key: key, index: index,cb: { (novels) in
            GrandCue.dismissLoading()
            self.isLoading = false
            if novels.count <= 0{
                GrandCue.toast("找不到数据")
                self.isLoadAll = true
                return
            }
            self.isLoadAll = false
            if self.index == 0{
                self.arrNovel.removeAll()
            }
            for vn in novels{
                self.arrNovel.append(vn)
            }
            self.index += 1
            self.tb.reloadData()
        })
    }

    
    func checkBBookmark() {
//        let vc = BookmarkViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrNovel.count == 0{
            return 0
        }
        else if !isLoadAll{
            return arrNovel.count + 1
        }
        return arrNovel.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrNovel.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as! LoadMoreCell
            cell.selectionStyle  = .none
            cell.spin.startAnimating()
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NovelTbCell
            cell.novelIndo = arrNovel[indexPath.row]
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == arrNovel.count{
            return 50
        }
        return 160
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isLoadAll {
            if indexPath.row >= arrNovel.count && !isLoading{
                getNovels()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = SectionListViewController()
//        vc.novelInfo = arrNovel[indexPath.row]
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


