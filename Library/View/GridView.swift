//
//  GridView.swift
//
//  Created by Stan Hu on 28/11/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//

//功能基本正常
import UIKit
import SnapKit
class GridView: UIView {
    var cellSize = CGSize()
    var padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var horizontalSpace:CGFloat = 0
    var verticalSpace:CGFloat = 0
    var showLast = true
    var maxWidth = ScreenWidth
    var arrViews:[UIView]?{
        didSet{
            if let views = arrViews{
                    for sub in self.subviews{
                        sub.removeFromSuperview()
                    }
                    var x = CGFloat(padding.left)
                    var y = CGFloat(padding.top)
                    let count = showLast ? views.count : views.count - 1
                    if count <= 0{
                        return
                    }
                    var isSwitch = false
                    var isNewRow = false
                    var right:CGFloat = 0
                    for i in 0..<count{
                        addSubview(views[i])
                        views[i].snp.makeConstraints({ (m) in
                            m.left.equalTo(x)
                            m.top.equalTo(y)
                            m.size.equalTo(cellSize)
                        })
                        
                        if x + horizontalSpace + cellSize.width * 2  + padding.right <= maxWidth{
                            x = x + horizontalSpace + cellSize.width
                            isNewRow = false
                        }
                        else{
                            isSwitch = true
                            isNewRow = true
                            x = CGFloat(padding.left)
                            y = y + verticalSpace + cellSize.height
                        }
                        Log(message: "x: \(x)")
                        Log(message: "right: \(right)")
                        if !isSwitch{
                            right = x - horizontalSpace +  padding.right
                        }
                    }
                    if right <= maxWidth{
                        right = maxWidth
                    }
                    self.snp.updateConstraints({ (m) in
                        m.width.greaterThanOrEqualTo(right)
                        var b:CGFloat = 0
                        if isNewRow{
                            b = y - verticalSpace + padding.bottom
                        }
                        else{
                            b = y + padding.bottom + cellSize.height
                        }
                        m.height.greaterThanOrEqualTo(b)
                    })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

