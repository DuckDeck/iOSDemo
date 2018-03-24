//
//  DataViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

    var arrData = ["SQLite"]
    var tbMenu = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Data"
        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
    }
}

extension DataViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrData[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(SQLiteViewController(), animated: true)
        case 1:
            break
        case 2:
            break
            
        default:
            break
        }
    }
}
