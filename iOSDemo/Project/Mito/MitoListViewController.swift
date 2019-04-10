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
    var imgType = 0
    var vCol: UICollectionView!
    var cat = "" //图片类型
    var _channel = 0
    var channel :Int{
        set{
            if _channel != newValue{
                _channel = newValue
                if vCol != nil{
                    vCol.mj_header.beginRefreshing()
                }
            }
        }
        get{
            return _channel
        }
    }
    var arrImageSets = [ImageSet]()
    var index = 1
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
        index = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        index += 1
        loadData()
    }
    
    func loadData() {
        if imgType == 0{
            ImageSet.getImageSet(type: channel, cat: cat, resolution: Resolution(), theme: "全部", index: index) { (res) in
                self.vCol.mj_header.endRefreshing()
                if !handleResult(result: res){
                    return
                }
                if self.index == 1{
                    self.arrImageSets = res.data! as! [ImageSet]
                }
                else{
                    let imgs = res.data! as! [ImageSet]
                    if imgs.count <= 0{
                        self.vCol.mj_footer.endRefreshingWithNoMoreData()
                    }
                    else{
                        self.arrImageSets += res.data! as! [ImageSet]
                        self.vCol.mj_footer.endRefreshing()
                    }
                }
                
                self.vCol.reloadData()
            }
        }
        else{
            ImageSet.getDynamicImage(cat: cat, index: index) { (res) in
                self.vCol.mj_header.endRefreshing()
                if !handleResult(result: res){
                    return
                }
                if self.index == 1{
                    self.arrImageSets = res.data! as! [ImageSet]
                }
                else{
                    let imgs = res.data! as! [ImageSet]
                    if imgs.count <= 0{
                        self.vCol.mj_footer.endRefreshingWithNoMoreData()
                    }
                    else{
                        self.arrImageSets += res.data! as! [ImageSet]
                        self.vCol.mj_footer.endRefreshing()
                    }
                }
                
                self.vCol.reloadData()
            }
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imgType == 0{
            let item = arrImageSets[indexPath.row]
            let vc = ImageSetListViewController()
            vc.imageSet = item
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let item = arrImageSets[indexPath.row]
            Toast.showLoading(txt: "获取视频链接中...")
            ImageSet.getVideoLink(url: item.url) { (res) in
                if !handleResult(result: res){
                    return
                }
                item.videoLink = res.data! as! String
                let vc = MitoPlayViewController()
                vc.item = item
                self.navigationController?.present(vc, animated: true, completion: nil)
                
            }
           
        }
       
    }
    
}


class ImageSetCell: UICollectionViewCell {
    let img = UIImageView()
    let lblTitle = UILabel()
    let lblTag = UILabel()
    let lblResolution = UILabel()
    let lblTheme = UILabel()
    
    var imgSet:ImageSet?{
        didSet{
            guard let i = imgSet else {
                return
                
            }
            img.setImg(url: i.mainImage)
            img.layer.borderColor = i.theme.toColor().cgColor
            lblTitle.text = i.title
            lblResolution.text = i.resolutionStr
            lblTheme.text = i.theme
            lblTag.text = i.category
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.borderWidth = 1
        img.addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.top.equalTo(5)
            m.right.equalTo(-5)
            m.height.greaterThanOrEqualTo(ScreenWidth / 3.5)
        }
        
        lblTitle.lineNum(num: 0).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.top.equalTo(img.snp.bottom).offset(10)
            m.height.equalTo(15)
        }
        
        lblTag.color(color: UIColor.darkGray).setFont(font: 13).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(lblTitle)
            m.top.equalTo(lblTitle.snp.bottom).offset(10)
            m.bottom.equalTo(-5)
            m.height.equalTo(20)
        }
        
        lblResolution.color(color: UIColor.darkGray).setFont(font: 13).addTo(view: contentView).snp.makeConstraints { (m) in
            m.centerX.equalTo(contentView)
            m.top.equalTo(lblTitle.snp.bottom).offset(10)
            m.bottom.equalTo(-5)
            m.height.equalTo(20)
        }
        
        lblTheme.color(color: UIColor.darkGray).setFont(font: 13).addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(lblTitle)
            m.top.equalTo(lblTitle.snp.bottom).offset(10)
            m.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
