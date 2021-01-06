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
    var menu = [(String,UIImage)](){
        didSet{
            setMenu()
        }
    }
    
    var clickMenu:((_ index:Int,_ title:String) -> Void)?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        alpha = 0
        
        backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        
        vMenu.backgroundColor = UIColor.white
        
        img.addTo(view: vMenu).snp.makeConstraints { (m) in
            m.top.equalTo(NavigationBarHeight)
            m.left.right.equalTo(0)
            m.height.equalTo(0.6 * UIScreen.main.bounds.size.width)
        }
        img.image = UIImage(named: "3")
        
        
        addSubview(vMenu)
        vMenu.snp.makeConstraints { (m) in
            m.left.equalTo(UIScreen.main.bounds.size.width)
            m.top.bottom.equalTo(0)
            m.width.equalTo(0.6 * UIScreen.main.bounds.size.width)
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
        for i in 0..<menu.count {
            let btn = LayoutButton()
            btn.setTitle(menu[i].0, for: .normal)
            btn.setImage(menu[i].1, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 26)
            btn.imageSize = CGSize(width: 26, height: 26)
            btn.layoutStyle = .LeftImageRightTitle
            btn.midSpacing = 5
            btn.tag = i
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(clickMenu(sender:)), for: .touchUpInside)
            vMenu.addSubview(btn)
            btn.snp.makeConstraints { (m) in
                m.right.equalTo(-50)
                if previousBtn == nil{
                     m.top.equalTo(350)
                }
                else{
                     m.top.equalTo(previousBtn!.snp.bottom).offset(24)
                }
                m.height.equalTo(25)
                m.width.equalTo(100)
            }
            previousBtn = btn
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc func clickMenu(sender:LayoutButton)  {
        let index = sender.tag
        clickMenu?(index,menu[index].0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func expand() {
         self.alpha = 1
        UIView.animate(withDuration: 0.5, animations: {
            self.vMenu.snp.updateConstraints { (m) in
                m.left.equalTo(UIScreen.main.bounds.size.width * 0.4)
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
