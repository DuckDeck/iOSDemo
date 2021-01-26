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
    var itemClickBlock:((_ index:Int,_ item:UILabel)->Void)?
    var itemDeleteBlock:((_ index:Int,_ item:UILabel)->Void)?
    var itemCornerRadius:CGFloat = 0
    var itemFont = UIFont.systemFont(ofSize: 14)
    var dataSourceBlock:((_ index:Int)->String)!
    
    var itemCount = 0
    var defaultTextColor : UIColor?
    var selectedTextColor : UIColor?
    var defaultBorderColor : UIColor?
    var selectedBorderColor : UIColor?
    var isDefaultSelect = false
    var showDeleteButton = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    public var flowHeight:CGFloat = 0
    func reloadData() {
        for item in self.subviews{
            tmpView = nil
            item.removeFromSuperview()
        }
        if dataSourceBlock == nil{
            return
        }
        if itemCount == 0{
            self.snp.updateConstraints({ (m) in
                m.height.greaterThanOrEqualTo(0)
            })

            return
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
            lbl.isHighlighted = isDefaultSelect
            lbl.font = itemFont
            lbl.layer.cornerRadius = itemCornerRadius
            lbl.clipsToBounds = false
            lbl.isUserInteractionEnabled = true
            if defaultTextColor != nil{
                lbl.textColor = defaultTextColor!
            }

            if defaultBorderColor != nil{
                lbl.layer.borderWidth = 1
                lbl.layer.cornerRadius = 0
                lbl.layer.borderColor = defaultBorderColor!.cgColor
                
            }
            
            if isDefaultSelect{
                lbl.textColor = selectedTextColor!
                lbl.layer.borderColor = selectedBorderColor!.cgColor
            }

            
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
            if showDeleteButton{
                let btnDelete = UIButton()
                btnDelete.backgroundColor = UIColor.red
                btnDelete.layer.cornerRadius = 10
                btnDelete.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                btnDelete.setTitle("X", for: .normal)
                btnDelete.tag = index
                addSubview(btnDelete)
                btnDelete.snp.makeConstraints { (m) in
                    m.centerX.equalTo(lbl.snp.right)
                    m.centerY.equalTo(lbl.snp.top)
                    m.width.height.equalTo(20)
                }
                btnDelete.addTarget(self, action: #selector(itemDeleteTap(sender:)), for: .touchUpInside)
                
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
    
    @objc func itemDeleteTap(sender:UIButton){
        for v in subviews{
            if v is UILabel && v.tag == sender.tag{
                itemDeleteBlock?(v.tag,v as! UILabel)
            }
        }
    }
    
    @objc func itemTap(ges:UITapGestureRecognizer)  {
        
        if let lbl = ges.view as? UILabel{
            if !showDeleteButton{
                lbl.isHighlighted = !lbl.isHighlighted
                if selectedTextColor != nil && selectedBorderColor != nil && defaultTextColor != nil && selectedBorderColor != nil{
                    lbl.textColor = lbl.isHighlighted ? selectedTextColor! :  defaultTextColor!
                    lbl.layer.borderColor = lbl.isHighlighted ? selectedBorderColor!.cgColor : defaultBorderColor!.cgColor
                }
            }
            itemClickBlock?(lbl.tag,lbl)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
