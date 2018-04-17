//
//  UIView+Base.swift
//  wanjia
//
//  Created by Stan Hu on 26/12/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//

import UIKit
extension UIView{
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
        let textSize = (txt as NSString).boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.truncatesLastVisibleLine,NSStringDrawingOptions.usesFontLeading], attributes: [NSAttributedStringKey.font:self.font], context: nil)
        let margin = (self.frame.size.width - textSize.size.width) / CGFloat(txt.count - 1)
        let attrStr = NSMutableAttributedString(string: txt)
        attrStr.addAttribute(kCTKernAttributeName as NSAttributedStringKey, value: margin, range: NSMakeRange(0, txt.count - 1))
//        attrStr.addAttributes([kCTKernAttributeName:margin], range: NSMakeRange(0, txt.count - 1))
        self.attributedText = attrStr
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


