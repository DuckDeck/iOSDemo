//
//  NovelTbCell.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class NovelTbCell: UITableViewCell {
   
    let imgNovel = UIImageView()
    let lblTitle = UILabel()
    let lblIntro = UILabel()
    let lblAuthor = UILabel()
    let lblType = UILabel()
    let lblUpdateTime = UILabel()
    var novelIndo:NovelInfo?{
        didSet{
            imgNovel.kf.setImage(with: URL(string: novelIndo!.img)!)
            lblTitle.text = novelIndo?.title
            lblIntro.text = novelIndo?.Intro
            lblAuthor.text = novelIndo?.author
            lblType.text = novelIndo?.novelType
            lblUpdateTime.text = novelIndo?.updateTimeStr
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

        lblTitle.setFont(font: 16).completed()
        lblIntro.lineNum(num: 3).setFont(font: 13).completed()
        lblAuthor.setFont(font: 13).completed()
        lblType.setFont(font: 13).completed()
        lblUpdateTime.setFont(font: 13).completed()
        
        createLinearRootLayout()
    }
    
    func createLinearRootLayout()  {
      
      
        imgNovel.cornerRadius(radius: 5).completed()
        contentView.addSubview(imgNovel)
        imgNovel.snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(10)
            m.width.equalTo(100)
            m.height.equalTo(150)
            m.bottom.equalTo(-20)
        }
        
        contentView.addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (m) in
            m.left.equalTo(140)
            m.top.equalTo(10)
            m.height.equalTo(16)
        }
        
      
        contentView.addSubview(lblIntro)
        lblIntro.snp.makeConstraints { (m) in
            m.top.equalTo(lblTitle.snp.bottom).offset(5)
            m.left.equalTo(lblTitle)
            m.height.equalTo(16)
        }
        
        
     
        contentView.addSubview(lblAuthor)
        lblAuthor.snp.makeConstraints { (m) in
            m.top.equalTo(lblIntro.snp.bottom).offset(5)
            m.left.equalTo(lblTitle)
            m.height.equalTo(16)
        }
     
        contentView.addSubview(lblType)
        lblType.snp.makeConstraints { (m) in
            m.top.equalTo(lblAuthor.snp.bottom).offset(5)
            m.left.equalTo(lblTitle)
            m.height.equalTo(16)
        }
        contentView.addSubview(lblUpdateTime)
        lblUpdateTime.snp.makeConstraints { (m) in
            m.top.equalTo(lblType.snp.bottom).offset(5)
            m.left.equalTo(lblTitle)
            m.height.equalTo(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//        return self.rootLayout.sizeThatFits(targetSize)
//    }
    

}
