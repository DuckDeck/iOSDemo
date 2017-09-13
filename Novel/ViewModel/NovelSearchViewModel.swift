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
enum RefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beginFooterRefresh
    case endFooterRefresh
    case noMoreData
}
let cellID = "cell"
typealias ClosureType = (Int) -> Void
class NovelSearchViewModel: NSObject {
       var bag : DisposeBag = DisposeBag()
       let provider = RxMoyaProvider<APIManager>()
       var modelObserable = Variable<[NovelInfo]> ([])
       var refreshStateObserable = Variable<RefreshStatus>(.none)
       let requestNewDataCommond =  PublishSubject<Bool>()
       var pushCloure : ClosureType?
       var pageIndex = 0
       var tb = UITableView()
      var key = ""
    
      func bind(){
          tb.register(NovelTbCell.self, forCellReuseIdentifier: cellID)
          tb.register(LoadMoreCell.self, forCellReuseIdentifier: "moreCell")
          tb.tableFooterView = UIView()
          modelObserable.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: NovelTbCell.self)){ row , model , cell in
                cell.novelIndo = model
          }.addDisposableTo(bag)
        
        tb.rx.itemSelected.subscribe(onNext: { (index) in
                Log(message: "\(index)")
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
        
        requestNewDataCommond.subscribe { [weak self](event) in
            if event.element!{
                self?.pageIndex = 0
                self?.provider.request(.GetSearch(self!.key,self!.pageIndex)).filterSuccessfulStatusCodes().mapString().subscribe({ (str) in
                    Log(message: str)
                }).addDisposableTo(self!.bag)
            }
        }.addDisposableTo(bag)
        
        refreshStateObserable.asObservable().subscribe(onNext: { (status) in
            switch(status){
            case .beginHeaderRefresh:
                self.tb.mj_header.beginRefreshing()
            case .endHeaderRefresh:
                self.tb.mj_header.endRefreshing()
                self.tb.mj_footer.resetNoMoreData()
            case .beginFooterRefresh:
                self.tb.mj_footer.beginRefreshing()
            case .endFooterRefresh:
                self.tb.mj_footer.endRefreshing()
            case .noMoreData:
                self.tb.mj_footer.endRefreshingWithNoMoreData()
            default:
                break
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(bag)
      }
}
