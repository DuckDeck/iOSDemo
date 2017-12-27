//
//  AnimationViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
class AnimationViewController: UIViewController {
    var arrData = ["LayerAnimation","GradientLayer","Replication","Slider","Emitter","TwoSideView","ImageTransform","Filter","Layer"]
    var tbMenu = UITableView()
    override func loadView() {
        super.loadView()
        self.view = TGFrameLayout(frame: self.view.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tg_width.equal(.fill)
        tbMenu.tg_height.equal(.fill)
        tbMenu.tg_left.equal(0)
        tbMenu.tg_top.equal(0)
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
    }
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
        default:
            break
        }
    }

}
