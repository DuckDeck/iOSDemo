//
//  Line.swift
//  TouchTest
//
//  Created by Tyrant on 6/5/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit
class Line {
    private var _lineColor:UIColor = UIColor.white
    var lineColor:UIColor {
        get  {    return _lineColor   }
        set {    _lineColor = newValue }
    }

    private var _point:CGPoint?
    var point:CGPoint {
        get{return _point!}
        set{_point = newValue }
    }
    
    private var _strokeThickness:CGFloat = 1
    var strokeThickness:CGFloat {
        get{return _strokeThickness}
        set{_strokeThickness = newValue }
    }
    
    private var _labelPoint:UILabel?
    var labelPoint:UILabel   {
        get{
            if _labelPoint == nil{
                _labelPoint = UILabel()
            }
            return _labelPoint!
        }
    }
}
