//
//  MediaViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class MediaViewController: UIViewController {

    var arrData = ["CaptureVideo","Play Music","Add Watermark","Record Audio","Record Video","Take Photo"]
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

extension MediaViewController:UITableViewDelegate,UITableViewDataSource{
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
            navigationController?.pushViewController(CaptureVideoViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(MusicListViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(WatermarkViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(SoundRecordViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(VideoListViewController(), animated: true)
        case 5:
            present(TakePhotoViewController(), animated: true, completion: nil)
        default:
            break
        }
    }
}
