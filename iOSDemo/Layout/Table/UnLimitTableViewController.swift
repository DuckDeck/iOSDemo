//
//  UnLimitTableViewController.swift
//  iOSDemo
//
//  Created by shadowedge on 2020/10/23.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit
//为个要优化
class UnLimitTableViewController: UIViewController {
    
    var arr = [1,2,3,4,5,6,7]
    
    let tb = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        tb.register(tbCell.self, forCellReuseIdentifier: "Cell")
        tb.dataSource = self
        tb.delegate = self
        tb.isPagingEnabled = true
        tb.estimatedRowHeight = ScreenHeight
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.left.top.right.equalTo(0)
            m.height.lessThanOrEqualTo(ScreenHeight - NavigationBarHeight)
        }
    }
    

  

}

extension UnLimitTableViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? tbCell
        cell?.title = arr[indexPath.row % arr.count].toString
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenHeight - NavigationBarHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            tb.setContentOffset(CGPoint(x: 0, y: arr.count * tb.frame.size.height), animated: false)
        }
        else if scrollView.contentOffset.y >= tb.frame.size.height * (arr.count * 2 - 1){
            tb.setContentOffset(CGPoint(x: 0, y: (arr.count - 1) * tb.frame.size.height), animated: false)
        }

    }
    
    
}

class tbCell: UITableViewCell {
    
    var title : String?{
        didSet{
            lbl.text = title
        }
    }
    let lbl = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.random
        lbl.txtAlignment(ali: .center).color(color: UIColor.black).addTo(view: contentView).snp.makeConstraints { (m) in
            m.center.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
