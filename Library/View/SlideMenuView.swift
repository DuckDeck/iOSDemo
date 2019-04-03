//
//  SlideMenuView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/13.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
//一个可以左右抽屉式滑出的菜单，等待完成
//目前这个从右边出来
class SlideMenuView: UIView {

    let vMenu = UIView()
    let img = UIImageView()
    var menu = [String:UIImage](){
        didSet{
            setMenu()
        }
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        alpha = 0
        
        backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        
        vMenu.backgroundColor = UIColor.white
        
        img.addTo(view: vMenu).snp.makeConstraints { (m) in
            m.top.equalTo(NavigationBarHeight)
            m.left.right.equalTo(0)
            m.height.equalTo(0.5 * UIScreen.main.bounds.size.width)
        }
        img.image = UIImage(named: "3")
        
        
        addSubview(vMenu)
        vMenu.snp.makeConstraints { (m) in
            m.left.equalTo(UIScreen.main.bounds.size.width)
            m.top.bottom.equalTo(0)
            m.width.equalTo(0.5 * UIScreen.main.bounds.size.width)
        }
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(collapse))
        swipe.direction = .right
        self.addGestureRecognizer(swipe)
        
        let vBlank = UIView()
        vBlank.addTo(view: self).snp.makeConstraints { (m) in
            m.left.top.bottom.equalTo(0)
            m.width.equalTo(0.4 * UIScreen.main.bounds.size.width)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(collapse))
        vBlank.addGestureRecognizer(tap)
    }
    
    func setMenu()  {
        var previousBtn:UIButton?
        for item in menu {
            let btn = JXLayoutButton()
            btn.setTitle(item.key, for: .normal)
            btn.setImage(item.value, for: .normal)
            btn.imageSize = CGSize(width: 20, height: 20)
            btn.layoutStyle = .leftImageRightTitle
            btn.midSpacing = 5
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(clickMenu), for: .touchUpInside)
            vMenu.addSubview(btn)
            btn.snp.makeConstraints { (m) in
                m.right.equalTo(-30)
                if previousBtn == nil{
                     m.top.equalTo(360)
                }
                else{
                     m.top.equalTo(previousBtn!.snp.bottom).offset(10)
                }
                m.height.equalTo(25)
                m.width.equalTo(60)
            }
            previousBtn = btn
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc func clickMenu()  {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func expand() {
         self.alpha = 1
        UIView.animate(withDuration: 0.5, animations: {
            self.vMenu.snp.updateConstraints { (m) in
                m.left.equalTo(UIScreen.main.bounds.size.width * 0.5)
            }
            self.layoutIfNeeded()
        }) 
        
    }
    
    @objc func collapse(){
        UIView.animate(withDuration: 0.5, animations: {
            self.vMenu.snp.updateConstraints { (m) in
                m.left.equalTo(UIScreen.main.bounds.size.width)
            }
            self.layoutIfNeeded()
        }) { (finish) in
            if finish{
                 self.alpha = 0
            }
        }
    }
    
}
