//
//  NovelContentCell.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class NovelContentCell: UITableViewCell {

    let lblContent = UILabel()

    func setText(str:NSAttributedString) {
        lblContent.attributedText = str
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lblContent.numberOfLines = 0
        contentView.addSubview(lblContent)
        lblContent.snp.makeConstraints { (m) in
            m.edges.equalTo(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   


}
