//
//  FFmpegViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/9.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FFmpegViewController: UIViewController {
    var arrData = ["VideoBox硬解码","音频解编码"]
    var tbMenu = UITableView()
    
    override func loadView() {
        super.loadView()
        print("New ViewController LoadView")
    }
    
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
        
        print("New ViewController viewDidLoad")
    }
    
    
   
}

extension FFmpegViewController:UITableViewDelegate,UITableViewDataSource{
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
            navigationController?.pushViewController(VideoBoxDecodeVideoViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(AudioDecoderViewController(), animated: true)

        case 2:
            break
        case 3:
           break
       
        default:
            break
        }
    }
}
