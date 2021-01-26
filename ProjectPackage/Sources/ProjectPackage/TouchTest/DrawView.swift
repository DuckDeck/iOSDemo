//
//  DrawView.swift
//  TouchTest
//
//  Created by 123 on 6/4/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit
import CommonLibrary
protocol drawViewDelegate{
    func btnClick(sender:UIButton)
}

class DrawView: UIView {
    var delegate:drawViewDelegate?
    var _btnPrevious:UIButton?
    var _btnNext:UIButton?
    var _btnSetting:UIButton?
    var _btnClear:UIButton?
    let Colors = [UIColor.red,UIColor.blue,UIColor.green,UIColor.white,UIColor.yellow,UIColor.purple,UIColor.brown,UIColor.cyan,UIColor.gray,UIColor.orange,UIColor.magenta]
    var colors:Array<UIColor>?
    private var arrTraces:Array<Trace>?
    private var arrDeletedTraces:Array<Trace>?
    private var arrLines:Array<Line>?
    private var arrLabelPoints:Array<UILabel>?
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true
        arrTraces = Array<Trace>()
        arrDeletedTraces = Array<Trace>()
        arrLines = Array<Line>()
        arrLabelPoints = Array<UILabel>()
        self.addSubview(btnPrevious)
        self.addSubview(btnNext)
        self.addSubview(btnSetting)
        self.addSubview(btnClear)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctg = UIGraphicsGetCurrentContext()!
        ctg.clear(rect)
        ctg.setLineWidth(1)
        ctg.setLineJoin(.round)
        ctg.setLineCap(.round)
        //画当前的线
        if arrTraces!.count > 0
        {
            ctg.beginPath()
            for i in 0..<arrTraces!.count
            {
                let tempTrace = arrTraces![i]
                if tempTrace.arrPoints.count > 0
                {
                    ctg.beginPath()
                    var point = tempTrace.arrPoints[0]
                    ctg.move(to: point)
                    let count:Int! = tempTrace.arrPoints.count
                    for j in 0 ..< count-1
                    {
                        point = tempTrace.arrPoints[j+1]
                        ctg.addLine(to: point)
                    }
                    //暂时都搞成红色
                    ctg.setStrokeColor(tempTrace.color.cgColor)
                    let width:CGFloat!  = tempTrace.thickness
                    ctg.setLineWidth(width)
                    ctg.strokePath()
                }
            }
        }
        
        if arrLines!.count > 0
        {
            for i in 0..<arrLines!.count {
                let tempLine = arrLines![i]
                
                ctg.beginPath()
                
                ctg.move(to: CGPoint(x: 0, y: tempLine.point.y))
                ctg.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: tempLine.point.y))

                ctg.setStrokeColor(tempLine.lineColor.cgColor)
                
     
                let width:CGFloat!  = tempLine.strokeThickness
                
                
                ctg.setLineWidth(width)
                ctg.strokePath()

                ctg.beginPath()
                
                ctg.move(to: CGPoint(x: tempLine.point.x, y: 0))
                
                ctg.addLine(to: CGPoint(x: tempLine.point.x, y: UIScreen.main.bounds.height))

                ctg.setStrokeColor(tempLine.lineColor.cgColor)
                
                ctg.setLineWidth(width)
                
                ctg.strokePath()

            }
        }
    }
    
    

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touchPoint in touches
        {
         
            let point = touchPoint.location(in: self)
            let line = Line()
            line.point = point
            line.lineColor = getRandomColor()
            line.strokeThickness = 1
            if Settings.needShowTrace.Value!{
               let trace = Trace()
                trace.arrPoints = Array<CGPoint>()
                trace.arrPoints.append(point)
                trace.color = line.lineColor
                trace.thickness = CGFloat(Settings.traceThickness.Value!)
                arrTraces?.append(trace)
            }
            if Settings.needShowCoordinate.Value!{
                line.labelPoint.textColor = line.lineColor
                line.labelPoint.font = UIFont.systemFont(ofSize: 10)
                line.labelPoint.numberOfLines = 0
                let x = NSString(format: "%5.1f", line.point.x*CGFloat(scale))
                let y = NSString(format: "%5.1f", line.point.y*CGFloat(scale))
                line.labelPoint.text = "Point\n x:\(x) \n y:\(y)"
            }
            arrLines?.append(line)
            if arrLines!.count > Settings.maxSupportTouches.Value!
            {
                Settings.maxSupportTouches.Value = arrLines!.count
            }
            layOutLabelPoints()
        }
        self.setNeedsDisplay()
        
    }
    

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)  {
        super.touchesMoved(touches, with: event)
        for touchPoint in touches
        {
          
            let point = touchPoint.location(in: self)
            //怎么找到上一个Point
            let previousPoint = touchPoint.previousLocation(in: self)
            for i in 0..<arrTraces!.count
            {
                let tempTraces = arrTraces![i]
               let lastPoint = tempTraces.arrPoints.last
                if lastPoint == previousPoint
                {
                    tempTraces.arrPoints.append(point)
                    break
                }
            }
            
            for j in 0..<arrLines!.count {
                let tempLine = arrLines?[j]
                 if tempLine?.point == previousPoint
                 {
                    tempLine?.point = point
                }
                if Settings.needShowCoordinate.Value!{
                    let x = NSString(format: "%5.1f", tempLine!.point.x*getScale())
                    let y = NSString(format: "%5.1f", tempLine!.point.y*getScale())
                    tempLine?.labelPoint.text = "Point\n x:\(x) \n y:\(y)"
                }
            }
            
            //arrPoints?.append(point)
            self .setNeedsDisplay()
        }
        
    }
    

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        //先移除十字线
        for touchPoint in touches
        {
            let point = touchPoint.location(in: self)
                //怎么找到上一个Point
            let previousPoint = touchPoint.previousLocation(in: self)
                var index = [Int]()
                for j in 0..<arrLines!.count {
                    let tempLine = arrLines?[j]
                    if tempLine?.point == previousPoint || tempLine?.point == point
                    {
                        if Settings.needShowCoordinate.Value!{
                            tempLine?.labelPoint.removeFromSuperview()
                        }
                        index.append(j)
                        
                    }
                }
                arrLines?.removeAtIndexs(indexs: index)
                if !Settings.needKeepTrace.Value!
                {
                    arrTraces?.removeAll(keepingCapacity: false)
                }
                self .setNeedsDisplay()
                
            
        }
        setButtonsEnable()
    }


    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        //先移除十字线
        for touchPoint in touches
        { 
          
            let point = touchPoint.location(in: self)
            //怎么找到上一个Point
            let previousPoint = touchPoint.previousLocation(in: self)
            var index = [Int]()
            for j in 0..<arrLines!.count {
                let tempLine = arrLines?[j]
                if tempLine?.point == previousPoint || tempLine?.point == point
                {
                    if Settings.needShowCoordinate.Value!{
                        tempLine?.labelPoint.removeFromSuperview()
                    }
                    index.append(j)
                }
            }
            arrLines?.removeAtIndexs(indexs: index)
            if !Settings.needKeepTrace.Value!
            {
                arrTraces?.removeAll(keepingCapacity: false)
            }
            self .setNeedsDisplay()
            
        }
        
        setButtonsEnable()

    }
    
    func clear()
    {
        arrLines?.removeAll(keepingCapacity: false)
        arrTraces?.removeAll(keepingCapacity: false)
        arrDeletedTraces?.removeAll(keepingCapacity: false)
        self.setNeedsDisplay()
    }
    
    func previous()
    {
        if arrTraces!.count <= 0{
            return
        }
        let lastLine = arrTraces?.removeLast()
        arrDeletedTraces?.append(lastLine!)
        self.setNeedsDisplay()
    }
    
    func next()
    {
        if arrDeletedTraces!.count <= 0{
         return
        }
        let lastLine = arrDeletedTraces?.removeLast()
        arrTraces?.append(lastLine!)
        self.setNeedsDisplay()
    }
    
    var canPrevious:Bool{
        get{
            return arrTraces!.count>0
        }
    }
    
    var canNext:Bool{
        get{
            return arrDeletedTraces!.count > 0
        }
    }

    var canClear:Bool {
        get{
            return canNext||canPrevious
        }
    }
    func getRandomColor() -> UIColor
    {
        var color:UIColor?
        if colors == nil || colors!.count <= 0{
            colors = Colors
        }
        color = colors?.removeLast()
        return color!
    }
    
    var btnPrevious:UIButton
        {
        get{
            if (_btnPrevious == nil)
            {
                _btnPrevious = UIButton()
                _btnPrevious?.setImage(UIImage(named: "public_btn_back_white_solid"), for: UIControl.State.normal)
                _btnPrevious!.frame = CGRect(x:UIScreen.main.bounds.size.width/5-15,y: UIScreen.main.bounds.height-100,width: 30, height:30)
                _btnPrevious?.layer.borderWidth = 2
                _btnPrevious?.layer.borderColor = UIColor.white.cgColor
                _btnPrevious?.layer.cornerRadius = 15
                _btnPrevious?.addTarget(self, action: #selector(DrawView.previous(sender:)), for: UIControl.Event.touchUpInside)
            }
            return _btnPrevious!
        }
    }
    
    var btnNext:UIButton
        {
        get{
            if (_btnNext == nil)
            {
                _btnNext = UIButton()
                _btnNext?.setImage(UIImage(named: "public_btn_next_white_solid"), for: UIControl.State.normal)
                _btnNext!.frame = CGRect(x:UIScreen.main.bounds.size.width*0.4-15,y: UIScreen.main.bounds.height-100,width: 30,height: 30)
                _btnNext?.layer.borderWidth = 2
                _btnNext?.layer.borderColor = UIColor.white.cgColor
                _btnNext?.layer.cornerRadius = 15
                _btnNext?.addTarget(self, action: #selector(DrawView.next(sender:)), for: UIControl.Event.touchUpInside)
            }
            return _btnNext!
        }
    }
    
    var btnSetting:UIButton
        {
        get{
            if (_btnSetting == nil)
            {
                _btnSetting = UIButton()
                _btnSetting?.setImage(UIImage(named: "public_btn_setting_white_solid"), for: UIControl.State.normal)
                _btnSetting!.frame = CGRect(x:UIScreen.main.bounds.size.width*0.6-15,y: UIScreen.main.bounds.height-100,width: 30, height:30)
                _btnSetting?.layer.borderWidth = 2
                _btnSetting?.layer.borderColor = UIColor.white.cgColor
                _btnSetting?.layer.cornerRadius = 15
                _btnSetting?.addTarget(self, action: #selector(DrawView.setting(sender:)), for: UIControl.Event.touchUpInside)
            }
            return _btnSetting!
        }
    }
    
    var btnClear:UIButton
        {
        get{
            if (_btnClear == nil)
            {
                _btnClear = UIButton()
                _btnClear?.setImage(UIImage(named: "public_btn_delete_white_solid"), for: UIControl.State.normal)
                _btnClear!.frame = CGRect(x:UIScreen.main.bounds.size.width*0.8-15,y: UIScreen.main.bounds.height-100, width:30,height: 30)
                _btnClear?.layer.borderWidth = 2
                _btnClear?.layer.borderColor = UIColor.white.cgColor
                _btnClear?.layer.cornerRadius = 15
                _btnClear?.addTarget(self, action: #selector(DrawView.clear(sender:)), for: UIControl.Event.touchUpInside);
            }
            return _btnClear!
        }
    }
    func setButtonsEnable()
    {
        _btnClear?.isEnabled = canClear
        _btnNext?.isEnabled = canNext
        _btnPrevious?.isEnabled = canPrevious
    }
    
    @objc func next(sender:UIButton){
        next()
        setButtonsEnable()
    }
    
    @objc func previous(sender:UIButton){
        previous()
        setButtonsEnable()
    }

    @objc func clear(sender:UIButton){
        clear()
        setButtonsEnable()
    }
    
    @objc func setting(sender:UIButton){
        delegate?.btnClick(sender: sender)
    }
    
    func layOutLabelPoints(){
        //self.subviews
        for  view  in  self.subviews
        {
            if view is UILabel
            {
                view.removeFromSuperview()
            }
        }
        for i in 0..<arrLines!.count {
            let line = arrLines?[i]
            let frame = CGRect(x: 0, y: i*40, width: 45, height: 40)
            line?.labelPoint.frame = frame
            //line?.labelPoint.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
            self.addSubview(line!.labelPoint)
        }
    }
    
    func getScale() -> CGFloat{
        if UIScreen.main.bounds.width  > 400
        {
            return 2.6
        }
        return 2
    }

}


