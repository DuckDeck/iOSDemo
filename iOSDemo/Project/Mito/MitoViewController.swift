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
    
    var grandMenu:GrandMenu?
    var grandMenuTable:GrandMenuTable?
    
    var arrMenu = ["全部","美女","性感","明星","风光","卡通","创意","汽车","游戏","建筑","影视","植物","动物",
                   "节庆","可爱","静物","体育","日历","唯美","其它","系统","动漫","非主流","小清新"]
     var currentDisplayTaskPageIndex = 0
     var arrControllers = [MitoListViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        
        //vMenu.expand()
        
        let btnOpenMenu = UIButton(type: .custom)
        btnOpenMenu.setImage(UIImage(named: "open_menu"), for: .normal)
        btnOpenMenu.frame = CGRect(x: 0, y: 0, w: 34, h: 34)
        btnOpenMenu.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btnOpenMenu.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnOpenMenu.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnOpenMenu)
        
       
        for item in arrMenu{
            let vc = MitoListViewController()
            arrControllers.append(vc)
        }
        
        grandMenu = GrandMenu(frame: CGRect(x: 0, y: 0, w: 222, h: 40), titles: arrMenu)
        grandMenu?.backgroundColor = UIColor.clear
        grandMenu?.selectMenu = {[weak self] (item:GrandMenuItem, index:Int) in
             self?.grandMenuTable?.contentViewCurrentIndex = index
        }
        grandMenu?.itemColor = UIColor.lightGray
        grandMenu?.itemSeletedColor = UIColor.blue
        grandMenu?.itemFont = 16
        grandMenu?.itemSelectedFont = 17
        grandMenu?.averageManu = false
        grandMenu?.sliderColor = UIColor.white
        grandMenu?.sliderBarLeftRightOffset = 8
        grandMenu?.sliderBarHeight = 2
        navigationItem.titleView = grandMenu
        
        grandMenuTable = GrandMenuTable(frame: CGRect(x: 0, y: NavigationBarHeight, width: ScreenWidth, height: ScreenHeight - NavigationBarHeight), childViewControllers: arrControllers, parentViewController: self)
        grandMenuTable?.scrollToIndex = {[weak self](index:Int)in
            self?.grandMenu?.selectSlideBarItemAtIndex(index)
            self?.currentDisplayTaskPageIndex = index
         
        }
        view.addSubview(grandMenuTable!)
     
        
        let menu = ["全部":UIImage(named: "a3")!]
        vMenu.menu = menu
         view.addSubview(vMenu)
        
    }
    
    @objc func openMenu()  {
        isExpand ? vMenu.collapse() : vMenu.expand()
        isExpand = !isExpand        
    }
    
}



