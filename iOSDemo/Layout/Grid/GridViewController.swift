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
    let sc = UIScrollView()
    var arr: Array<ConstraintView> = []
    var viewContainer = GridView()
    var arrViews = [UIView]()
    let viewDemo = UIView()
    let lbl = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grid"
        let btnAdd = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(add))
        let btnRemove = UIBarButtonItem(title: "Rem", style: .plain, target: self, action: #selector(remove))
        navigationItem.rightBarButtonItems = [btnAdd,btnRemove]
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(sc)
        sc.snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        sc.addSubview(viewDemo)
        viewDemo.backgroundColor = UIColor.yellow
        viewDemo.snp.makeConstraints { (m) in
            m.top.bottom.equalTo(sc)
            m.left.right.equalTo(view)
    
            //这种情况下还是不能让viewDemo的大小变化来改变Scrollviww的ContentSize
        }
        
        
        viewContainer.layer.borderWidth = 1
        viewDemo.addSubview(viewContainer)
        viewContainer.maxWidth = ScreenWidth - 20
        viewContainer.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.width.greaterThanOrEqualTo(150)
            m.top.equalTo(10)
            m.height.greaterThanOrEqualTo(150)
//            m.bottom.equalTo(-10)
        }
        
        for _ in 0..<1 {
            let subview = UIView()
            subview.backgroundColor = UIColor.random
            //viewContainer.addSubview(subview)
            
            arr.append(subview)
        }
        viewContainer.cellSize = CGSize(width: (ScreenWidth - 95) / 4, height: (ScreenWidth - 95) / 4)
        viewContainer.horizontalSpace = 15
        viewContainer.verticalSpace = 15
        viewContainer.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        viewContainer.padding = UIEdgeInsets(top: 20, left: 10, bottom: 40, right: 15)
        viewContainer.arrViews = arr
        
        lbl.text = "当一个女孩，看见她心爱的男孩下班后第一件事便是在出租屋里打游戏，周末宅在家里看片看综艺看动漫，你认为她在这个男孩身上看得见未来吗"
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.textColor = UIColor.red
        viewDemo.addSubview(lbl)
        lbl.numberOfLines = 0
        lbl.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(viewContainer.snp.bottom).offset(40)
            m.bottom.equalTo(-10)
        }
        //        固定大小,可变中间间距,上下左右间距默认为0,可以设置
        //arr.snp.distributeSudokuViews(fixedItemWidth: 100, fixedItemHeight: 100, warpCount: 3, horizontalSpace: 20, verticalSpace: 10, padding: UIEdgeInsets(top: 10, left: 10, bottom: 50, right: 10))
        
        
        
    }

    @objc func add()  {
        if 6.random() > 3{
            addView()
        }
        else{
            addImg()
        }
    }
    
    func addView() {
        print(viewDemo.frame)
        let subview = UIView()
        subview.backgroundColor = UIColor.random
        arr.append(subview)
        viewContainer.arrViews = arr
    }
    
    func addImg()  {
        let subview = UIImageView()
        subview.setImg(url: "http://d.5857.com/snhbqx_170628/001.jpg")
        
        subview.contentMode = .scaleAspectFill
        arr.append(subview)
        viewContainer.arrViews = arr
    }
    
    @objc func remove()  {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


