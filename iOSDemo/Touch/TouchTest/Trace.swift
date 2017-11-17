//
//  Trace.swift
//  TouchTest
//
//  Created by Tyrant on 6/5/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit
class Trace {
    private var  _arrPoints:Array<CGPoint>?
    private var _color:UIColor = UIColor.white
    private var _thickness:CGFloat = 1
    
    var arrPoints:Array<CGPoint>{
        get{
            if _arrPoints == nil
            {
                _arrPoints = Array<CGPoint>()
            }
            return _arrPoints!
        }
        set{
            _arrPoints = newValue
        }
    }
    
    var color:UIColor{
        get{
            return _color
        }
        set{
            _color = newValue
        }
    }
    
    var thickness:CGFloat{
        get{
            return _thickness
        }
        set{
            _thickness = newValue
        }
    }
    
    
    
    
}
