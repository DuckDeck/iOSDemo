//
//  TableLayout.swift
//  iOSDemo
//
//  Created by shadowedge on 2020/9/25.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import Foundation
class TableLayoutViewController: UIViewController {
    
    let tb = UITableView()
    let sectionView = ExtendSection()
    let header = UIImageView()
    override func viewDidLoad() {
        sectionView.toggle = {[weak self]toggle in
            
            self?.tb.reloadData()
        }
        header.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 200)
        header.image = UIImage(named: "7")
        tb.tableHeaderView = header
        tb.delegate = self
        tb.dataSource = self
        tb.register(testCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.top.equalTo(NavigationBarHeight)
        }
    }
    
    class ExtendSection: UIView {
        var sectionHeight = 50
        let btn = UIButton()
        var toggle:((_ toggle:Bool)->Void)?
        var isExpand = false
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.yellow
            btn.backgroundColor = UIColor.green
            btn.setTitle("展开", for: .normal)
            btn.setTitle("收起", for: .selected)
            btn.addTarget(self, action: #selector(toggleHeight), for: .touchUpInside)
            addSubview(btn)
            btn.snp.makeConstraints { (m) in
                m.right.equalTo(-20)
                m.centerY.equalTo(self)
                m.width.equalTo(200)
                m.height.equalTo(30)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func toggleHeight() {
            isExpand = !isExpand
            toggle?(isExpand)
            btn.isSelected = isExpand
            sectionHeight = isExpand ? 100 : 50
        }
    }
    
    
    class testCell: UITableViewCell {
        
        let head = UIView()
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor.gray
            head.backgroundColor = UIColor.red
            contentView.addSubview(head)
            head.snp.makeConstraints { (m) in
                m.left.equalTo(20)
                m.top.equalTo(10)
                m.width.height.equalTo(200)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
}

extension TableLayoutViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(sectionView.sectionHeight)
    }
}
