//
//  CrossLine.swift
//  TouchTest
//
//  Created by Tyrant on 6/4/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit
class CrossLine {
    private var _lineColor:UIColor = UIColor.white
    var lineColor:UIColor {
        get  {    return _lineColor   }
        set {    _lineColor = newValue
            _vHorizontal?.backgroundColor = _lineColor
            _vVertical?.backgroundColor = _lineColor
        }
    }
    
    private var _strokeThickness:Float = 1
    var strokeThickness:Float
        {
        get{return _strokeThickness}
        set{_strokeThickness = newValue
        var x:CGFloat! = _vVertical?.frame.origin.x
        let newX  = x - CGFloat(_strokeThickness*0.5)
        var y:CGFloat! = _vVertical?.frame.origin.y
        let height:CGFloat! = _vVertical?.frame.size.height
            _vVertical?.frame = CGRect(x:newX, y:y, width: CGFloat(_strokeThickness),height: height)
        x = _vHorizontal?.frame.origin.x
        y = _vHorizontal?.frame.origin.y
        let newY = y - CGFloat(_strokeThickness*0.5)
        let width:CGFloat! = _vHorizontal?.frame.size.width
            _vHorizontal?.frame = CGRect(x:x,y: newY,width: width,height: CGFloat(_strokeThickness))
        }
    }
    private var _vHorizontal:UIView?
    var vHorizontal:UIView  {
        get  {  return _vHorizontal!  }
        set     {     _vHorizontal = newValue  }
    }
    
    private var _vVertical:UIView?
    var vVertical:UIView {
        get {    return _vVertical!   }
        set    {  _vVertical = newValue  }
    }
    
    private var _tag:UInt = 0
    var tag:UInt
        {
        get{return _tag}
        set{_tag = newValue}
    }
    
    private var _point:CGPoint?
    var point:CGPoint
        {
        get{return _point!}
        set{_point = newValue
            var x:CGFloat! = _point!.x
            let newX  = x - CGFloat(_strokeThickness*0.5)
            var y:CGFloat! = _vVertical?.frame.origin.y
            let height:CGFloat! = _vVertical?.frame.size.height
            _vVertical?.frame = CGRect(x:newX,y: y,width: CGFloat(_strokeThickness),height: height)
            x = _vHorizontal?.frame.origin.x
            y = _point?.y
            let newY = y - CGFloat(_strokeThickness*0.5)
            let width:CGFloat! = _vHorizontal?.frame.size.width
            _vHorizontal?.frame = CGRect(x:x,y: newY,width: width,height: CGFloat(_strokeThickness))}
    }
    
    init(color:UIColor, point:CGPoint)
    {
        _point = point
        _lineColor = color
        _vHorizontal = UIView(frame: CGRect(x:0,y: point.y - CGFloat(_strokeThickness*0.5),width: UIScreen.main.bounds.width,height: CGFloat(_strokeThickness)))
        _vVertical = UIView(frame: CGRect(x:point.x - CGFloat(_strokeThickness*0.5),y: 0,width: CGFloat(_strokeThickness),height: UIScreen.main.bounds.height))
        _vHorizontal?.backgroundColor = color
        _vVertical?.backgroundColor = color
    }
}
