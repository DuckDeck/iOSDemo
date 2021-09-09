//
//  GradientLayerViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class GradientLayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        let lbl = GradientLabel(frame: CGRect(x: 0, y: 100, width: 300, height: 44))
        lbl.text = ">---滑动来解锁"
        view.addSubview(lbl)
        
        
        let img = UIImageView(frame: CGRect(x: 80, y: 250, width: ScreenWidth - 160, height: 240))
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "10")
        view.addSubview(img)
        let viewGradient = UIView(frame: img.frame)
        view.addSubview(viewGradient)
        let gradientColor = CAGradientLayer()
        gradientColor.frame = img.bounds
        let color1 = UIColor.white.withAlphaComponent(0.1)
        let color2 = UIColor.white
        gradientColor.colors = [color1.cgColor,color2.cgColor]
        //设置渲染的起始结束位置（纵向渐变）
        gradientColor.startPoint = CGPoint(x: 0, y: 0)
        gradientColor.endPoint = CGPoint(x: 0, y: 1)
        gradientColor.cornerRadius = 21
        //定义每种颜色所在的位置
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        gradientColor.locations = gradientLocations
        viewGradient.layer.addSublayer(gradientColor)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


class GradientLabel: UIView {
    lazy var textAttributes:[NSAttributedString.Key:AnyObject] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            
            NSAttributedString.Key.font:UIFont(name: "HelveticaNeue-Thin", size: 28.0)!,
            NSAttributedString.Key.paragraphStyle:style
        ]
    }()
    
    lazy var gradientLayer:CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors = [UIColor.black.cgColor,UIColor.white.cgColor,UIColor.black.cgColor]
        gradientLayer.colors = colors
        let locations = [0.25,0.5,0.75]
        gradientLayer.locations = locations as [NSNumber]?
        
        //添加一个动画
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0,0.1,0.25]
        gradientAnimation.toValue = [0.75,0.95,1.0]
        gradientAnimation.duration = 3.0
        gradientAnimation.repeatCount = Float.infinity
        gradientLayer.add(gradientAnimation, forKey: nil)
        
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = CGRect(x: -bounds.size.width, y: bounds.origin.y, width: 3*bounds.size.width, height: bounds.size.height)
        
        layer.addSublayer(gradientLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBInspectable var text: String! {
        didSet {
            
            setNeedsDisplay()
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            text.draw(in: bounds, withAttributes: textAttributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.frame = bounds.offsetBy(dx: bounds.size.width, dy: 0)
            maskLayer.contents = image?.cgImage
            
            gradientLayer.mask = maskLayer
        }
    }
}
