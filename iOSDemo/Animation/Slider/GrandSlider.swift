//
//  GrandSlider.swift
//  GrandSliderDemo
//
//  Created by Tyrant on 1/13/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class GrandSlider: UIView,UIScrollViewDelegate {
   open var views:[UIView]?{
        didSet{
            if scrollView == nil{
                scrollView = UIScrollView(frame:bounds)
                autoresizesSubviews = true
                if let window = UIApplication.shared.keyWindow
                {
                    if var viewController = window.rootViewController{
                        while viewController.presentedViewController != nil{
                            viewController = viewController.presentedViewController!
                        }
                        while viewController.isKind(of: UINavigationController.self) && (viewController as! UINavigationController).topViewController != nil{
                            viewController = (viewController as! UINavigationController).topViewController!
                        }
                        viewController.automaticallyAdjustsScrollViewInsets = false
                    }
                }
                scrollView?.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
                scrollView?.contentSize = CGSize(width: CGFloat(3) * scrollView!.frame.width, height: scrollView!.frame.height)
                scrollView?.delegate = self
                scrollView?.isPagingEnabled = true
                scrollView?.showsHorizontalScrollIndicator = false
                self.addSubview(scrollView!)
            }
            if displayView == nil{
                displayView = [UIView]()
            }
            for view in scrollView!.subviews{
                if view is DotView{}
                else{
                    view.removeFromSuperview()
                }
            }
            scrollView!.addSubview(views![0])
            timer?.pause()
            currentPageIndex = 0
            if views!.count > 1{
                scrollView?.isScrollEnabled = true
                scrollView?.contentOffset = CGPoint(x: scrollView!.frame.width, y: 0)
                timer!.resumeAfterTimeInterval(TimeInterval(animationDuration))
            }
            else{
                scrollView?.isScrollEnabled = false
                scrollView?.contentOffset = CGPoint(x: scrollView!.frame.width * 2, y: 0)
            }
            setDisplayView()
            resetDotView()
            
        }
    }
    var dView:DotView?
    fileprivate var hightLightedDotView:DotView?  //这个是不能设定的了
 open   var dotGap:Float = 6{
        didSet{
            pageControl?.dotGap = dotGap
            resetDotView()
        }
    }
 open   var dotWidth:Float = 12{
        didSet{
            pageControl?.dotWidth = dotWidth
            resetDotView()
        }
    }
    open var normalDotColor:UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7){
        didSet{
            pageControl?.normalDotColor = normalDotColor
            resetDotView()
        }
    }
    
    open var highlightedDotColor:UIColor = UIColor.white{
        didSet{
            pageControl?.highlightedDotColor = highlightedDotColor
            resetDotView()
        }
    }
    fileprivate var displayView:[UIView]?
    fileprivate var pageControl:DotViewControl?
    public  static var scale:Float{
        get{
            return Float(UIScreen.main.bounds.width) / 320.0
        }
    }
    var scrollView:UIScrollView?
    var currentPageIndex = 0 {
        didSet{
            pageControl?.setCurrentPage(currentPageIndex)
        }
    }
  open  var pageControlYScale:Float = 0.7{
        didSet{
            resetDotView()
        }
    }
   open var animationDuration:Int = 2
   open var tap:((_ view:UIView,_ index:Int)->())?
    fileprivate var scrollViewStartContentOffsetX:Float?
    fileprivate weak var timer:Timer?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
  public  convenience init(frame: CGRect,animationDuration:Int) {
        self.init(frame:frame)
        self.animationDuration = animationDuration
        timer = WeakTimer.scheduledTimerWithTimeInterval(TimeInterval(animationDuration), target: self, selector: #selector(GrandSlider.tick(_:)), userInfo: nil, repeats: true) //Bug NSTimer is strong refrence
        timer?.pause()
    }
  public  convenience init(frame: CGRect,animationDuration:Int,dView:DotView?,hDotView:DotView?,dotGap:Float) {
        self.init(frame:frame)
        self.animationDuration = animationDuration
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(animationDuration), target: self, selector: #selector(GrandSlider.tick(_:)), userInfo: nil, repeats: true)
        timer?.pause()
        self.dView = dView
        self.dotGap = dotGap
        self.hightLightedDotView = hDotView
    }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetDotView(){
        if views == nil{
            return
        }
        if views!.count <= 1{
            pageControl?.removeFromSuperview()
            return
        }
        var dotViewWith = dotWidth
        if dView != nil{
            dotViewWith = Float(dView!.frame.size.width)
        }
        let dotViewControllerWidth = CGFloat( views!.count) * CGFloat(dotViewWith * GrandSlider.scale) + CGFloat(views!.count - 1) * CGFloat(dotGap * GrandSlider.scale)
        let f = CGRect(x: frame.midX - 0.5 * CGFloat(dotViewControllerWidth), y: frame.height * CGFloat(pageControlYScale), width: dotViewControllerWidth, height: CGFloat(dotGap * GrandSlider.scale))
        if pageControl == nil{
            if self.dView == nil{
                pageControl = DotViewControl(frame: f, dotGap: self.dotGap, dotWidth: self.dotWidth, normalDotColor: self.normalDotColor, highlightedDotColor: self.highlightedDotColor)
            }
            else{
                pageControl = DotViewControl(frame: f, dView: self.dView!, hDotView: self.hightLightedDotView!, dotGap: self.dotGap)
            }
            pageControl?.dotNum = views!.count
        }
        else{
            pageControl?.removeFromSuperview()
            pageControl!.dotNum = views!.count
            pageControl?.frame = f
        }
        addSubview(pageControl!)
    }
    
    
    func setDisplayView(){
        for view in scrollView!.subviews{
            if view is DotView{}
            else{
                view.removeFromSuperview()
            }
        }
        let previousIndex = getAdjustNextPage(currentPageIndex - 1)
        let nexIndex = getAdjustNextPage(currentPageIndex + 1)
        displayView!.removeAll(keepingCapacity: true)
        displayView?.append(views![previousIndex])
        displayView?.append(views![currentPageIndex])
        displayView?.append(views![nexIndex])
        var index:Int = 0
        for view in displayView!{
            view.isUserInteractionEnabled = true
            var f = view.frame
            f.origin = CGPoint(x: frame.width * CGFloat(index), y: CGFloat(0))
            index = index + 1
            view.frame = f
            let tap = UITapGestureRecognizer(target: self, action: #selector(GrandSlider.tapGesture(_:)))
            view.addGestureRecognizer(tap)
            
            scrollView!.addSubview(view)//如果只是两张图片,那么就相当于把前面的图片改变了位置,让这些View来实现Copy协议也不现实啊,有什么办法吗?
            
        }
        if views!.count > 1{
            scrollView!.setContentOffset(CGPoint(x: scrollView!.frame.size.width, y: 0), animated: false)
        }
    }
    
    func getAdjustNextPage(_ index:Int) -> Int{
        if index == -1
        {
            return views!.count - 1
        }
        else if index == views!.count {
            return 0
        }
        else {
            return index
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewStartContentOffsetX = Float(scrollView.contentOffset.x)
        timer?.pause()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timer?.resumeAfterTimeInterval(TimeInterval(self.animationDuration))
    }
  open   func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if self.views?.count == 2{
            if scrollViewStartContentOffsetX < Float(contentOffsetX){
                let tempView = self.displayView!.last
                tempView?.frame = CGRect(x: 2 * self.scrollView!.frame.size.width, y: 0, width: tempView!.frame.size.width, height: tempView!.frame.size.height)
            }
            else if scrollViewStartContentOffsetX > Float(contentOffsetX){
                let tempView = self.displayView!.last
                tempView?.frame = CGRect(x: 0, y: 0, width: tempView!.frame.size.width, height: tempView!.frame.size.height)
            }
        }
        if contentOffsetX >= self.scrollView!.frame.width * 2{
            currentPageIndex = getAdjustNextPage(currentPageIndex + 1)
            setDisplayView()
        }
        if contentOffsetX <= 0{
            currentPageIndex = getAdjustNextPage(currentPageIndex - 1)
            setDisplayView()
        }
    }
    
    @objc func tick(_ timer:Timer){
        let newOffset = CGPoint(x: scrollView!.contentOffset.x + scrollView!.frame.width, y: scrollView!.contentOffset.y)
        scrollView?.setContentOffset(newOffset, animated: true)
    }
    
    @objc func tapGesture(_ tapGesture:UITapGestureRecognizer){
        if let tapAction = tap{
            tapAction(tapGesture.view!, currentPageIndex)
        }
    }
    deinit{
        timer?.invalidate()
        timer = nil
    }
}



class DotViewControl: UIView {
    
    var highLightdView:DotView?
    var dView:DotView?
    fileprivate var dotGap:Float?
    fileprivate var dotWidth:Float?
    fileprivate var dotHeight:Float?
    fileprivate var normalDotColor:UIColor?
    fileprivate var highlightedDotColor:UIColor?
    var dotNum:Int?{
        didSet{
            if dotNum > 0{
                
                for view in subviews{
                    view.removeFromSuperview()
                }
                if self.dotWidth == nil{
                    self.dotWidth = Float(self.dView!.frame.size.width)
                    self.dotHeight = Float(self.dView!.frame.size.height)
                    self.normalDotColor = self.dView?.backgroundColor
                    self.highlightedDotColor = self.highLightdView?.backgroundColor
                }
                else
                {
                    self.dotHeight = self.dotWidth
                }
                if highLightdView == nil{
                    highLightdView = DotView(frame: CGRect(x: 0, y: 0, width: CGFloat(dotWidth! * GrandSlider.scale), height: CGFloat(dotHeight! * GrandSlider.scale)),color:self.highlightedDotColor!)
                }
                highLightdView?.frame = CGRect(x: 0, y: 0, width: CGFloat(dotWidth! * GrandSlider.scale), height: CGFloat(dotHeight! * GrandSlider.scale))
                // highLightdView?.dotColor = highlightedDotColor
                var normalView:DotView?
                var f:CGRect = CGRect.zero
                for i in 0..<dotNum!{
                    f = CGRect(x: CGFloat((dotWidth! + dotGap!) * GrandSlider.scale) * CGFloat(i), y: 0, width: CGFloat((dotWidth!) * GrandSlider.scale), height: CGFloat(dotHeight! * GrandSlider.scale))
                    if self.dView == nil{
                        normalView = DotView(frame: f,color:self.normalDotColor!)
                    }
                    else{
                        normalView = dView!.copy() as? DotView
                        //normalView?.dotColor = normalView?.backgroundColor
                    }
                    normalView?.frame =  f
                    addSubview(normalView!)
                }
                addSubview(highLightdView!)
            }
            
        }
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    convenience init(frame: CGRect,dView:DotView?,hDotView:DotView?,dotGap:Float) {
        self.init(frame:frame)
        self.dView = dView
        self.dotGap = dotGap
        self.highLightdView = hDotView
    }
    
    convenience init(frame: CGRect,dotGap:Float,dotWidth:Float,normalDotColor:UIColor,highlightedDotColor:UIColor) {
        self.init(frame:frame)
        self.dotGap = dotGap
        self.dotWidth = dotWidth
        self.normalDotColor = normalDotColor
        self.highlightedDotColor = highlightedDotColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCurrentPage(_ pageIndex:Int){
        if highLightdView != nil{
            let newRect = CGRect(x: CGFloat(self.dotGap! + self.dotWidth!) * CGFloat(GrandSlider.scale) * CGFloat(pageIndex), y: 0, width: CGFloat(dotWidth! * GrandSlider.scale), height: CGFloat(dotHeight! * GrandSlider.scale))
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                self.highLightdView?.frame = newRect
                }, completion: nil)
        }
    }
    
}



open class DotView: UIView {
    
    override open func copy() -> Any {
        var dotColor = UIColor.white
        if self.dotColor != nil{
            dotColor = self.dotColor!
        }
        let newDot = DotView(frame: self.bounds, color: dotColor)
        newDot.layer.cornerRadius = self.layer.cornerRadius
        newDot.layer.borderColor = self.layer.borderColor
        newDot.layer.borderWidth = self.layer.borderWidth
        newDot.backgroundColor = self.backgroundColor
        newDot.tag = self.tag
        return newDot
    }
    
    var dotColor:UIColor?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    convenience init(frame: CGRect,color:UIColor){
        self.init(frame:frame)
        self.dotColor = color
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(self.dotColor!.cgColor)
        ctx?.fillEllipse(in: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
    }
}



extension Timer{
    func pause(){
        if !self.isValid{
            return
        }
        fireDate = Date.distantFuture
    }
    func resume(){
        if !self.isValid{
            return
        }
        fireDate = Date()
    }
    func resumeAfterTimeInterval(_ time:TimeInterval){
        if !self.isValid{
            return
        }
        fireDate = Date(timeIntervalSinceNow: time)
    }
    
}

class WeakTimer:NSObject {
    weak var target:AnyObject?
    weak var timer:Timer? //此招不管用
    var sel:Selector?
    @objc func fire(_ timer:Timer){
        if self.target != nil{
           _ =  self.target?.perform(self.sel!, with: self.timer!.userInfo)
        }
        else{
            self.timer?.invalidate()
        }
    }
    static func scheduledTimerWithTimeInterval(_ interval:TimeInterval,target:AnyObject,selector:Selector,userInfo:AnyObject?,repeats:Bool)->Timer{
        let weakTimer = WeakTimer()
        weakTimer.target = target
        weakTimer.sel = selector
        weakTimer.timer = Timer.scheduledTimer(timeInterval: interval, target: weakTimer, selector: #selector(WeakTimer.fire(_:)), userInfo: userInfo, repeats: repeats)
        return weakTimer.timer!
    }
}
