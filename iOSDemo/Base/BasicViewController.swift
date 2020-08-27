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

    var arrData = ["Demo","Thread","MemeryLeak","离屏渲染","通知","测试通知"]
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
            navigationController?.pushViewController(DemoViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(ThreadViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(MemeryLeakTestViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(OffSreenRenderViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(NotifcationViewController(), animated: true)
        case 5:
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "test"), object: "123")
            Toast.showToast(msg: "上个页面没有remove obserer不会引发crash")
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

