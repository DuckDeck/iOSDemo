//
//  CityTableViewCell.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

 
    let btnWidth = (ScreenWidth - 75) / 3
    let btnHeight:CGFloat = 34
    var cityChooseBlock:((_ city:AddressInfo)->Void)?
    
    var info: [AddressInfo]? {
        didSet {
            if let cities = info {
                for v in contentView.subviews{
                    v.removeFromSuperview()
                }
                var i = 0
                while i < cities.count {
                    
                    let f = CGRect(x: CGFloat(i % 3) * (btnWidth + 10) + 15, y: 10 + CGFloat( i / 3) * (btnHeight + 10) , width: btnWidth, height: btnHeight)
                    let btn = UIButton(frame: f).title(title: cities[i].city).color(color: UIColor.Hex(hexString: "#f64950")).bgColor(color: UIColor.white).cornerRadius(radius: 4).borderWidth(width: lineHeight).borderColor(color: UIColor.Hex(hexString: "#f64950"))
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    btn.tag = cities[i].areaId
                    btn.addTarget(self, action: #selector(CityTableViewCell.btnClick(sender:)), for: .touchUpInside)
                    contentView.addSubview(btn)
                    i = i + 1
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?,cities:[(String,Int)]) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.Hex(hexString: "#f0f0f1")
        var i = 0
        while i < cities.count {
            let f = CGRect(x: CGFloat(i % 3) * (btnWidth + 10) + 15, y: 10 + CGFloat( i / 3) * (btnHeight + 10) , width: btnWidth, height: btnHeight)
            let btn = UIButton(frame: f).title(title: cities[i].0).color(color: UIColor.Hex(hexString: "#f64950")).bgColor(color: UIColor.white).cornerRadius(radius: 4).borderWidth(width: lineHeight).borderColor(color: UIColor.Hex(hexString: "#f64950"))
            btn.tag = cities[i].1
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(self, action: #selector(CityTableViewCell.btnClick(sender:)), for: .touchUpInside)
            addSubview(btn)
            i = i + 1
        }
    }
    
    @objc func btnClick(sender:UIButton)  {
        var c = AddressInfo()
        if let blk = cityChooseBlock {
            c.city = sender.title(for: .normal)!
            c.areaId = sender.tag
            blk(c)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
