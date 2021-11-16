//
//  menuCellTableViewCell.swift
//  DemoLayout
//
//  Created by Stan Hu on 11/6/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

open class GrandCellTableViewCell: UITableViewCell {

   open  var  pageContentView:GrandPageContentView?
   open  var vcs = [UIViewController]()
   open  var cellCanScroll = false{
        didSet{
            for vc in vcs{
                if let v = vc as? GrandContentViewController{
                    v.canScroll = cellCanScroll
                    v.tableView.contentOffset = CGPoint()
                }
            }
        }
    }
}
