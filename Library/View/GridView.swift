//
//  GridView.swift
//
//  Created by Stan Hu on 28/11/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//

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
                    var right:CGFloat  = 0
                    for i in 0..<count{
                        addSubview(views[i])
                        views[i].snp.makeConstraints({ (m) in
                            m.left.equalTo(x)
                            m.top.equalTo(y)
                            m.size.equalTo(cellSize)
                        })
                        if i == count - 1{
                            break
                        }
                        if x + horizontalSpace + cellSize.width * 2 + padding.right <= maxWidth{
                            x = x + horizontalSpace + cellSize.width
                        }
                        else{
                            right = x  + cellSize.width + padding.right
                            x = CGFloat(padding.left)
                            y = y + verticalSpace + cellSize.height
                        }
                    }
                self.snp.updateConstraints({ (m) in
                    m.width.greaterThanOrEqualTo(right)
                    m.height.greaterThanOrEqualTo(y - verticalSpace + cellSize.height + padding.bottom)
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

