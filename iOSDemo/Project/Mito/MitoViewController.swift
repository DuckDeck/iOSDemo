//
//  MitoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/13.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import GrandMenu
class MitoViewController: UIViewController {
    
    let vMenu = SlideMenuView()
    var isExpand = false
    let vTb = UICollectionView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let menu = ["全部":UIImage(named: "a3")!]
        vMenu.menu = menu
        
        view.addSubview(vMenu)
        //vMenu.expand()
        
        let btnOpenMenu = UIButton(type: .custom)
        btnOpenMenu.setImage(UIImage(named: "open_menu"), for: .normal)
        btnOpenMenu.frame = CGRect(x: 0, y: 0, w: 34, h: 34)
        btnOpenMenu.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btnOpenMenu.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnOpenMenu.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnOpenMenu)
        
        
        
    }
    
    @objc func openMenu()  {
        isExpand ? vMenu.collapse() : vMenu.expand()
        isExpand = !isExpand
    }
    
}


