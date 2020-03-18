//
//  GrandCue.swift
//  GrandCueDemo
//
//  Created by HuStan on 3/14/16.
//  Copyright © 2016 StanHu. All rights reserved.
//

import UIKit
import KRProgressHUD
class GrandCue: NSObject {
    fileprivate static let sharedInstance = GrandCue()
    class var sharedToast:GrandCue {
        return sharedInstance
    }
    var lbl:ToastLable?
    var window:UIWindow?
    static func toast(_ msg:String){
        GrandCue.sharedToast.showToast(msg)
    }
    
    static func toast(_ msg:String,verticalScale:Float){
        GrandCue.sharedToast.showToast(msg,verticalScale:verticalScale)
    }
    
    fileprivate func showToast(_ msg:String){
        self.showToast(msg,verticalScale:0.85)
    }

    static func showLoading() {
        KRProgressHUD.showMessage("加载中")
    }
    static func showLoading(msg:String) {
        KRProgressHUD.showMessage(msg)
    }
    static func dismissLoading() {
        KRProgressHUD.dismiss()
    }
    fileprivate func showToast(_ msg:String,verticalScale:Float = 0.8){
        if lbl == nil{
            lbl = ToastLable(text: msg)
        }
        else{
            lbl?.text = msg
            lbl?.sizeToFit()
            lbl?.layer.removeAnimation(forKey: "animation")
        }
    
        window = UIApplication.shared.keyWindow
        
        if !(window!.subviews.contains(lbl!)){
            window?.addSubview(lbl!)
            lbl?.center = window!.center
            lbl?.frame.origin.y = UIScreen.main.bounds.height * CGFloat(verticalScale)
        }
        lbl?.addAnimationGroup()
    }
    
}





class ToastLable:UILabel {
    enum ToastShowType{
        case top,center,bottom
    }
    var forwardAnimationDuration:CFTimeInterval = 0.3
    var backwardAnimationDuration:CFTimeInterval = 0.2
    var waitAnimationDuration:CFTimeInterval = 1.5
    var textInsets:UIEdgeInsets?
    var maxWidth:Float?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        maxWidth = Float(UIScreen.main.bounds.width) - 20.0
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.numberOfLines = 0
        self.textAlignment = NSTextAlignment.left
        self.textColor = UIColor.white
        self.font = UIFont.systemFont(ofSize: 14)
    }
    convenience init(text:String) {
        self.init(frame:CGRect.zero)
        self.text = text
        self.sizeToFit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addAnimationGroup(){
        let forwardAnimation = CABasicAnimation(keyPath: "transform.scale")
        forwardAnimation.duration = self.forwardAnimationDuration
        forwardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.7, 0.6, 0.85)
        forwardAnimation.fromValue = 0
        forwardAnimation.toValue = 1
        
        let backWardAnimation = CABasicAnimation(keyPath: "transform.scale")
        backWardAnimation.duration = self.backwardAnimationDuration
        backWardAnimation.beginTime = forwardAnimation.duration + waitAnimationDuration
        backWardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.15, 0.5, -0.7)
        backWardAnimation.fromValue = 1
        backWardAnimation.toValue = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [forwardAnimation,backWardAnimation]
        animationGroup.duration = forwardAnimation.duration + backWardAnimation.duration + waitAnimationDuration
        animationGroup.isRemovedOnCompletion = false
//        animationGroup.delegate = self
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(animationGroup, forKey: "animation")
    }
    override func sizeToFit() {
        super.sizeToFit()
        var fm = self.frame
        let width = self.bounds.width + self.textInsets!.left + self.textInsets!.right
        fm.size.width = width > CGFloat(self.maxWidth!) ? CGFloat(self.maxWidth!) : width
        fm.size.height = self.bounds.height + self.textInsets!.top + self.textInsets!.bottom
        fm.origin.x = UIScreen.main.bounds.width / 2 - fm.size.width / 2
        self.frame = fm
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag{
            self.removeFromSuperview()
        }
    }
    override func drawText(in rect: CGRect) {
        
        super.drawText(in: rect.inset(by: self.textInsets!))
    }
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = bounds
        if let txt = self.text{
            rect.size =  (txt as NSString).boundingRect(with: CGSize(width: CGFloat(self.maxWidth!) - self.textInsets!.left - self.textInsets!.right, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:self.font], context: nil).size
        }
        return rect
    }
}



