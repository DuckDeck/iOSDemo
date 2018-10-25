//
//  UITableView+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 21/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
extension UITableView{
    open func setEmptyView(view:UIView,offset:CGFloat)  {
        view.isHidden = true
        view.tag = -10000
        view.addTo(view: self).snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(self).offset(offset)
            m.width.greaterThanOrEqualTo(view.frame.size.width)
            m.height.greaterThanOrEqualTo(view.frame.size.height)
        }
    }
    
    open func emptyReload()  {
        var section = 1
        var count = 0
        if let numSection = dataSource!.numberOfSections?(in: self){
            section = numSection
        }
        for i in 0..<section{
            count += dataSource!.tableView(self, numberOfRowsInSection: i)
        }
        self.reloadData()
        if count <= 0{
            self.viewWithTag(-10000)?.isHidden = false
        }
        else{
            self.viewWithTag(-10000)?.isHidden = true
        }
        
    }
    
    public static func createEmptyView(size:CGSize,img:String,text:NSAttributedString)->UIView{
        let v = UIView(frame: CGRect(origin: CGPoint(), size: size))
        let image = UIImageView(image: UIImage(named: img))
        v.addSubview(image)
        image.snp.makeConstraints { (m) in
            m.top.equalTo(0)
            m.centerX.equalTo(v)
        }
        let lbl = UILabel()
        lbl.attributedText = text
        lbl.textAlignment = .center
        v.addSubview(lbl)
        lbl.snp.makeConstraints { (m) in
            m.bottom.equalTo(0)
            m.left.right.equalTo(0)
        }
        return v
    }
    
    public static func createEmptyView(size:CGSize,img:String,text:String,font:UIFont,color:UIColor)->UIView{
        let v = UIView(frame: CGRect(origin: CGPoint(), size: size))
        let image = UIImageView(image: UIImage(named: img))
        v.addSubview(image)
        image.snp.makeConstraints { (m) in
            m.top.equalTo(0)
            m.centerX.equalTo(v)
        }
        let lbl = UILabel()
        lbl.text = text
        lbl.font = font
        lbl.textColor = color
        lbl.textAlignment = .center
        v.addSubview(lbl)
        lbl.snp.makeConstraints { (m) in
            m.bottom.equalTo(0)
            m.left.right.equalTo(0)
        }
        return v
    }
    
    
    
    public static func createEmptyView(size:CGSize,text:NSAttributedString)->UIView{
        let v = UIView(frame: CGRect(origin: CGPoint(), size: size))
        let lbl = UILabel()
        lbl.attributedText = text
        lbl.textAlignment = .center
        v.addSubview(lbl)
        lbl.snp.makeConstraints { (m) in
            m.bottom.equalTo(0)
            m.left.right.equalTo(0)
        }
        return v
    }
    
    public static func createEmptyView(size:CGSize,text:String,font:UIFont,color:UIColor)->UIView{
        let v = UIView(frame: CGRect(origin: CGPoint(), size: size))
        let lbl = UILabel()
        lbl.text = text
        lbl.font = font
        lbl.textColor = color
        lbl.textAlignment = .center
        v.addSubview(lbl)
        lbl.snp.makeConstraints { (m) in
            m.bottom.equalTo(0)
            m.left.right.equalTo(0)
        }
        return v
    }
    
}


