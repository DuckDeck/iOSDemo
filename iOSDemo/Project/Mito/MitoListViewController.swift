//
//  MitoListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/21.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import MJRefresh
class MitoListViewController: UIViewController {
    
    
    var vCol: UICollectionView!
    var cat = 0 //图片类型
    var arrImageSets = [ImageSet]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = FlowLayout(columnCount: 3, columnMargin: 8) { (index) -> Double in
           return 100
        }
        
        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        vCol.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        vCol.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
        view.addSubview(vCol)

        vCol.mj_header.beginRefreshing()
    }
    
    @objc func headerRefresh() {
        ImageSet.getImageSet(type: 0, cat: "全部", resolution: Resolution(), theme: "全部", index: 1) { (res) in
            if !handleResult(result: res){
                return
            }
            print(res)
        }
    }
    
    @objc func footerRefresh() {
        
    }


}
extension MitoListViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.random
        return cell
    }
    
    
}


class ImageSetCell: UICollectionViewCell {
    
}
