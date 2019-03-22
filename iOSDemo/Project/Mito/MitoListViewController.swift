//
//  MitoListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/21.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import MJRefresh
import Kingfisher
class MitoListViewController: UIViewController {
    
    
    var vCol: UICollectionView!
    var cat = 0 //图片类型
    var arrImageSets = [ImageSet]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = FlowLayout(columnCount: 2, columnMargin: 8) { [weak self] (index) -> Double in
           return Double(self!.arrImageSets[index.row].cellHeight)
        }
        
        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(ImageSetCell.self, forCellWithReuseIdentifier: "Cell")
        vCol.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        vCol.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
        view.addSubview(vCol)

        vCol.mj_header.beginRefreshing()
    }
    
    @objc func headerRefresh() {
        ImageSet.getImageSet(type: 0, cat: "全部", resolution: Resolution(), theme: "全部", index: 1) { (res) in
            self.vCol.mj_header.endRefreshing()
            if !handleResult(result: res){
                return
            }
            self.arrImageSets = res.data! as! [ImageSet]
            self.vCol.reloadData()
        }
    }
    
    @objc func footerRefresh() {
        
    }


}
extension MitoListViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageSets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageSetCell
        cell.imgSet = arrImageSets[indexPath.row]
        return cell
    }
    
    
}


class ImageSetCell: UICollectionViewCell {
    let img = UIImageView()
    let lblTitle = UILabel()
    let lblResolution = UILabel()
    let lblTheme = UILabel()
    
    var imgSet:ImageSet?{
        didSet{
            guard let i = imgSet else {
                return
                
            }
            let sour = ImageResource(downloadURL: URL(string: i.mainImage)!)
            img.kf.setImage(with: sour)
            lblTitle.text = i.title
            lblResolution.text = i.resolution.toString()
            lblTheme.text = i.theme
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.top.equalTo(5)
            m.right.equalTo(-5)
            m.height.greaterThanOrEqualTo(ScreenWidth / 3)
        }
        
        lblTitle.lineNum(num: 0).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.top.equalTo(img.snp.bottom).offset(10)
        }
        
        lblResolution.addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(lblTitle)
            m.top.equalTo(lblTitle.snp.bottom).offset(5)
            m.width.equalTo(120)
            m.bottom.equalTo(-5)
        }
        
        lblTheme.addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(lblTitle)
            m.top.equalTo(lblTitle.snp.bottom).offset(5)
            m.width.equalTo(60)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
