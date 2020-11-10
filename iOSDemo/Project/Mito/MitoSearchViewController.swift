//
//  MitoSearchViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class MitoSearchViewController: UIViewController,UITextFieldDelegate {

    var vCol: UICollectionView!
    var arrImageSets = [ImageSet]()
    var index = 1
    
    let txtSearch = UITextField()
    let btnSearch = UIButton()
    var key = "美女"
    let vHotSearch = GridView()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "壁纸搜索"
        view.backgroundColor = UIColor.white
        
        
        txtSearch.returnKeyType = .search
        txtSearch.delegate = self
        txtSearch.layer.borderWidth = 1
        txtSearch.layer.borderColor = UIColor.blue.cgColor
        txtSearch.placeholder = "美女"
        txtSearch.addOffsetView(value: 10)
        txtSearch.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.top.equalTo(NavigationBarHeight + 5)
            m.height.equalTo(36)
            m.right.equalTo(-75)
        }
        
        btnSearch.backgroundColor = UIColor.lightGray
        btnSearch.addTarget(self, action: #selector(searchKey), for: .touchUpInside)
        btnSearch.color(color: UIColor.blue).title(title: "搜索").addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(txtSearch)
            m.right.equalTo(-5)
            m.height.equalTo(36)
            m.left.equalTo(txtSearch.snp.right).offset(5)
        }
        
        let layout = FlowLayout(columnCount: 2, columnMargin: 8) { [weak self] (index) -> Double in
            
            let height = self!.arrImageSets[index.row].cellHeight
            print(height)
            return Double(height)
        }
        
        vCol = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(ImageSetCell.self, forCellWithReuseIdentifier: "Cell")
        vCol.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        vCol.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
        view.addSubview(vCol)
        vCol.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.top.equalTo(txtSearch.snp.bottom)
        }
        vCol.isHidden = true
        
        
        vHotSearch.cellSize = CGSize(width: 140, height: 25)
        vHotSearch.padding = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        vHotSearch.horizontalSpace = 20
        vHotSearch.verticalSpace = 10
        vHotSearch.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.width.greaterThanOrEqualTo(ScreenWidth)
            m.height.greaterThanOrEqualTo(ScreenHeight - 300)
            m.top.equalTo(txtSearch.snp.bottom)
        }
        
        
        
       
        
    }
    
    @objc func hotKeySearch(sender:UIButton)  {
        txtSearch.text = sender.title(for: .normal)
        searchKey()
    }
    
    @objc func searchKey(){
        txtSearch.resignFirstResponder()
        if txtSearch.text!.isEmpty{
            key = "美女"
        }
        else{
            key = txtSearch.text!
        }
        vCol.isHidden = false
        vHotSearch.isHidden = true
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchKey()
        return true
    }
    
    func loadData() {
        ImageSet.searchMito(key: key, index: index) { (res) in
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

extension MitoSearchViewController:UICollectionViewDataSource,UICollectionViewDelegate{
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
