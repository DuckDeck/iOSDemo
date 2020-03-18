//
//  HotMitoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/10.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class HotMitoViewController: UIViewController {

     var vCol: UICollectionView!
     var arrImageSets = [ImageSet]()
    var index = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "热门壁纸"
        
        let layout = FlowLayout(columnCount: 2, columnMargin: 8) { [weak self] (index) -> Double in
            
            let height = self!.arrImageSets[index.row].cellHeight
            print(height)
            return Double(height)
        }
        
        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(ImageSetCell.self, forCellWithReuseIdentifier: "Cell")
        vCol.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        vCol.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
        view.addSubview(vCol)
        
        vCol.mj_header?.beginRefreshing()
        
    }

    @objc func headerRefresh() {
        index = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        index += 1
        loadData()
    }
    
    func loadData() {
        
        ImageSet.getHotImageSet(index: index) { (res) in
            self.vCol.mj_header?.endRefreshing()
            
            if !handleResult(result: res){
                return
            }
            if self.index == 1{
                self.arrImageSets = res.data! as! [ImageSet]
            }
            else{
                let imgs = res.data! as! [ImageSet]
                if imgs.count <= 0{
                    self.vCol.mj_footer?.endRefreshingWithNoMoreData()
                }
                else{
                    self.arrImageSets += res.data! as! [ImageSet]
                    self.vCol.mj_footer?.endRefreshing()
                }
            }
            
            self.vCol.reloadData()
        }
    }

}

extension HotMitoViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageSets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageSetCell
        cell.imgSet = arrImageSets[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = arrImageSets[indexPath.row]
        let vc = ImageSetListViewController()
        vc.imageSet = item
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
