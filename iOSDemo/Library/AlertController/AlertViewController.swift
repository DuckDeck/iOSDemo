//
//  AlertViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 17/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import GrandTime
class AlertViewController: UIViewController {

    var arrData = ["普通Alert","Alert"]
    var tbMenu = UITableView()
    var timer:GrandTimer!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromSeconds(1), target: self, sel: #selector(tick), userInfo: nil, repeats: true, dispatchQueue: DispatchQueue.main)
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
       
    }

    @objc func tick() {
        
    }
    
    @objc func showAlert() {
        timer.invalidate()
        let attrStr = NSMutableAttributedString(string: "购买本次修复服务需花费20积分,是否确实购买")
        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(11, 2))
        let alert = UIAlertController.title(attrTitle: nil, attrMessage: attrStr).action(title: "取消",handle: nil, color:UIColor.gray).action(title: "购买", handle: {(action:UIAlertAction) in
            self.timer.pause()
        })
      
        
     
        alert.show()
    }
    
}

extension AlertViewController:UITableViewDelegate,UITableViewDataSource{
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
            UIAlertController.title(title: "这是标题", message:"比初代产品更小巧便携，重约4.5公斤，改进的背带背起来不会感到太过").action(title: "取消", handle: nil, color: UIColor.lightGray, style: .cancel).action(title: "确定", handle: { (action:UIAlertAction) in
                
            }, style: .default).show()
        case 1:
            break
        case 2:
            break
            
        default:
            break
        }
    }
}
