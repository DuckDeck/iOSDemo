//
//  TransverseTable.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/8/13.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import Foundation
class TransverseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    
    
    let tb = UITableView(frame: CGRect(x: 100, y: 0, width: 50, height: ScreenWidth), style: .plain)
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        tb.delegate = self
        tb.dataSource = self
        tb.rowHeight = 50
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb.showsVerticalScrollIndicator = false
        tb.center = CGPoint(x: tb.centerY, y: tb.centerX)
        tb.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2));
        view.addSubview(tb)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        cell.contentView.backgroundColor = UIColor.random
        return cell
    }
}
