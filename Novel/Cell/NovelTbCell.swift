//
//  NovelTbCell.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
class NovelTbCell: UITableViewCell {
    fileprivate(set) var rootLayout:TGBaseLayout!
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
        self.rootLayout = TGLinearLayout(.horz)
        self.rootLayout.tg_topPadding = 5
        self.rootLayout.tg_bottomPadding = 5
        self.rootLayout.tg_width.equal(.fill)
        self.rootLayout.tg_height.equal(.wrap)
        self.rootLayout.tg_padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.rootLayout.tg_cacheEstimatedRect = true
        self.contentView.addSubview(self.rootLayout)
        
        imgNovel.tg_width.equal(100)
        imgNovel.tg_height.equal(150)
        imgNovel.cornerRadius(radius: 5).completed()
        self.rootLayout.addSubview(imgNovel)
        
        let messageLayout = TGLinearLayout(.vert)
        messageLayout.tg_width.equal(.fill)  //等价于tg_width.equal(100%)
        messageLayout.tg_height.equal(.wrap)
        messageLayout.tg_leading.equal(5)
        messageLayout.tg_vspace = 5 //前面4行代码描述的是垂直布局占用除头像外的所有宽度，并和头像保持5个点的间距。
        messageLayout.tg_padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.rootLayout.addSubview(messageLayout)

       lblTitle.tg_width.equal(.fill)
        lblTitle.tg_height.equal(.wrap)
        messageLayout.addSubview(lblTitle)

        lblIntro.tg_width.equal(.fill)
        lblIntro.tg_height.equal(.wrap)
        lblIntro.tg_top.equal(self.lblTitle.tg_bottom, offset:5)
        messageLayout.addSubview(lblIntro)

        lblAuthor.tg_width.equal(.fill)
        lblAuthor.tg_height.equal(.wrap)
        lblAuthor.tg_top.equal(self.lblIntro.tg_bottom, offset:3)
        messageLayout.addSubview(lblAuthor)
        
        lblType.tg_width.equal(.fill)
        lblType.tg_height.equal(.wrap)
        lblType.tg_top.equal(self.lblAuthor.tg_bottom, offset:3)
        messageLayout.addSubview(lblType)
        
        lblUpdateTime.tg_width.equal(.fill)
        lblUpdateTime.tg_height.equal(.wrap)
        lblUpdateTime.tg_top.equal(self.lblType.tg_bottom, offset:3)
        messageLayout.addSubview(lblUpdateTime)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return self.rootLayout.sizeThatFits(targetSize)
    }
    

}
