//
//  WordsCell.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import UIKit
class WordsCell: UICollectionViewCell {
    
    var wordslabel = UILabel()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
//        self.backgroundColor = UIColor.brown
//        self.contentView.backgroundColor = UIColor.red
        wordslabel.textAlignment = .center
        wordslabel.sizeToFit()
        wordslabel.font = UIFont.preferredFont(forTextStyle: .title3)
        wordslabel.textColor = UIColor.black

        self.contentView.addSubview(wordslabel)
        
        self.contentView.snp.makeConstraints({ (make) -> Void in
            make.top.left.equalToSuperview()
            make.height.equalTo(bannerHeight*2/5)
            make.right.equalTo(wordslabel)
        })
        
        wordslabel.snp.makeConstraints({ (make) -> Void in
            make.left.top.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(46.875).priority(1000)
        })

    }
    
    
//    override func layoutSubviews() {
//
//        super.layoutSubviews()
//
//
//
//    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
