//
//  ShadowPlayView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/21.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
class ShadowVideoPlayControlView: UIView {
    let btnImage = UIButton()
    var playBlock:((_ view:ShadowVideoPlayControlView,_ state:Bool)->Void)?
    var state = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        btnImage.addTarget(self, action: #selector(handleImageTapAction(sender:)), for: .touchUpInside)
        addSubview(btnImage)
        btnImage.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        btnImage.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        btnImage.showsTouchWhenHighlighted = true
        btnImage.setImage(#imageLiteral(resourceName: "pause"), for: .selected)
    }
    
    @objc func handleImageTapAction(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        state = btnImage.isSelected
        playBlock?(self,state)
    }
}
