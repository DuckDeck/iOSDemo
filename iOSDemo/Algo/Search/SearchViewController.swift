//
//  SearchViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/9/7.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

       var arrData = ["二分查找"]
        var tbMenu = UITableView()
        override func viewDidLoad() {
            super.viewDidLoad()
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
extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
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
           navigationController?.pushViewController(BinarySearchViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(PointLockViewController(), animated: true)
        case 2:
//            navigationController?.pushViewController(MitoViewController(), animated: true)
            Toast.showToast(msg: "此网站已经关了，无法再访问，所以不能再进了")
        case 3:
            navigationController?.pushViewController(FiveStrokeViewController(), animated: true)
        default:
            break
        }
    }


}
