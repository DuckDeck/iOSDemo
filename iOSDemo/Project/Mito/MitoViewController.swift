//
//  MitoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/13.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import GrandMenu

//doto 1: 空白页面
//doto 2: resolution 分类
//kingfish可能因为某种原来导致显示404


class MitoViewController: UIViewController {
    
    let vMenu = SlideMenuView()
    var isExpand = false
    var channel = 0
    var grandMenu:GrandMenu?
    var grandMenuTable:GrandMenuTable?
    var btnFilter = UIButton(frame: CGRect(x: 40, y: ScreenHeight - 100, width: 60, height: 60))
    let arrMenu = ["秀人网","美嫒錧","兔几盟","魅妍社"]
    
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
     
        
        let menu = [("秀人系列",UIImage(named: "computer")!),
                    ("精品套图",UIImage(named: "tablet")!),
                    ("我的收藏",UIImage(named: "star_full")!),
                    ("关于美图",UIImage(named: "a11")!)]
        vMenu.menu = menu
        vMenu.clickMenu = { [weak self] (index,title) in
            self?.changeCat(index: index)
        }
        view.addSubview(vMenu)
        
        btnFilter.setImage(UIImage(named: "filter"), for: .normal)
        btnFilter.layer.cornerRadius = 30
        btnFilter.backgroundColor = UIColor.cyan
        btnFilter.addTarget(self, action: #selector(changeResolution), for: .touchUpInside)
        view.addSubview(btnFilter)
        
        
        
    }
    
    @objc func changeResolution() {
        let vResolution = ResolutionFilterView(frame: UIScreen.main.bounds)
        switch channel {
        case 0,3:
            vResolution.arrFilters = Resolution.ComputorResolutions
        case 1:
            vResolution.arrFilters = Resolution.PadResolutions
        case 2:
            vResolution.arrFilters = Resolution.PhoneResolutions
        default:
            break
        }
        vResolution.selectBlock = {(res:Resolution) in
            for vc in self.arrControllers{
                vc.currentResolution = res
            }
            vResolution.removeFromSuperview()
        }
        UIApplication.shared.keyWindow?.addSubview(vResolution)
    }
    
    @objc func openMenu()  {
        isExpand ? vMenu.collapse() : vMenu.expand()
        isExpand = !isExpand        
    }
    
    
    func changeCat(index:Int) {
        vMenu.collapse()
        if index <= 3{
            channel = index
            for vc in arrControllers{
                vc._currentResolution = Resolution()
                vc.channel = index
            }
        }

        if index == 7{
            let vc = CollectedViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if index == 8{
            let vc = AboutMitoViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}



