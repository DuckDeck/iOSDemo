//
//  ViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class ViewController: UIViewController {
    var arrData = ["Memery","Media","Animation&Graphic","Layout","AI","Network","Touch","Library","Sensor","Rumtime","Keyboard","Data","Webview","Project","Open OtherApp"]
    var tbMenu = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
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
            navigationController?.pushViewController(MemeryViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(MediaViewController(), animated: true)
        case 2:
              navigationController?.pushViewController(AnimationViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(LayoutViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(AIViewController(), animated: true)
        case 5:
            navigationController?.pushViewController(NetworkViewController(), animated: true)
        case 6:
            navigationController?.pushViewController(TouchViewController(), animated: true)
        case 7:
            navigationController?.pushViewController(LibraryViewController(), animated: true)
        case 8:
            navigationController?.pushViewController(SensorViewController(), animated: true)
        case 9:
            navigationController?.pushViewController(RunTimeViewController(), animated: true)
        case 10:
            navigationController?.pushViewController(KeyboardViewController(), animated: true)
        case 11:
            navigationController?.pushViewController(DataViewController(), animated: true)
        case 12:
            navigationController?.pushViewController(WebViewController(), animated: true)
        case 13:
            navigationController?.pushViewController(ProjectViewController(), animated: true)
        case 14:
            let url = URL(string: "yihui://")
            UIApplication.shared.openURL(url!)
        default:
            break
        }
    }

}
