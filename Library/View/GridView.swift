//
//  GridView.swift
//
//  Created by Stan Hu on 28/11/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//

import UIKit

class GridView: UIView {

    var cellSize = CGSize()

    var padding:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var horizontalSpace:CGFloat = 0
    var verticalSpace:CGFloat = 0
    var showLast = true
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
                    for i in 0..<count{
                        views[i].frame = CGRect(x: x, y: y, width:  cellSize.width, height: cellSize.height)
                        addSubview(views[i])
                        if x + horizontalSpace + cellSize.width * 2 + padding.right <= frame.size.width{
                            x = x + horizontalSpace + cellSize.width
                        }
                        else{
                            x = CGFloat(padding.left)
                            y = y + verticalSpace + cellSize.height
                        }
                    }
                frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: views[count - 1].frame.origin.y + views[count - 1].frame.size.height + verticalSpace)
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
