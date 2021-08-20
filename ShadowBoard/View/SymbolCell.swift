//
//  SymbolCell.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import UIKit
class SymbolCell: UICollectionViewCell {
    
    var keyView: KeyView?
    let line = UIView()
    let line1 = UIView()
    var index: Int?
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }

    func addPinyin(_ pinyin: String, index: Int) {
        let key = Key(withTitle: pinyin, andType: .pinyin)
        key.index = index
        addKey(key)
    }
    
    func addKey(_ key: Key) {
        
        keyView = KeyView(withKey: key)
        
        self.contentView.addSubview(keyView!)
        self.contentView.addSubview(line)
//        self.contentView.addSubview(line1)
        line.backgroundColor = lineColor
//        line1.backgroundColor = lineColor
        
        keyView?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalToSuperview()
        })
        line.snp.makeConstraints({ (make) -> Void in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(lineThickness)
        })
//        line1.snp.makeConstraints({ (make) -> Void in
//            make.top.right.bottom.equalToSuperview()
//            make.width.equalTo(lineThickness)
//        })
    }
    
//    init(withKey key: Key) {
//
//        keyView = KeyView(withKey: key)
//        super.init(frame: CGRect.zero)
//
//        self.addSubview(keyView)
//
//    }

    override func layoutSubviews() {

        super.layoutSubviews()
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
