//
//  ShadowAudioPlayerView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/6/9.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class ShadowAudioPlayerView: UIView {

    let btnPlay = UIButton()
    let lblPlayTime = UILabel()
    let lblTotalTime = UILabel()
    let url:String!
    let slider = UISlider()
    let sliderCache = UISlider()
    var player:ShadowAudioPlayer!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
