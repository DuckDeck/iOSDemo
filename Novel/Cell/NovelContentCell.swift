//
//  NovelContentCell.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
class NovelContentCell: UITableViewCell {

    fileprivate(set) var rootLayout:TGBaseLayout!

    let lblContent = UILabel()

    func setText(str:NSAttributedString) {
        lblContent.attributedText = str
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createLinearRootLayout()
    }
    
    func createLinearRootLayout()  {
        self.rootLayout = TGLinearLayout(.horz)
        self.rootLayout.tg_topPadding = 5
        self.rootLayout.tg_bottomPadding = 5
        self.rootLayout.tg_width.equal(.fill)
        self.rootLayout.tg_height.equal(.wrap)
        self.rootLayout.tg_padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.rootLayout.tg_cacheEstimatedRect = true
        self.contentView.addSubview(self.rootLayout)
        
        lblContent.numberOfLines = 0
        lblContent.tg_left.equal(0)
        lblContent.tg_top.equal(0)
        lblContent.tg_width.equal(.fill)
        lblContent.tg_height.equal(.wrap)
        rootLayout.addSubview(lblContent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return self.rootLayout.sizeThatFits(targetSize)
    }
    


}
