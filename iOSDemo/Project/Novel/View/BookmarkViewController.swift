//
//  BookmarkViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
import SnapKit

final class BookmarkViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }

    var tb = UITableView()
    var vm:BookMarkViewModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "书签"
      
        tb.tableFooterView = UIView()
        tb.delegate = self
       // tb.estimatedHeightForRow = 50 can not set estimatedHeightForRow when use rxdatasource

        tb.rowHeight = UITableView.automaticDimension
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        vm = BookMarkViewModel(tb: tb)
        
        let buttonSaveBoookmark = UIBarButtonItem(title: "清空书签", style: .plain, target: self, action: #selector(BookmarkViewController.clearBookmark))
        navigationItem.rightBarButtonItem = buttonSaveBoookmark
    }
    
    
    @objc func clearBookmark()  {
        if Bookmark.Value!.count <= 0{
            return
        }
        let action = UIAlertController(title: "清空书签", message: "你确实要全部清空书签吗?", preferredStyle: .alert)
        let a1 = UIAlertAction(title: "确定", style: .default) { (a) in
            self.vm?.clearBookmark()
        }
        let a2 = UIAlertAction(title: "取消", style: .cancel) { (a) in
        }
        action.addAction(a1)
        action.addAction(a2)
        present(action, animated: true, completion: nil)
    }
    
    
    deinit {
            Log(message: "\(type(of:self))已经被回收了")
    }
}



extension BookmarkViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    

}

