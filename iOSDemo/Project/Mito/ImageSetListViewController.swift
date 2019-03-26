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
    override func viewDidLoad() {
        super.viewDidLoad()
        tb.tableFooterView = UIView()
        tb.dataSource = self
        tb.delegate = self
        tb.register(ImageSetInfoCell.self, forCellReuseIdentifier: "ImageCell")
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        // Do any additional setup after loading the view.
    }
    
    func initData() {
        
    }
    
 

}

extension ImageSetListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
        let url = arrImages[indexPath.row]
        let sour = ImageResource(downloadURL: URL(string: url)!)
        cell.imageView?.kf.setImage(with: sour)
        return cell
    }
    
    
}

class ImageSetInfoCell: UITableViewCell {
    
    let img = UIImageView()
    let btnDownload = UIButton()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        img.addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.right.top.equalTo(0)
        }
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
