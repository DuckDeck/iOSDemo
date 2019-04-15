//
//  FlowView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
//todo 完成FlowView

//protocol FlowViewDataSource{
//    func numOfCells(flowView:FlowView) -> Int
//    func cellFor(flowView:FlowView,index:Int)->UIView
//    func itemWidth(flowView:FlowView,index:Int)->Float
//}

class FlowView: UIView {

    var padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var horizontalSpace:CGFloat = 0
    var verticalSpace:CGFloat = 0
    var showLast = true
    var maxWidth = ScreenWidth
    var itemHeight:CGFloat = 20
    var fetchViewBlock : ((_ index:Int)->(UIView,Float,Bool))?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func loadView() {
        guard let blc = fetchViewBlock else {
            return
        }
        for sub in self.subviews{
            sub.removeFromSuperview()
        }
        var x = CGFloat(padding.left)
        var y = CGFloat(padding.top)
        var i = 0
        while true {
            let item = blc(i)
            if item.2{
                break
            }
            addSubview(item.0)
            
            // 查看看能不能安置
            print(item.1)
            let tmpWidth = x + CGFloat(item.1) + horizontalSpace + padding.right
            if tmpWidth > maxWidth{  //如果不行
                y = y + itemHeight + verticalSpace
                x = CGFloat(padding.left)
                item.0.snp.makeConstraints({ (m) in  //先安置好
                    m.left.equalTo(x)
                    m.top.equalTo(y)
                    m.width.equalTo(item.1)
                    m.height.equalTo(itemHeight)
                })
                x = x + CGFloat(item.1) + horizontalSpace
            }
            else{
                item.0.snp.makeConstraints({ (m) in  //先安置好
                    m.left.equalTo(x)
                    m.top.equalTo(y)
                    m.width.equalTo(item.1)
                    m.height.equalTo(itemHeight)
                })
                
                 x = x + CGFloat(item.1) + horizontalSpace
            }
            i = i + 1
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
