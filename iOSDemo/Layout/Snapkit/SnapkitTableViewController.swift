//
//  SnapkitTableViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/01/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class SnapkitTableViewController: UIViewController {

    let tb = UITableView()
    let arr = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        tb.dataSource = self
        tb.delegate = self
        tb.register(SnapCell.self, forCellReuseIdentifier: "cell")
        tb.estimatedRowHeight = 100
        tb.tableFooterView = UIView()
        
      
    }

}

extension SnapkitTableViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SnapCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    
    
}

class SnapCell: UITableViewCell {
    let lbl = UILabel()
    let img = UIImageView()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        lbl.layer.borderWidth = 1
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
