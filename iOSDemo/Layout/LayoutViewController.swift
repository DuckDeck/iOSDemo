//
//  LayoutViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class LayoutViewController: UIViewController {

    var arrData = ["ScrollMenu","Snapkit","Grid","StackView","Text Layout","Form","Kind Of Cell Type","FlowLayout","TableLayout","UnLimitTableLayout","优化的tableview",]
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

extension LayoutViewController:UITableViewDelegate,UITableViewDataSource{
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
            navigationController?.pushViewController(ScrollMenuViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(SnapkitViewController(), animated: true)
        case 2:
             navigationController?.pushViewController(GridViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(StackViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(LoadMoreTable(), animated: true)
        case 5:
            break
        case 6:
            navigationController?.pushViewController(CellTypeViewController(), animated: true)
        case 7:
            navigationController?.pushViewController(FlowLayoutViewController(), animated: true)
        case 8:
            navigationController?.pushViewController(TableLayoutViewController(), animated: true)
        case 9:
            navigationController?.pushViewController(UnLimitTableViewController(), animated: true)
        case 10:
            navigationController?.pushViewController(GrandTableViewController(), animated: true)
        default:
            break
        }
    }
}

class LoadMoreTable: UIViewController,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrColor.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath)
        cell.contentView.backgroundColor = arrColor[indexPath.row]
        cell.textLabel?.text = indexPath.row.toString
        return cell
    }
    
    var tb = UITableView()
    var arrColor = [UIColor]()
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<20{
            arrColor.append(UIColor.random)
        }
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "ColorCell")
        tb.delegate = self
        tb.dataSource = self

        
        tb.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("will display cell \(indexPath.row)")
        if indexPath.row >= arrColor.count - 5 && !tb.mj_footer!.isRefreshing{
                tb.mj_footer?.beginRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @objc func footerRefresh()  {
        _ = delay(time: 0.5) {
            for _ in 0..<20{
                self.arrColor.append(UIColor.random)
            }
            self.tb.reloadData()
            self.tb.mj_footer?.endRefreshing()
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("contextOffset \(scrollView.contentOffset.y)")
//        print("contextSize\(scrollView.contentSize)")
//        if scrollView.contentOffset.y >= scrollView.contentSize.height - ScreenHeight && !isLoadingMore{
//            tb.mj_footer?.beginRefreshing()
//            isLoadingMore = true
//        }
    }
    
    
}
