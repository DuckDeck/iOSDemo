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
    let provider = RxMoyaProvider<APIManager>(requestClosure:MoyaProvider.myRequestMapping)
    var modelObserable = Variable<[SectionInfo]> ([])
    let requestNewDataCommond =  PublishSubject<Bool>()
    var tb : UITableView
    var novelInfo:Variable<NovelInfo>
    init(input:(tb:UITableView,novelInfo:Variable<NovelInfo>)) {
        self.tb = input.tb
        self.novelInfo = input.novelInfo
        bind()
    }
    
    func bind(){
        weak var wkself = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tb.tableFooterView = UIView()
        modelObserable.asObservable().bind(to: tb.rx.items(cellIdentifier: cellID, cellType: UITableViewCell.self)){ row , model , cell in
                cell.textLabel?.attributedText = model.sectionAttributeContent
            }.addDisposableTo(bag)


        let path = novelInfo.value.url.subToEnd(start: 19)
        provider.request(.GetSection(path)).filterSuccessfulStatusCodes().mapString().mapSectionInfo().subscribe({ (str) in
            switch(str){
            case let .success(result):
                wkself?.modelObserable.value = result.data! as! [SectionInfo]
            case let  .error(err):
                Log(message: err)
                GrandCue.toast(err.localizedDescription)
            }
        }).addDisposableTo(wkself!.bag)
    
    
    }

}
