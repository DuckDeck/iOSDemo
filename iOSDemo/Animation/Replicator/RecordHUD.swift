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
    private let progress = ProgressView(frame: CGRect(x: 0, y: 0, width: 170, height: 78))
    private var volume: VolumeView!
    
    //MARK: Methods
    public func startCounting() {
        progress.countingAnimate()
      
    }
    
    public func stopCounting() {
        progress.stopAnimate()
    }
    
    //MARK: - Init
    
    convenience init(type: HUDType) {
        self.init(frame: .zero)
        self.frame.size.width = 170
        self.frame.size.height = 78
        center = CGPoint(x: ScreenWidth/2, y: ScreenHeight/2 - 50)
        backgroundColor = UIColor.clear
        addSubview(progress)
        
        volume = VolumeView(frame: CGRect(x: 56, y: 0, width: ScreenWidth, height: ScreenHeight), type: type)
        addSubview(volume)
        
        setUpShadow()
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Setup
extension RecordHUD {
    
    
    
    private func setUpShadow() {
        
        let progessViewBounds = progress.frame
        let shadowWidth = progessViewBounds.size.width * 0.85
        let shadowHeight = progessViewBounds.size.height * 0.75
        
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: progessViewBounds.origin.x + (progessViewBounds.width - shadowWidth) * 0.5,
                                                          y: progessViewBounds.origin.y + 20,
                                                          width: shadowWidth,
                                                          height: shadowHeight),
                                      cornerRadius: progress.layer.cornerRadius)
        
        layer.shadowColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1).cgColor
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}
