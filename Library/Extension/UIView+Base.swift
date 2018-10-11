//
//  UIView+Base.swift
//  wanjia
//
//  Created by Stan Hu on 26/12/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//

import UIKit
extension UIView{
    
    public var x: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: self.y, width: self.w, height: self.h)
        }
    }
    
    /// EZSwiftExtensions
    public var y: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: self.x, y: value, width: self.w, height: self.h)
        }
    }
    
    /// EZSwiftExtensions
    public var w: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: value, height: self.h)
        }
    }
    
    /// EZSwiftExtensions
    public var h: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: value)
        }
    }
    
    /// EZSwiftExtensions
    public var left: CGFloat {
        get {
            return self.x
        } set(value) {
            self.x = value
        }
    }
    
    /// EZSwiftExtensions
    public var right: CGFloat {
        get {
            return self.x + self.w
        } set(value) {
            self.x = value - self.w
        }
    }
    
    /// EZSwiftExtensions
    public var top: CGFloat {
        get {
            return self.y
        } set(value) {
            self.y = value
        }
    }
    
    /// EZSwiftExtensions
    public var bottom: CGFloat {
        get {
            return self.y + self.h
        } set(value) {
            self.y = value - self.h
        }
    }
    
    /// EZSwiftExtensions
    public var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }
    
    /// EZSwiftExtensions
    public var centerX: CGFloat {
        get {
            return self.center.x
        } set(value) {
            self.center.x = value
        }
    }
    
    /// EZSwiftExtensions
    public var centerY: CGFloat {
        get {
            return self.center.y
        } set(value) {
            self.center.y = value
        }
    }
    
    /// EZSwiftExtensions
    public var size: CGSize {
        get {
            return self.frame.size
        } set(value) {
            self.frame = CGRect(origin: self.frame.origin, size: value)
        }
    }
    
    
    public func removeSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    public func addTapGesture(tapNumber: Int = 1, target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    
    public func addLongPressGesture(action: ((UILongPressGestureRecognizer) -> Void)?) {
        let longPress = BlockLongPress(action: action)
        addGestureRecognizer(longPress)
        isUserInteractionEnabled = true
    }
    
    public func addTapGesture(tapNumber: Int = 1, action: ((UITapGestureRecognizer) -> Void)?) {
        let tap = BlockTap(tapCount: tapNumber, fingerCount: 1, action: action)
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    func addTo(view:UIView) ->Self {
        view.addSubview(self)
        return self
    }
    func borderWidth(width:CGFloat) -> Self {
        self.layer.borderWidth = width
        return self
    }
    func borderColor(color:UIColor) -> Self {
        self.layer.borderColor = color.cgColor
        return self
    }
    func cornerRadius(radius:CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
    
    func bgColor(color:UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    func clearText() {
        for v in self.subviews{
            if let t = v as? UITextField{
                 t.text = ""
            }
            else if let t = v as? UITextView{
                t.text = ""
            }
        }
    }
    
    func setFrame(frame:CGRect) -> Self {
        self.frame = frame
        return self
    }
    
    func completed()  {
        
    }
    
    func currentVC() -> UIViewController? {
        var vc:UIViewController! = nil
        var window = UIApplication.shared.keyWindow!
        if window.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for win in windows{
                if win.windowLevel == UIWindow.Level.normal{
                    window = win
                    break
                }
            }
        }
        let frontView = window.subviews.first!
        let responder = frontView.next
        if responder != nil && responder! is UIViewController{
            vc = responder! as? UIViewController
        }
        else{
            vc = window.rootViewController
        }
        return vc
    }
}



extension UILabel{
    func text(text:String) -> Self {
        self.text = text
        return self
    }
    
    func attrText(text:NSAttributedString) -> Self {
        self.attributedText = text
        return self
    }
    
    func setFont(font:CGFloat) -> Self {
        self.font = UIFont.systemFont(ofSize: font)
        return self
    }
    
    func setUIFont(font:UIFont) -> Self {
        self.font = font
        return self
    }
    
    
    func color(color:UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    func txtAlignment(ali:NSTextAlignment) -> Self {
        self.textAlignment = ali
        return self
    }
  
    func lineNum(num:Int) -> Self {
        self.numberOfLines = num
        return self
    }
    
    func TwoSideAligment() {
        guard let txt = self.text else {
            return
        }
        let textSize = (txt as NSString).boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.truncatesLastVisibleLine,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedString.Key.font:self.font], context: nil)
        let margin = (self.frame.size.width - textSize.size.width) / CGFloat(txt.count - 1)
        let attrStr = NSMutableAttributedString(string: txt)
        attrStr.addAttribute(kCTKernAttributeName as NSAttributedString.Key, value: margin, range: NSMakeRange(0, txt.count - 1))
//        attrStr.addAttributes([kCTKernAttributeName:margin], range: NSMakeRange(0, txt.count - 1))
        self.attributedText = attrStr
    }
    
    
    func longPressCopyContentToPastboard(){
        self.addLongPressGesture {[weak self] (ges) in
            self?.becomeFirstResponder()
            self?.backgroundColor = UIColor(gray: 0.3, alpha: 0.3)
            let item = UIMenuItem(title: "复制", action: #selector(self!.copyContent))
            UIMenuController.shared.setTargetRect(self!.bounds, in: self!)
            UIMenuController.shared.menuItems = [item]
            UIMenuController.shared.arrowDirection = .up
            UIMenuController.shared.setMenuVisible(true, animated: true)
            NotificationCenter.default.addObserver(self!, selector: #selector(self!.hide), name: UIMenuController.didHideMenuNotification, object: nil)
        }
    }
    
    open override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func hide()  {
        self.backgroundColor = UIColor.clear
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func copyContent()  {
        var txt = self.text ?? ""
        if !txt.isEmpty{
            let pastboard = UIPasteboard.general
            if txt.contains(","){
                txt = txt.replacingOccurrences(of: ",", with: "")
            }
            pastboard.string = txt
            Toast.showToast(msg: "\(pastboard.string!) 已复制成功")
        }
    }

    
}

extension UITextField{
    func addOffsetView(value:Float){
        let vOffset = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(value), height: self.frame.size.height))
        self.leftViewMode = .always
        self.leftView = vOffset
    }
    
    func addOffsetLabel(width:Float,txt:NSMutableAttributedString) {
        let vOffset = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat(width), height: self.frame.size.height))
        vOffset.attributedText = txt
        self.leftViewMode = .always
        self.leftView = vOffset
    }
    
    func text(text:String) -> Self {
        self.text = text
        return self
    }
    
    func attrText(text:NSAttributedString) -> Self {
        self.attributedText = text
        return self
    }
    
    func setFont(font:CGFloat) -> Self {
        self.font = UIFont.systemFont(ofSize: font)
        return self
    }
    
    func setUIFont(font:UIFont) -> Self {
        self.font = font
        return self
    }
    
    
    func color(color:UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    func txtAlignment(ali:NSTextAlignment) -> Self {
        self.textAlignment = ali
        return self
    }
    
    func plaHolder(txt:String) -> Self {
        self.placeholder = txt
        return self
    }
    
    func attrPlaHolder(txt:NSAttributedString) -> Self {
        self.attributedText = txt
        return self
    }
    
   }

extension UIButton{

    public convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
    }
    
    func title(title:String) -> Self {
        self.setTitle(title, for: .normal)
        return self
    }
    
    
    func setTarget(_ target: Any?, action: Selector) -> Self {
        self.addTarget(target, action: action, for: .touchUpInside)
        return self
    }
    
    func color(color:UIColor) -> Self {
        self.setTitleColor(color, for: .normal)
        return self
    }
    
    func setFont(font:CGFloat) -> Self {
        self.titleLabel?.font = UIFont.systemFont(ofSize: font)
        return self
    }
    
    func setUIFont(font:UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }
    
    
    
    func img(img:UIImage) -> Self {
        self.setImage(img, for: .normal)
        return self
    }
    
}

open class BlockLongPress: UILongPressGestureRecognizer {
    private var longPressAction: ((UILongPressGestureRecognizer) -> Void)?
    
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    public convenience init (action: ((UILongPressGestureRecognizer) -> Void)?) {
        self.init()
        longPressAction = action
        addTarget(self, action: #selector(BlockLongPress.didLongPressed(_:)))
    }
    
    @objc open func didLongPressed(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == UIGestureRecognizer.State.began {
            longPressAction?(longPress)
        }
    }
}


open class BlockTap: UITapGestureRecognizer {
    private var tapAction: ((UITapGestureRecognizer) -> Void)?
    
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    public convenience init (
        tapCount: Int = 1,
        fingerCount: Int = 1,
        action: ((UITapGestureRecognizer) -> Void)?) {
        self.init()
        self.numberOfTapsRequired = tapCount
        
        #if os(iOS)
        
        self.numberOfTouchesRequired = fingerCount
        
        #endif
        
        self.tapAction = action
        self.addTarget(self, action: #selector(BlockTap.didTap(_:)))
    }
    
    @objc open func didTap (_ tap: UITapGestureRecognizer) {
        tapAction? (tap)
    }
}
