//
//  BookMarkViewModel.swift
//  iOSDemo
//
//  Created by Stan Hu on 18/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator
import RxDataSources
class BookMarkViewModel {
    let cellID = "cell"
    var bag : DisposeBag = DisposeBag()
    var tb : UITableView
    var dataSource: RxTableViewSectionedAnimatedDataSource<SectionTableInfo>?
    init(tb:UITableView) {
        self.tb = tb
        bind()
    }
    
    func bind()  {
        
         tb.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionTableInfo>()
        dataSource.configureCell = { [weak self] ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: self!.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: self!.cellID)
            cell.textLabel?.text = item.sectionName
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let sections = Bookmark.Value!.map { (novelInfo) -> SectionTableInfo in
           return SectionTableInfo(header: novelInfo.title, items: novelInfo.arrBookMark!)
        }
        
        
        //Observable.just(sections).bind(to: tb.rx.items(datasource:dataSource)).addDisposableTo(bag)
        Observable.just(sections)
            .bind(to: tb.rx.items(dataSource: dataSource))
            .addDisposableTo(bag)
        self.dataSource = dataSource
    }
}
