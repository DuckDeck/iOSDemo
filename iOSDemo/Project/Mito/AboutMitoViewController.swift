//
//  AboutMitoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/8.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
class AboutMitoViewController: UIViewController {

    let lbl = UILabel()
    let btnCleanCache = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "关于美图"
        view.backgroundColor = UIColor.white
        lbl.text = "这是一款看图片的软件，图片来源是5857壁纸站，图片质量高美女也多，因为官方的APP很不好用，还有广告，我就写了这个APP，通过解析HTML实现加载显示图片，还有图片批量下载功能。/n 注意有的分辨率打不开是因为网站有问题"
        lbl.lineNum(num: 0).color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(150)
            m.left.equalTo(15)
            m.right.equalTo(-25)
        }
        
        btnCleanCache.color(color: UIColor.darkGray).title(title: "清空缓存").addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(lbl.snp.bottom).offset(10)
            m.centerX.equalTo(view)
        }
        
        btnCleanCache.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
        
    }
    
    @objc func clearCache(){
        KingfisherManager.shared.cache.clearDiskCache()
        let files = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        for file in files{
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file)
            if !url.isFlod{
                try? FileManager.default.removeItem(at: url)
            }
            
        }
        Toast.showToast(msg: "成功清空缓存")
    }
 

}
