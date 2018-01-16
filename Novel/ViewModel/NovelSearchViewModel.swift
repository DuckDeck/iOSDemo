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
class NovelSearchViewModel:BaseViewModel {

       let cellID = "cell"
       var bag : DisposeBag = DisposeBag()
       //let provider = MoyaProvider<APIManager>(requestClosure:MoyaProvider.myRequestMapping)
       let provider = MoyaProvider<APIManager>()
       var modelObserable = Variable<[NovelInfo]> ([])
       var refreshStateObserable = Variable<RefreshStatus>(.none)
       let requestNewDataCommond =  PublishSubject<Bool>()
       var pushCloure : ClosureType?  //for what
       var pageIndex = 0
       var tb : UITableView!
       var key :Driver<String>!
       var keyStr = Variable<String>.init("")
       var searchCommand :Driver<Void>!
    

    
    static func create(input:(tb:UITableView,searchKey:Driver<String>,searchTap:Driver<Void>))->NovelSearchViewModel{
        let m = NovelSearchViewModel()
        m.tb = input.tb
        m.key = input.searchKey
        m.key.drive(m.keyStr).disposed(by: m.bag)
        m.searchCommand = input.searchTap
        m.bind()
        return m
    }
    
//     init(input:(tb:UITableView,searchKey:Driver<String>,searchTap:Driver<Void>)) {
//        tb = input.tb
//        key = input.searchKey
//        key.drive(keyStr).disposed(by: bag)
//        searchCommand = input.searchTap
//        self.bind()
//     }
    
      func bind(){
         weak var wkself = self
          tb.register(NovelTbCell.self, forCellReuseIdentifier: cellID)
          tb.tableFooterView = UIView()
          modelObserable.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: NovelTbCell.self)){ row , model , cell in
                cell.novelIndo = model
            }.disposed(by: bag)
        
        tb.rx.itemSelected.subscribe(onNext: {[weak self] (index) in
            guard  let novel = wkself?.modelObserable.value[index.row] else{
                return
            }
            self?.urlNav?.push(Routers.sectionList, context: novel, from: nil, animated: true)
            //critic issue  新版本的URLNavgator 在MVVM 看来是不能用了
            //if let del = UIApplication.shared.delegate as? AppDelegate{
                //let _ =  del.navigator.push(Routers.sectionList, context: novel, from: nil, animated: true)
                    //navigator can not work
            //}
//           _ = (UIApplication.shared.delegate as! AppDelegate).navigator?.push(Routers.sectionList, context: novel, from: nil, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
        
        requestNewDataCommond.subscribe { [weak self](event) in
           Tool.hiddenKeyboard()
            if event.element!{
                self?.pageIndex = 0
  
                self?.provider.rx.request(.GetSearch(self!.keyStr.value,self!.pageIndex)).filterSuccessfulStatusCodes().mapNovelInfo().subscribe({ (str) in
                    switch(str){
                    case let .success(result):
                            self?.modelObserable.value = result.data! as! [NovelInfo]
                            self?.refreshStateObserable.value = .endHeaderRefresh
                    case let  .error(err):
                        Log(message: err)
                        self?.refreshStateObserable.value = .endHeaderRefresh
                        GrandCue.toast(err.localizedDescription)
                    }
                }).disposed(by: self!.bag)
            }
            else{
                self?.pageIndex += 1
                self?.provider.rx.request(.GetSearch(self!.keyStr.value,self!.pageIndex)).filterSuccessfulStatusCodes().mapNovelInfo().subscribe({ (str) in
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
                }).disposed(by: self!.bag)
            }
            }.disposed(by: bag)
        
        
        searchCommand.drive(onNext: {
            self.refreshStateObserable.value = .beginHeaderRefresh
        }, onCompleted: nil, onDisposed: nil).disposed(by: bag)
        
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
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
      }
}
