//
//  BinarySearchViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/9/7.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit

class BinarySearchViewController: UIViewController {

    let lblQus = UILabel()
    let btnBasic = UIButton()
    let arrIntro = ["最基本的二分查找就是从数组的中间取数。再和给定的数据比较大小，根据比较的结果缩小搜索范围，再重复前面的搜索过程，时间复杂度是O[logn]，空间复杂度是O[1]",
    "如果这个已经排好序的数组的内部元素分布十分不均匀，那么二分查找执行起来效率会有所降低"]
    let arrCode = [["123"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        lblQus.text(text: "二分搜索是一种从一个有序(有般是小到大)的数组中找出给定的一个指定元素,因为是有序的，所以每次都可以取该数组中间的一个数和给定的数比较小，再根据大小从新的区域重复这个查找过程，因此可以使用递归和循环来实现。").lineNum(num: 0).setFont(font: 13).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.top.equalTo(NavigationBarHeight)
            
        }
        
        btnBasic.title(title: "查看最基本的二分查找写法").color(color: UIColor.blue).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.top.equalTo(lblQus.snp.bottom).offset(10)
            m.height.equalTo(30)
        }
        btnBasic.addTarget(self, action: #selector(basicBinarySearch), for: .touchUpInside)
        
    }
    
    @objc func basicBinarySearch() {
        let vc = SearchDemoViewController()
        vc.strDesc = arrIntro[1]
        present(vc, animated: true, completion: nil)
    }

   

}
