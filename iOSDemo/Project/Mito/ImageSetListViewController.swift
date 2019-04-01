//
//  ImageSetListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/25.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
class ImageSetListViewController: UIViewController {

    let tb = UITableView()
    var imageSet:ImageSet?
    var arrImages = [String]()
    let btnDownload = UIButton()
    let btnCollect = UIButton(type: .custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = imageSet!.title
        btnCollect.setImage(UIImage(named: "star_hollow"), for: .normal)
        btnCollect.frame = CGRect(x: 0, y: 0, w: 34, h: 34)
        btnCollect.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btnCollect.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnCollect.addTarget(self, action: #selector(collect), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnCollect)
        
        tb.separatorStyle = .none
        tb.tableFooterView = UIView()
        tb.dataSource = self
        tb.delegate = self
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
        btnDownload.imageView?.contentMode = .scaleAspectFill
        btnDownload.setImage(UIImage(named: "download-arrow"), for: .normal)
        btnDownload.addTarget(self, action: #selector(download), for: .touchUpInside)
        btnDownload.addTo(view: view).snp.makeConstraints { (m) in
            m.right.equalTo(-50)
            m.bottom.equalTo(-50)
            m.width.height.equalTo(60)
        }
        
        
        initData()
        
    }
    
    @objc func collect()  {
        
    }
    
    @objc func download()  {
        UIAlertController.init(title: "下载图片", message: "你要下载全部图片吗", preferredStyle: .alert).action(title: "取消", handle: nil).action(title: "确定", handle: {(action:UIAlertAction) in
            
        }).show()
    }
    
    func initData() {
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
        let sour = ImageResource(downloadURL: URL(string: url)!)
        cell.img.kf.setImage(with: sour)
        return cell
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
            m.edges.equalTo(4)
        }
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
