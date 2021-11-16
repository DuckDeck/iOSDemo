//
//  GrandMenu.swift
//  GrandMenuDemo
//
//  Created by Tyrant on 1/15/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import UIKit

open class GrandMenu: UIView,GraneMenuItemDelegate {
    open var arrItemsTitle:[String]?{
        didSet{
            setupItems()
        }
    }
    open var sliderBarLeftRightOffset = 15{
        didSet{
            setupItems()
        }
    }
    open var itemLeftRightOffset:Float = 10{
        didSet{
            setupItems()
        }
    }
    open  var sliderBarHeight = 2
    open  var sliderColor = UIColor.red{
        didSet{
            vSlider?.backgroundColor = sliderColor
        }
    }
    var allItemWidth:Float  = 0
    open var  averageManu:Bool = true //当Menu过多时,设置无效
    
    open  var defaultSelectedIndex:Int = 0{
        didSet{
            if defaultSelectedIndex < arrItemsTitle!.count{
                setupItems()
            }
        }
    }
    
    open var itemColor:UIColor = UIColor.black{
        didSet{
            if  let items = arrItems{
                for item in items{
                    item.color = itemColor
                }
            }
            
        }
    }
    
    open  var itemSeletedColor:UIColor = UIColor.red{
        didSet{
            if  let items = arrItems{
                for item in items{
                    item.selectedColor = itemSeletedColor
                }
            }
        }
    }
    
    open var itemFont:Float?{
        didSet{
            if itemFont == nil{
                return
            }
            if  let items = arrItems{
                for item in items{
                    item.Font = UIFont.systemFont(ofSize: CGFloat(itemFont!))
                }
            }
        }
    }
    
    open var itemUIFont:UIFont?{
        didSet{
            if itemUIFont == nil{
                return
            }
            if  let items = arrItems{
                for item in items{
                    item.Font = itemUIFont!
                }
            }
        }
    }
    
    open  var itemSelectedFont:Float?{
        didSet{
            if itemSelectedFont == nil{
                return
            }
            if  let items = arrItems{
                for item in items{
                    item.selectedFont = UIFont.systemFont(ofSize: CGFloat(itemSelectedFont!))
                }
            }
        }
    }
    
    open  var itemSelectedUIFont:UIFont?{
        didSet{
            
            if itemSelectedUIFont == nil{
                return
            }
            if  let items = arrItems{
                for item in items{
                    item.selectedFont = itemSelectedUIFont!
                }
            }
        }
    }
    
    open var selectMenu:((_ item:GrandMenuItem, _ index:Int)->())?
    
    fileprivate var selectedItemIndex:Int = 0
    fileprivate var scrollView:UIScrollView?
    fileprivate var arrItems:[GrandMenuItem]?
    fileprivate var vSlider:UIView?
    fileprivate var vBottomLine:UIView?
    fileprivate var selectedItem:GrandMenuItem?{
        willSet{
            selectedItem?.selected = false  //这个警告可以无视
        }
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        arrItems = [GrandMenuItem]()
        scrollView = UIScrollView(frame: bounds)
        scrollView!.backgroundColor = UIColor.clear
        scrollView!.showsHorizontalScrollIndicator = false
        scrollView!.showsVerticalScrollIndicator = false
        scrollView!.bounces = false
        addSubview(scrollView!)
        vSlider = UIView()
        vSlider?.backgroundColor = sliderColor
        scrollView!.addSubview(vSlider!)
    }
    public  convenience init(frame: CGRect,titles:[String]){
        self.init(frame:frame)
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
        arrItemsTitle = titles
        setupItems()
    }
    open func addBottomLine(_ bgColor:UIColor,size:CGSize){
        vBottomLine = UIView(frame: CGRect(x: (frame.size.width - size.width) / 2, y: frame.size.height, width: size.width, height: size.height))
        vBottomLine?.backgroundColor = bgColor
        addSubview(vBottomLine!)
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: vBottomLine!.frame.maxY)
    }
    
    
    
    
    func setupItems(){
        weak var weakSelf = self
        for view in scrollView!.subviews{
            if view is GrandMenuItem{
                view.removeFromSuperview()
            }
        }
        arrItems?.removeAll(keepingCapacity: true)
        var x:Float = 0
        var maxItemWidth:Float = 0.0
        allItemWidth = 0
        for  title in arrItemsTitle! {
            let item = GrandMenuItem()
            item.selectedColor = itemSeletedColor
            item.color = itemColor
            if let f = itemFont{
                item.Font = UIFont.systemFont(ofSize: CGFloat(f))
            }
            if let f = itemUIFont{
                item.Font = f
            }
            if let sf = itemSelectedFont{
                item.selectedFont = UIFont.systemFont(ofSize: CGFloat(sf))
            }
           
            if let sf = itemSelectedUIFont{
                item.selectedFont = sf
            }
            
            item.delegate = weakSelf
            var itemWidth = GrandMenuItem.getTitleWidth(title, fontSize: Float(item.Font.pointSize), leftrightOffset: itemLeftRightOffset)
            
            if itemWidth > maxItemWidth{
                maxItemWidth = itemWidth
            }
            if averageManu{
                if maxItemWidth * Float(arrItemsTitle!.count) > Float(frame.size.width){
                    itemWidth = maxItemWidth
                }
                else{
                    itemWidth = Float(frame.size.width / CGFloat(arrItemsTitle!.count))
                }
            }
            allItemWidth = allItemWidth + itemWidth
            item.frame = CGRect(x: CGFloat(x), y: CGFloat(0), width: CGFloat(itemWidth), height: scrollView!.frame.height)
            item.title = title
            arrItems!.append(item)
            scrollView?.addSubview(item)
            x = Float(item.frame.maxX)
        }
        scrollView?.contentSize = CGSize(width: CGFloat(x), height: scrollView!.frame.height)
        let defaultItem = arrItems![defaultSelectedIndex]
        selectedItemIndex = defaultSelectedIndex
        defaultItem.selected = true
        selectedItem = defaultItem
        vSlider?.frame = CGRect(x: defaultItem.frame.origin.x + CGFloat(sliderBarLeftRightOffset), y: frame.size.height - CGFloat(sliderBarHeight), width: defaultItem.frame.size.width - CGFloat(sliderBarLeftRightOffset * 2), height: CGFloat(sliderBarHeight))
    }
    
    
    func scrollToVisibleItem(_ item:GrandMenuItem){
        weak var weakSelf = self
        let selectedItemIndex = arrItems!.find({(s:GrandMenuItem) ->Bool in return s.title! == weakSelf?.selectedItem!.title!}).1
        let visibleItemIndex = arrItems!.find({(s:GrandMenuItem) ->Bool in return s.title! == item.title!}).1
        if selectedItemIndex == visibleItemIndex{
            return
        }
        var offset = scrollView!.contentOffset
        if item.frame.midX > offset.x && item.frame.maxX < (offset.x + scrollView!.frame.width){
            return
        }
        if selectedItemIndex < visibleItemIndex{
            if selectedItem!.frame.maxX < offset.x{
                offset.x = item.frame.minX
            }
            else{
                offset.x = item.frame.maxX - scrollView!.frame.width
            }
        }
        else{
            if selectedItem!.frame.minX > offset.x + scrollView!.frame.width{
                offset.x = item.frame.maxX - scrollView!.frame.width
            }
            else{
                offset.x = item.frame.minX
            }
        }
        scrollView?.contentOffset = offset
    }
    
    func addAnimationWithSelectedItem(_ item:GrandMenuItem,withAnimation:Bool = true)
    {
        // let dx = item.frame.midX - selectedItem!.frame.midX
        let dx = item.frame.midX - vSlider!.frame.size.width / 2
        //        let positionAnimation = CABasicAnimation()
        //        positionAnimation.keyPath = "position.x"
        //        positionAnimation.fromValue = vSlider?.layer.position.x
        //        positionAnimation.toValue = vSlider!.layer.position.x + dx
        
        //        let boundsAnimation = CABasicAnimation()
        //        boundsAnimation.keyPath = "bounds.size.width"
        //        boundsAnimation.fromValue = CGRectGetWidth(vSlider!.layer.bounds)
        //        boundsAnimation.toValue = CGRectGetWidth(item.frame)
        //这个是不必要的动画
        
        //        let animationGroup = CAAnimationGroup()
        //        animationGroup.animations = [positionAnimation]
        //        animationGroup.duration = 0.2
        //        vSlider?.layer.addAnimation(animationGroup, forKey: "basic")
        //
        //        vSlider?.layer.position = CGPoint(x: vSlider!.layer.position.x + dx, y: vSlider!.layer.position.y)
        //        var rect = vSlider!.layer.bounds
        //        rect.size.width = CGRectGetWidth(item.frame) - CGFloat(sliderBarLeftRightOffset * 2)
        //        vSlider?.layer.bounds = rect
        //这个动画有个小Bug,目前不知道怎么修正,它会先把滑块移动到目的地再消失,再执行动画,所以只好用下面的方法了,这种情况有30%的可能性发生
        //不用这种动画试试
        if withAnimation{
            weak var weakSelf = self
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                weakSelf?.vSlider?.frame = CGRect(x:  dx, y:weakSelf!.vSlider!.frame.origin.y, width: weakSelf!.vSlider!.frame.size.width, height: weakSelf!.vSlider!.frame.size.height)
            })
        }
        else{
            vSlider?.frame = CGRect(x:  dx, y: vSlider!.frame.origin.y, width: vSlider!.frame.size.width, height: vSlider!.frame.size.height)
        }
    }
    
    open func adjustScrollOffset(){
        let x = selectedItem!.frame.origin.x
        let right = x + selectedItem!.frame.size.width
        if right <= 0.5 * scrollView!.frame.width {
            scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        else if  right > scrollView!.contentSize.width - 0.5 * scrollView!.frame.width{
            if CGFloat(allItemWidth) < scrollView!.frame.width{
                return
            }
            scrollView?.setContentOffset(CGPoint(x: scrollView!.contentSize.width - scrollView!.frame.width, y: 0), animated: true)
        }
        else{
            let of = x - 0.5 * scrollView!.frame.width + selectedItem!.frame.size.width * 0.5
            if of > 0{
                scrollView?.setContentOffset(CGPoint(x: of, y: 0), animated: true)
            }
        }
    }
    
    func GraneMenuItemSelected(_ item: GrandMenuItem) {
        
        if item == selectedItem!{
            addAnimationWithSelectedItem(item)
            return
        }
        addAnimationWithSelectedItem(item)
        selectedItem = item
        //调整到合适的位置
        adjustScrollOffset()
        
        if let call = selectMenu{
            let item = arrItems!.find({(s:GrandMenuItem) ->Bool in return s.selected == item.selected })
            call(item.0!, item.1)
        }
    }
    
    open  func selectSlideBarItemAtIndex(_ index:Int,withAnimation:Bool = true){
        let item = arrItems![index]
        if item == selectedItem!{
            addAnimationWithSelectedItem(item)
            return
        }
        item.selected = true
        scrollToVisibleItem(item)
        addAnimationWithSelectedItem(item, withAnimation: withAnimation)
        selectedItem = item
        
        //it will check
        if let call = selectMenu{
            let item = arrItems!.find({(s:GrandMenuItem) ->Bool in return s.selected == item.selected })
            call(item.0!, item.1)
        }
    }
    
    open func setSlidertBar(x:Float)  {
        if x < 0{
            //            if vSlider!.frame.origin.x + vSlider!.frame.size.width < self.frame.size.width{
            vSlider!.frame = CGRect(x: vSlider!.frame.origin.x - CGFloat(x), y: vSlider!.frame.origin.y, width: vSlider!.frame.size.width, height: vSlider!.frame.size.height)
            //            }
        }
        else{
            //            if vSlider!.frame.origin.x > 0{
            vSlider!.frame = CGRect(x: vSlider!.frame.origin.x - CGFloat(x), y: vSlider!.frame.origin.y, width: vSlider!.frame.size.width, height: vSlider!.frame.size.height)
            //            }
        }
    }
    
    open func adjustSlider()  {
        let center =  vSlider!.frame.origin.x + vSlider!.frame.size.width / 2
        if center < -10 {
            selectSlideBarItemAtIndex(arrItems!.count - 1, withAnimation: false)
            return
        }
        if center > arrItems!.last!.frame.origin.x + arrItems!.last!.frame.size.width + 10{
            selectSlideBarItemAtIndex(0,withAnimation: false)
            return
        }
        var index = 0
        for i in 0..<arrItems!.count {
            if center > arrItems![i].frame.origin.x && center <= arrItems![i].frame.origin.x + arrItems![i].frame.size.width{
                index = i
                break
            }
        }
        selectSlideBarItemAtIndex(index)
    }
    
}

extension Array{
    func find(_ method:(Element)->Bool)->(Element?,Int){
        var index = 0
        for item in self{
            if method(item){
                return (item,index)
            }
            index += 1
        }
        return (nil,-1)
    }
    
    mutating func remove(_ method:(Element)->Bool)->(Element?,Bool){
        let result = find(method)
        if result.1 >= 0{
            return (self.remove(at: result.1),true)
        }
        return (nil,false)
    }
    
    func compareFirstObject(_ arrTarget:Array, method:(Element,Element)->Bool)->Bool{
        if count == 0 || arrTarget.count == 0
        {
            return false
        }
        let firstItem = first!
        let targetFirstItem = arrTarget.first!
        if method(firstItem,targetFirstItem)
        {
            return true
        }
        return false
    }
    
    func compareLastObject(_ arrTarget:Array, method:(Element,Element)->Bool)->Bool{
        if count == 0 || arrTarget.count == 0
        {
            return false
        }
        let firstItem = last!
        let targetFirstItem = arrTarget.last!
        if method(firstItem,targetFirstItem)
        {
            return true
        }
        return false
    }
    
    mutating func exchangeObjectAdIndex(_ IndexA:Int,atIndexB:Int)
    {
        if IndexA >= count || IndexA < 0{
            return
        }
        if atIndexB >= count || atIndexB < 0{
            return
        }
        let objA = self[IndexA]
        let objB = self[atIndexB]
        replaceObject(objA, atIndex: atIndexB)
        replaceObject(objB, atIndex: IndexA)
    }
    
    mutating func replaceObject(_ obj:Element,atIndex:Int){
        if atIndex >= count || atIndex < 0{
            return
        }
        self.remove(at: atIndex)
        insert(obj, at: atIndex)
    }
    
    mutating func merge(_ newArray:Array){
        for obj in newArray
        {
            append(obj)
        }
    }
}
