//
//  ProjectViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/2.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
class ProjectViewController: UIViewController {

    var arrData = ["Novel","LinkGame","PointLock"]
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

extension ProjectViewController:UITableViewDelegate,UITableViewDataSource{
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
            NavigationMap.initialize() //现在的API改成每个ViewController都有Navigator了，我不喜欢这样，感觉要换一个,目前这个功能就用不了
            navigationController?.pushViewController(NovelViewController(), animated: true)
        case 1:
           navigationController?.pushViewController(LinkGameViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(PointLockViewController(), animated: true)
        default:
            break
        }
    }


}
