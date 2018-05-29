//
//  RecordHUD.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/25.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

/// HUD类型
///
/// - bar: 条状
/// - stroke: 线状
enum HUDType: Int {
    case bar = 0
    case line
}


class RecordHUD: UIView {
    
    
    //MARK: - Private Properties
    private var progress:ProgressView!
    private var volume: VolumeView!
    
    //MARK: Methods
    public func startCounting() {
        progress.countingAnimate()
      
    }
    
    public func stopCounting() {
        progress.stopAnimate()
    }
    
    //MARK: - Init
    
    convenience init(frame: CGRect,type: HUDType) {
        self.init(frame: frame)
        backgroundColor = UIColor.clear
        progress =  ProgressView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
//        addSubview(progress)
        
        volume = VolumeView(frame: CGRect(x: 5, y: 0, width: frame.size.width, height: frame.size.height), type: type)
        volume.barWidth = 2
        volume.barGap = 8
        addSubview(volume)
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

