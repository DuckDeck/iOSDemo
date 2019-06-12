//
//  ThreadViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class ThreadViewController: UIViewController {
    
     var arrData = ["测试信号量"]
//    let btn = UIButton().then {
//        $0.setTitle("按钮", for: .normal)
//        $0.color(color: UIColor.red).bgColor(color: UIColor.gray).completed()
//        $0.frame = CGRect(x: 100, y: 80, width: 100, height: 30)
//        $0.layer.borderColor = UIColor.green.cgColor
//        $0.layer.borderWidth = 2
//        $0.addTarget(self, action: #selector(ThreadViewController.clickDown(sender:)), for: .touchUpInside)
//    }

    
    
    let tb = UITableView().then{
        $0.tableFooterView = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tb.dataSource = self
        tb.delegate = self
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
     
    }

//    @objc func clickDown(sender:UIButton)  {
//        Semaphore.testSemaphore()
//        Semaphore.testAsyncFinished()
//        Semaphore.testProductionAndConsumer()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ThreadViewController:UITableViewDelegate,UITableViewDataSource{
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
        switch indexPath.row {
        case 0:
            Semaphore.testSemaphore()
        default:
            break
        }
    }
}
