//
//  NovelContentViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

import Result
class NovelContentViewModel {
    let cellID = "cell"
    var bag : DisposeBag = DisposeBag()
//    let provider = MoyaProvider<APIManager>(requestClosure:MoyaProvider.myRequestMapping)
    let provider = MoyaProvider<APIManager>()
    var pageIndex = 0
    var tb : UITableView
    var currentSection:SectionInfo                  //当前加载到最前面的section
    var novelInfo:NovelInfo                             //section的小说信息
    var arrSectionUrl : [SectionInfo]?              //该小说所有的section的Url
    var arrSection = Variable<[SectionInfo]> ([])               //该小说所有的section
    var currentDisplayRow: SectionInfo?         //当前显示的section
    let sectionTitle: Variable<String>
    var isLoadAll = false
    var isLoading = false
    init(input:(tb:UITableView,novel:NovelInfo,currentSection:SectionInfo,sectionUrl:[SectionInfo]?)) {
        self.tb = input.tb
        self.novelInfo = input.novel
        self.currentSection = input.currentSection
        self.arrSectionUrl = input.sectionUrl
        self.sectionTitle = Variable<String>(self.currentSection.sectionName)
        bind()
        initData()
    }
    
    func bind()  {
        
        
        
        tb.register(NovelContentCell.self, forCellReuseIdentifier: cellID)
        tb.tableFooterView = UIView()
        arrSection.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: NovelContentCell.self)){ [weak self] row , model , cell in
            self?.currentDisplayRow = model
            self?.sectionTitle.value = model.sectionName
            cell.setText(str: model.sectionAttributeContent)
            }.disposed(by: bag)
    }
    
    func initData()  {
        //先写arrSectionUrl不为空的
        GrandCue.showLoading()
        if let urls = arrSectionUrl{
            pageIndex = urls.index(where: { (s) -> Bool in
                return s.sectionUrl == self.currentSection.sectionUrl
            })!
            getNovelContent()
        }
        else{
            getNovelSections()
        }
    }
    
    func getNovelContent() {
        let url = novelInfo.url.subToEnd(start: 19) + "/"+currentSection.sectionUrl
        isLoading = true
        provider.rx.request(.GetNovel(url)).filterSuccessfulStatusCodes().mapNovelSection().subscribe({ [weak self](str) in
            self?.isLoading = false
            GrandCue.dismissLoading()
            switch(str){
            case let .success(result):
                self!.currentSection.sectionContent = result.data as! String
                self?.arrSection.value += [self!.currentSection]
                self?.pageIndex += 1
                self!.currentSection = self!.arrSectionUrl![self!.pageIndex]
            case let  .error(err):
                Log(message: err)
                GrandCue.toast(err.localizedDescription)
            }
        }).disposed(by: self.bag)
      
    }

    func getNovelSections()  {
        let path = novelInfo.url.subToEnd(start: 19)
        provider.rx.request(.GetSection(path)).filterSuccessfulStatusCodes().mapSectionInfo().subscribe({ [weak self] (str) in
            switch(str){
            case let .success(result):
                self?.arrSectionUrl = result.data! as? [SectionInfo]
                self?.initData()
            case let  .error(err):
                Log(message: err)
                GrandCue.dismissLoading()
                GrandCue.toast(err.localizedDescription)
            }
        }).disposed(by: self.bag)

    }
    
    func saveBookmark()  {
        if currentDisplayRow == nil {
            return
        }
        var marks = Bookmark.Value!
        let index = marks.index(where: { (n) -> Bool in
            n.url == novelInfo.url
        })
        if index == nil{
            let novel = novelInfo
            novel.arrBookMark = [SectionInfo]()
            novel.arrBookMark?.append(currentDisplayRow!)
            marks.append(novelInfo)
        }
        else{
            let n = marks[index!]
            if n.arrBookMark != nil{
                let sectionIndex = n.arrBookMark!.index(where: { (s) -> Bool in
                    s.sectionUrl == currentDisplayRow?.sectionUrl
                })
                if sectionIndex == nil{
                    n.arrBookMark?.append(currentDisplayRow!)
                }
                else{
                    GrandCue.toast("你已经添加这个地方的书签了")
                    return
                }
            }
            else{
                n.arrBookMark = [SectionInfo]()
                n.arrBookMark?.append(currentDisplayRow!)
            }
        }
        Bookmark.Value = marks
        GrandCue.toast("添加书签成功")
    }
}
