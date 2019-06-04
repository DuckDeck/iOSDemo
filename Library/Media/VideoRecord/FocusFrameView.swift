//
//  FocusFrameView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/6/4.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FocusFrameView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        layer.borderWidth = 3
        layer.borderColor = UIColor.blue.cgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startToFocus(point:CGPoint,view:UIView) {
        
        
        
    }
    
    
}
