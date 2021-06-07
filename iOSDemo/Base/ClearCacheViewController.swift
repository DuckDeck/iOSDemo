//
//  ClearCacheViewController.swift
//  iOSDemo
//
//  Created by chen liang on 2021/6/3.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
class ClearCacheViewController: BaseViewController {
    
    let lblSize = UILabel()
    let btnClear = UIButton()
    
    override func viewDidLoad() {
        lblSize.textColor = UIColor.darkGray
        view.addSubview(lblSize)
        lblSize.snp.makeConstraints { m in
            m.left.right.equalTo(0)
            m.top.equalTo(100)
        }
        
        btnClear.setTitle("清空缓存", for: .normal)
        btnClear.setTitleColor(UIColor.purple, for: .normal)
        btnClear.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
        view.addSubview(btnClear)
        btnClear.snp.makeConstraints { m in
            m.top.equalTo(150)
            m.width.equalTo(200)
            m.height.equalTo(40)
            m.centerX.equalTo(view)
        }
        
        folderSizeAtPath { size in
            print(size)
        }
        
    }
    
    func folderSizeAtPath(completed:@escaping (_ size:Double?)->Void)  {
        let manager = FileManager.default
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        
        var fileSize = 0.0
        DispatchQueue.global().async {
            if manager.fileExists(atPath: cachePath) {
                if let childFiles = manager.subpaths(atPath: cachePath){
                    for fileName in childFiles {
                        let aPath = cachePath + "/" + fileName
                        let size = aPath.fileSizeAtPath() ?? 0
                        fileSize += size
                    }
                }
                 KingfisherManager.shared.cache.calculateDiskStorageSize(completion: { res in
                   let imgSize =  try? res.get()
                    print(imgSize ?? 0)
                    completed(fileSize)
                })
                
                
            }
            else{
                completed(nil)
            }
        }
       
    }

    
    @objc func clearCache() {
        
    }
}
