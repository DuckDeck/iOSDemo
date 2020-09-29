//
//  GrandTextView.swift
//  iOSDemo
//
//  Created by shadowedge on 2020/9/28.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit
class GrandTextView: UITextView {
    private var heightConstraint: NSLayoutConstraint?
    var maxLength:Int = 0
    @IBInspectable open var trimWhiteSpaceWhenEndEditing: Bool = true
    @IBInspectable open var attributedPlaceholder: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    // Initialize
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: UITextView.textDidEndEditingNotification, object: self)
    }
    
    
    private func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height,from: https://github.com/legranddamien/MBAutoGrowingTextView
        for constraint in constraints {
            if (constraint.firstAttribute == .height) {
                if (constraint.relation == .equal) {
                    heightConstraint = constraint;
                }
            }
        }
    }
    
    private func scrollToCorrectPosition() {
        if self.isFirstResponder {
            self.scrollRangeToVisible(NSMakeRange(-1, 0)) // Scroll to bottom
        } else {
            self.scrollRangeToVisible(NSMakeRange(0, 0)) // Scroll to top
        }
    }
    
    @objc func textDidEndEditing(notification: Notification){
        if let sender = notification.object as? GrowingTextView, sender == self {
            if trimWhiteSpaceWhenEndEditing {
                text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                setNeedsDisplay()
            }
            scrollToCorrectPosition()
        }
    }
    //需要处理place holder
    @objc func textDidChange(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
//            if maxLength > 0 && text.count > maxLength {
//                let endIndex = text.index(text.startIndex, offsetBy: maxLength)
//                text = String(text[..<endIndex])
//                undoManager?.removeAllActions()
//            }
            
            guard let content = sender.text else{
                return
            }
            
            guard let lang = textInputMode?.primaryLanguage else{
                return
            }
            
            if lang == "zh-Hans" {
                let range = sender.markedTextRange
                
                if range == nil {
                    if content.count >= maxLength {
                        sender.text = content.substring(to: maxLength - 1)
                        //set the number lable to zero
                    }
                    else{
                        // set the number lable to the right num
                    }
                }
                
            }
            else{
                if content.count > maxLength {
                    sender.text = content.substring(to: maxLength - 1)
                    //set the number lable to zero
                }
                else{
                    // set the number lable to the right num
                }
            }
            
            setNeedsDisplay()
        }
    }
}
