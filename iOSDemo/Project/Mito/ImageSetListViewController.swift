//
//  ImageSetListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/25.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
import Photos
class ImageSetListViewController: UIViewController {

    let tb = UITableView()
    var imageSet:ImageSet?
    var arrImages = [String]()
    let btnDownload = UIButton()
    let btnCollect = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = imageSet!.title
        
        
        let img = MitoConfig.isContain(imageSet: imageSet!) ? UIImage(named: "star_full") : UIImage(named: "star_hollow")
        
        
        btnCollect.setImage(img, for: .normal)
        btnCollect.frame = CGRect(x: 0, y: 0, w: 34, h: 34)
        btnCollect.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btnCollect.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnCollect.addTarget(self, action: #selector(collect), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnCollect)
        
        tb.separatorStyle = .none
        tb.tableFooterView = UIView()
        tb.dataSource = self
        tb.delegate = self
        if imageSet!.resolution == nil{
            imageSet!.resolution = Resolution(resolution: imageSet!.resolutionStr)
        }
        tb.rowHeight = ScreenWidth / CGFloat(imageSet!.resolution.ratio) 
        tb.register(ImageSetInfoCell.self, forCellReuseIdentifier: "ImageCell")
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        btnDownload.layer.cornerRadius = 30
        btnDownload.layer.borderColor = UIColor.orange.cgColor
        btnDownload.layer.borderWidth = 2
        btnDownload.backgroundColor = UIColor.orange
        btnDownload.setTitle("下载", for: .normal)
        btnDownload.addTarget(self, action: #selector(download), for: .touchUpInside)
        btnDownload.addTo(view: view).snp.makeConstraints { (m) in
            m.right.equalTo(-40)
            m.bottom.equalTo(-50)
            m.width.height.equalTo(60)
        }
        
        
        initData()
        
        
        
    }
    
    @objc func collect()  {
        if MitoConfig.isContain(imageSet: imageSet!){
            MitoConfig.remove(imageSet: imageSet!)
            btnCollect.setImage(UIImage(named: "star_hollow"), for: .normal)
            Toast.showToast(msg: "取消收藏")
        }
        else{
            MitoConfig.collect(imageSet: imageSet!)
            btnCollect.setImage(UIImage(named: "star_full"), for: .normal)
            Toast.showToast(msg: "成功收藏")
        }
    }
    
    @objc func download()  {
        UIAlertController.init(title: "下载图片", message: "你要下载全部图片吗", preferredStyle: .alert).action(title: "取消", handle: nil).action(title: "确定", handle: {(action:UIAlertAction) in
            self.savaPhoto()
        }).show()
    }
    
    func savaPhoto() {
       let count = arrImages.count
        var current = 0
        let downLoader = ImageDownloader.default
        for item in arrImages{
            downLoader.downloadImage(with: URL(string: item)!, options: nil, progressBlock: nil) { (res) in
                switch res{
                case .success(let img):
                    img.image.saveToAlbum()
                    current += 1
                    if(current == count){
                        Toast.showToast(msg: "图片全部下载完")
                    }
                case .failure(let error):
                    Toast.showToast(msg: error.failureReason!)
                }
            }
        }
       
    }
    
    func initData() {
        Toast.showLoading()
        ImageSet.getImageSetList(url: imageSet!.url) { (result) in
            if !handleResult(result: result){
                return
            }
            self.arrImages = result.data! as! [String]
            
            self.tb.reloadData()
        }
    }
    
 

}

extension ImageSetListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageSetInfoCell
        let url = arrImages[indexPath.row]
        cell.img.setImg(url: url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vImageBroswer = ImageBrowserViewController()
        vImageBroswer.arrImages = self.arrImages
        vImageBroswer.currentIndex = indexPath.row
        present(vImageBroswer, animated: true, completion: nil)
    }
    
}

class ImageSetInfoCell: UITableViewCell {
    
    let img = UIImageView()
    let btnDownload = UIButton()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.top.equalTo(4)
            m.bottom.right.equalTo(-4)
        }
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
