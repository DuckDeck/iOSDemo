//
//  FlowView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
class FlowView: UIView {
    var tmpView:UIView?
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var horizontalSpace:CGFloat = 0
    var verticalSpace:CGFloat = 0
    var itemPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var maxWidth = UIScreen.main.bounds.size.width
    var itemBackground = UIColor.white
    var itemClickBlock:((_ index:Int,_ name:String)->Void)?
    var itemCornerRadius:CGFloat = 0
    var itemFont = UIFont.systemFont(ofSize: 14)
    var dataSourceBlock:((_ index:Int)->String)!
    
    var itemCount = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    public var flowHeight:CGFloat = 0
    func reloadData() {
        if dataSourceBlock == nil{
            return
        }
        if itemCount == 0{
            return
        }
        for item in self.subviews{
            item.removeFromSuperview()
        }
        var x = padding.left
        var y = padding.top
        for index in 0..<itemCount{
            let lbl = UILabel()
            lbl.text = dataSourceBlock(index)
            lbl.tag = index
            lbl.backgroundColor = itemBackground
            lbl.textAlignment = .center
            lbl.sizeToFit()
            lbl.font = itemFont
            lbl.layer.cornerRadius = itemCornerRadius
            lbl.clipsToBounds = true
            lbl.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemTap(ges:)))
            lbl.addGestureRecognizer(tap)
            addSubview(lbl)
            
            if tmpView == nil {
                
            }
            else{
                let tmpViewRight = tmpView!.frame.origin.x + tmpView!.frame.size.width
                if lbl.frame.size.width + horizontalSpace + itemPadding.left + itemPadding.right + padding.right + tmpViewRight >= maxWidth{
                    x = padding.left
                    y = tmpView!.frame.origin.y + tmpView!.frame.size.height + verticalSpace
                }
                else{
                    x = tmpViewRight + horizontalSpace
                }
            }
            lbl.snp.makeConstraints { (m) in
                m.left.equalTo(x)
                m.top.equalTo(y)
                m.width.equalTo(lbl.frame.size.width + itemPadding.left + itemPadding.right)
                m.height.equalTo(lbl.frame.size.height + itemPadding.top + itemPadding.bottom)

            }
            tmpView = lbl
            layoutIfNeeded()
        }
        var bottom:CGFloat = 0
        if tmpView != nil{
            bottom = tmpView!.frame.size.height + tmpView!.frame.origin.y + padding.bottom
        }
        self.snp.updateConstraints({ (m) in
            m.width.greaterThanOrEqualTo(maxWidth)
            m.height.greaterThanOrEqualTo(bottom)
        })
        flowHeight = bottom
    }
    
    @objc func itemTap(ges:UITapGestureRecognizer)  {
        if let lbl = ges.view as? UILabel{
            itemClickBlock?(lbl.tag,lbl.text!)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

