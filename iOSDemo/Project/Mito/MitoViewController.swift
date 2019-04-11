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
    
    let arrMenu = ["全部","美女","性感","明星","风光","卡通","创意","汽车","游戏","建筑","影视","植物","动物",
                   "节庆","可爱","静物","体育","日历","唯美","其它","系统","动漫","非主流","小清新"]
    //let channels = ["电脑壁纸","手机壁纸","平板壁纸","精选一图","精选一图","我的收藏"]
    
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
            vc.cat = item
            arrControllers.append(vc)
        }
        
        grandMenu = GrandMenu(frame: CGRect(x: 0, y: 0, w: 260, h: 40), titles: arrMenu)
        grandMenu?.backgroundColor = UIColor.clear
        grandMenu?.selectMenu = {[weak self] (item:GrandMenuItem, index:Int) in
             self?.grandMenuTable?.contentViewCurrentIndex = index
        }
        grandMenu?.itemColor = UIColor.black
        grandMenu?.itemSeletedColor = UIColor.blue
        grandMenu?.itemFont = 16
        grandMenu?.itemSelectedFont = 17
        grandMenu?.averageManu = false
        grandMenu?.sliderColor = UIColor.blue
        grandMenu?.sliderBarLeftRightOffset = 8
        grandMenu?.sliderBarHeight = 2
        navigationItem.titleView = grandMenu
        
        grandMenuTable = GrandMenuTable(frame: CGRect(x: 0, y: NavigationBarHeight, width: ScreenWidth, height: ScreenHeight - NavigationBarHeight), childViewControllers: arrControllers, parentViewController: self)
        grandMenuTable?.scrollToIndex = {[weak self](index:Int)in
            self?.grandMenu?.selectSlideBarItemAtIndex(index)
            self?.currentDisplayTaskPageIndex = index
         
        }
        view.addSubview(grandMenuTable!)
     
        
        let menu = [("电脑壁纸",UIImage(named: "computer")!),
                    ("平板壁纸",UIImage(named: "tablet")!),
                    ("手机壁纸",UIImage(named: "phone")!),
                    ("精选一图",UIImage(named: "a3")!),
                    ("热门壁纸",UIImage(named: "a4")!),
                    ("动态壁纸",UIImage(named: "a5")!),
                    ("我的收藏",UIImage(named: "star_full")!),
                    ("关于美图",UIImage(named: "a11")!)]
        vMenu.menu = menu
        vMenu.clickMenu = { [weak self] (index,title) in
            self?.changeCat(index: index)
        }
        view.addSubview(vMenu)
        
    }
    
    @objc func openMenu()  {
        isExpand ? vMenu.collapse() : vMenu.expand()
        isExpand = !isExpand        
    }
    
    
    func changeCat(index:Int) {
        vMenu.collapse()
        if index <= 3{
            for vc in arrControllers{
                vc.channel = index
            }
        }
        
        if index == 4{
            let vc = HotMitoViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if index == 5{
            let vc = DynamicMitoViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if index == 6{
            let vc = CollectedViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if index == 7{
            let vc = AboutMitoViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}



