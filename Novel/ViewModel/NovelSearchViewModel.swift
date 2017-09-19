//
//  NovelSearchViewModel.swift
//  iOSDemo
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import RxMoya
import Result
import RxBlocking
import URLNavigator
enum RefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
    case noMoreData
}

typealias ClosureType = (Int) -> Void
class NovelSearchViewModel {

       let cellID = "cell"
       var bag : DisposeBag = DisposeBag()
       let provider = RxMoyaProvider<APIManager>(requestClosure:MoyaProvider.myRequestMapping)
       var modelObserable = Variable<[NovelInfo]> ([])
       var refreshStateObserable = Variable<RefreshStatus>(.none)
       let requestNewDataCommond =  PublishSubject<Bool>()
       var pushCloure : ClosureType?  //for what
       var pageIndex = 0
       var tb : UITableView
       var key :Driver<String>
      var keyStr = Variable<String>.init("")
       var searchCommand :Driver<Void>
    
     init(input:(tb:UITableView,searchKey:Driver<String>,searchTap:Driver<Void>)) {
        tb = input.tb
        key = input.searchKey
        key.drive(keyStr).addDisposableTo(bag)
        searchCommand = input.searchTap
        bind()
     }
    
      func bind(){
         weak var wkself = self
        
          tb.register(NovelTbCell.self, forCellReuseIdentifier: cellID)
          tb.tableFooterView = UIView()
          modelObserable.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: NovelTbCell.self)){ row , model , cell in
                cell.novelIndo = model
          }.addDisposableTo(bag)
        
        
        
        tb.rx.itemSelected.subscribe(onNext: { (index) in
            guard  let novel = wkself?.modelObserable.value[index.row] else{
                return
            }
            Navigator.push(Routers.sectionList, context: novel, from: nil, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
        
        requestNewDataCommond.subscribe { [weak self](event) in
           Tool.hiddenKeyboard()
            if event.element!{
                self?.pageIndex = 0
                self?.provider.request(.GetSearch(self!.keyStr.value,self!.pageIndex)).filterSuccessfulStatusCodes().mapNovelInfo().subscribe({ (str) in
                    switch(str){
                    case let .success(result):
                            self?.modelObserable.value = result.data! as! [NovelInfo]
                            self?.refreshStateObserable.value = .endHeaderRefresh
                    case let  .error(err):
                        Log(message: err)
                        self?.refreshStateObserable.value = .endHeaderRefresh
                        GrandCue.toast(err.localizedDescription)
                    }
                }).addDisposableTo(self!.bag)
            }
            else{
                self?.pageIndex += 1
                self?.provider.request(.GetSearch(self!.keyStr.value,self!.pageIndex)).filterSuccessfulStatusCodes().mapNovelInfo().subscribe({ (str) in
                    switch(str){
                    case let .success(result):
                        let res = result.data! as! [NovelInfo]
                        if res.count <= 0 {
                             self?.refreshStateObserable.value = .noMoreData
                        }
                        else{
                            self?.modelObserable.value += res
                             self?.refreshStateObserable.value = .endFooterRefresh
                        }
                    case let  .error(err):
                        self?.refreshStateObserable.value = .endFooterRefresh
                        GrandCue.toast(err.localizedDescription)
                    }
                }).addDisposableTo(self!.bag)
            }
        }.addDisposableTo(bag)
        
   
        
        searchCommand.drive(onNext: {
            wkself?.tb.mj_header.beginRefreshing()
        }, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
        

        refreshStateObserable.asObservable().subscribe(onNext: { (status) in
            switch(status){
            case .beginHeaderRefresh:
                wkself?.tb.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                wkself?.tb.mj_header.endRefreshing()
                wkself?.tb.mj_footer.resetNoMoreData()
            case .beginFooterRefresh:
                wkself?.tb.mj_footer.beginRefreshing()
            case .endFooterRefresh:
                wkself?.tb.mj_footer.endRefreshing()
            case .noMoreData:
                wkself?.tb.mj_footer.endRefreshingWithNoMoreData()
            default:
                break
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
      }
}
