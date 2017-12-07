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
    var bookmarks =  Variable<[SectionTableInfo]> ([])
    var dataSource: RxTableViewSectionedAnimatedDataSource<SectionTableInfo>?
    init(tb:UITableView) {
        self.tb = tb
        bind()
    }
    
    
    //对于ViewModel也是有一个生命同期的，ViewController 有 LoadView
    // ViewDidLoad,WillAppare等， 而ViewModel应该有
    // Create, BindData,  Destroy 等生命周期事件
    func bind()  {
        
         tb.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionTableInfo>(configureCell: {ds,tv,ip,item in
            let cell = tv.dequeueReusableCell(withIdentifier: self.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: self.cellID)
            cell.textLabel?.text = item.sectionName
            return cell
        })
//        dataSource.configureCell = {  ds, tv, ip, item in
//            let cell = tv.dequeueReusableCell(withIdentifier: self.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: self.cellID)
//            cell.textLabel?.text = item.sectionName
//            return cell
//        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let sections = Bookmark.Value!.map { (novelInfo) -> SectionTableInfo in
           return SectionTableInfo(header: novelInfo.title, items: novelInfo.arrBookMark!)
        }

        bookmarks.value = sections
        
        let deleteCommand = tb.rx.itemDeleted.asObservable()
            .map(TableViewEditingCommand.DeleteItem)
        
        let initialState = SectionedTableViewState(sections: sections)
        Observable.of(deleteCommand)
            .merge()
            .scan(initialState) { (state: SectionedTableViewState, command: TableViewEditingCommand) -> SectionedTableViewState in
                return state.execute(command: command)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .share(replay: 1)
            .bind(to: tb.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        
        dataSource.canEditRowAtIndexPath = { _,_  in
            return true
        }
        
        bookmarks.asObservable()
            .bind(to: tb.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        self.dataSource = dataSource
        
        tb.rx.itemSelected.subscribe(onNext: { (index) in
            let bookmarks = Bookmark.Value!
            let dict = ["novelInfo":bookmarks[index.section],"currentSection":bookmarks[index.section].arrBookMark![index.row]] as [String : Any]
//            _ = (UIApplication.shared.delegate as! AppDelegate).navigator?.push(Routers.sectionList, context: dict, from: nil, animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)

    }
    
    func clearBookmark()  {
        Bookmark.clear()
        bookmarks.value.removeAll()
        GrandCue.toast("书签全部清除")
    }
}

enum TableViewEditingCommand {
    case DeleteItem(IndexPath)
}


struct SectionedTableViewState {
    fileprivate var sections: [SectionTableInfo]
    
    init(sections: [SectionTableInfo]) {
        self.sections = sections
    }
    
    func execute(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
              case .DeleteItem(let indexPath):
                var sections = Bookmark.Value!
                sections[indexPath.section].arrBookMark?.remove(at: indexPath.row)
                if sections[indexPath.section].arrBookMark!.count <= 0{
                    sections.remove(at: indexPath.section)
                }
                let sc = sections.map { (novelInfo) -> SectionTableInfo in
                    return SectionTableInfo(header: novelInfo.title, items: novelInfo.arrBookMark!)
                }
                Bookmark.Value = sections
            
            return SectionedTableViewState(sections: sc)
        }
    }
}
