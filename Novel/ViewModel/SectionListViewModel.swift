//
//  SectionListViewModel.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
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
class SectionListViewModel {
    let cellID = "cell"
    var bag : DisposeBag = DisposeBag()
//    let provider = RxMoyaProvider<APIManager>(requestClosure:MoyaProvider.myRequestMapping)
    let provider = MoyaProvider<APIManager>()
    var modelObserable = Variable<[SectionInfo]> ([])
    let requestNewDataCommond =  PublishSubject<Bool>()
    var tb : UITableView
    var novelInfo:Variable<NovelInfo>

    init(input:(tb:UITableView,novelInfo:Variable<NovelInfo>)) {
        self.tb = input.tb
        self.novelInfo = input.novelInfo
        bind()
        initData()
    }
    
    func bind(){
        tb.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tb.tableFooterView = UIView()
        modelObserable.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: UITableViewCell.self)){ row , model , cell in
                cell.textLabel?.text = model.sectionName
            }.disposed(by: bag)
        weak var wkself = self
        tb.rx.itemSelected.subscribe(onNext: { (index) in
            guard  let section = wkself?.modelObserable.value[index.row] else{
                return
            }
            let dict = ["novelInfo":wkself!.novelInfo.value,"currentSection":section,"arrSectionUrl":wkself!.modelObserable.value] as [String : Any]
            if let del = UIApplication.shared.delegate as? AppDelegate{
                del.navigator.push(Routers.novelContent, context: dict, from: nil, animated: true)
            }
            
    
            //            _ = (UIApplication.shared.delegate as! AppDelegate).navigator?.push(Routers.novelContent, context: dict, from: nil, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)

        
    }
    
    func initData(){
        weak var wkself = self
        let path = novelInfo.value.url.subToEnd(start: 19)
        GrandCue.showLoading()
        provider.rx.request(.GetSection(path)).filterSuccessfulStatusCodes().mapSectionInfo().subscribe({ (str) in
            GrandCue.dismissLoading()
            switch(str){
            case let .success(result):
                wkself?.modelObserable.value = result.data! as! [SectionInfo]
            case let  .error(err):
                Log(message: err)
                GrandCue.toast(err.localizedDescription)
            }
        }).disposed(by: wkself!.bag)
    }

}
