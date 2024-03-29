//
//  RunTimeViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class BasicViewController: UIViewController {

    var arrData = ["Thread","MemeryLeak","清理缓存","日志系统"]
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
extension BasicViewController:UITableViewDelegate,UITableViewDataSource{
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
            navigationController?.pushViewController(ThreadViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(MemeryLeakTestViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(ClearCacheViewController(), animated: true)

        case 3:
            navigationController?.pushViewController(LogViewController(), animated: true)
        default:
            break
        }
    }
    

}

public protocol Then{}

extension Then where Self:AnyObject{
    public func then(_ block: (Self)->Void)->Self{
        block(self)
        return self
    }
}

extension NSObject:Then{
    
}

