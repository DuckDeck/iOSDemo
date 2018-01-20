//
//  GridViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 20/01/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class GridViewController: UIViewController {
    var arr: Array<ConstraintView> = []
    var viewContainer = GridView()
    var arrViews = [UIView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grid"
        let btnAdd = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(add))
        let btnRemove = UIBarButtonItem(title: "Rem", style: .plain, target: self, action: #selector(remove))
        navigationItem.rightBarButtonItems = [btnAdd,btnRemove]
        
        view.backgroundColor = UIColor.white
        viewContainer.layer.borderWidth = 1
        view.addSubview(viewContainer)
        viewContainer.maxWidth = ScreenWidth
        viewContainer.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.width.greaterThanOrEqualTo(150)
            m.top.equalTo(100)
            m.height.greaterThanOrEqualTo(150)
        }
        
        for _ in 0..<9 {
            let subview = UIView()
            subview.backgroundColor = UIColor.random
            //viewContainer.addSubview(subview)
            
            arr.append(subview)
        }
        viewContainer.cellSize = CGSize(width: 100, height: 100)
        viewContainer.horizontalSpace = 20
        viewContainer.verticalSpace = 20
        viewContainer.padding = UIEdgeInsets(top: 20, left: 10, bottom: 40, right: 15)
        viewContainer.arrViews = arr
        
        //        固定大小,可变中间间距,上下左右间距默认为0,可以设置
        //arr.snp.distributeSudokuViews(fixedItemWidth: 100, fixedItemHeight: 100, warpCount: 3, horizontalSpace: 20, verticalSpace: 10, padding: UIEdgeInsets(top: 10, left: 10, bottom: 50, right: 10))
        
        
        
    }

    @objc func add()  {
        
    }
    
    @objc func remove()  {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
