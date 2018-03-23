//
//  AnimationViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class AnimationViewController: UIViewController {
    var arrData = ["LayerAnimation","GradientLayer","Replication","Slider","Emitter","TwoSideView","ImageTransform","Filter","Layer","Ripple"]
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
        }    }
}

extension AnimationViewController:UITableViewDelegate,UITableViewDataSource{
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
            navigationController?.pushViewController(LayerAnimationViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(GradientLayerViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(ReplicatorViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(SliderDemoViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(EmitterViewController(), animated: true)
        case 5:
            navigationController?.pushViewController(TwoSideViewController(), animated: true)
        case 6:
            navigationController?.pushViewController(ImageTransformViewController(), animated: true)
        case 7:
            navigationController?.pushViewController(FilterViewController(), animated: true)
        case 8:
            navigationController?.pushViewController(LayerViewController(), animated: true)
        case 9:
            navigationController?.pushViewController(RippleViewController(), animated: true)
        default:
            break
        }
    }

}
