//
//  GrandMenuItem.swift
//  GrandMenuDemo
//
//  Created by Tyrant on 1/15/16.
//  Copyright © 2016 Qfq. All rights reserved.
//

import UIKit
protocol GraneMenuItemDelegate:NSObjectProtocol{
    func GraneMenuItemSelected(_ item:GrandMenuItem)
}
open class GrandMenuItem: UIView {
    var selected:Bool = false{
        didSet{
            setNeedsDisplay()
        }
    }
    
    var title:String?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    
    var Font:UIFont = UIFont.systemFont(ofSize: 15){
        didSet{
            setNeedsDisplay()
        }
    }
    
    var selectedFont:UIFont = UIFont.systemFont(ofSize: 15){
        didSet{
            setNeedsDisplay()
        }
    }
    var color:UIColor = UIColor.black{
        didSet{
            setNeedsDisplay()
        }
    }
    var selectedColor:UIColor = UIColor.red{
        didSet{
            setNeedsDisplay()
        }
    }
    
    weak var delegate:GraneMenuItemDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = UIColor.clearColor()
    }
    
    convenience init(){
        self.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.backgroundColor = UIColor.clear
    }
    
    override open func draw(_ rect: CGRect) {
        let titleX = (frame.width - titleSize().width) * 0.5
        let titleY = (frame.height - titleSize().height) * 0.5
        let titleRect = CGRect(x: titleX, y: titleY, width: titleSize().width, height: titleSize().height)
        let attributes = [NSAttributedString.Key.font:titleFont(),NSAttributedString.Key.foregroundColor:titleColor()]
        if let currentTitle = title{
            (currentTitle as NSString).draw(in: titleRect, withAttributes: attributes)
        }
    }
    
    func titleSize()->CGSize{
        let attribures = [NSAttributedString.Key.font:titleFont()]
        var size = (title! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attribures, context: nil).size
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        return size
    }
    func titleFont()->UIFont{
        if selected{
            return selectedFont
        }
        else{
            return Font
        }
    }
    func titleColor()->UIColor{
        if selected{
            return selectedColor
        }
        else
        {
            return color
        }
    }
    
    static func getTitleWidth(_ title:String,fontSize: Float,leftrightOffset:Float = 10)->Float{
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: CGFloat(fontSize))]
        var size = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        size.width = ceil(size.width) + CGFloat(leftrightOffset * 2)
        return Float(size.width)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selected = true
        delegate?.GraneMenuItemSelected(self)
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if object == nil
        {
            return false
        }
        if let newItem = object! as? GrandMenuItem{
            if newItem.title! == title!{
                return true
            }
        }
        return false
    }
}
