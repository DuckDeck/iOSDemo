//
//  LayerViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class LayerViewController: BaseViewController,CALayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let bar = UIBarButtonItem(title: "3D", style: .plain, target: self, action: #selector(barTap))
        navigationItem.rightBarButtonItem = bar
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.red.cgColor
        
        let subLayer  = CALayer()
        subLayer.backgroundColor = UIColor.magenta.cgColor
        subLayer.cornerRadius = 8
        subLayer.borderWidth = 4
        subLayer.borderColor = UIColor.black.cgColor
        subLayer.shadowOffset = CGSize(width: 4, height: 5)
        subLayer.shadowRadius = 1
        subLayer.shadowColor = UIColor.black.cgColor
        subLayer.shadowOpacity = 0.8
        subLayer.frame = CGRect(x: 10, y: 75, width: 120, height: 160)
        view.layer.addSublayer(subLayer)
        let subLayer2 = CALayer()
        subLayer2.cornerRadius = 8
        subLayer2.borderWidth = 4
        subLayer2.borderColor = UIColor.black.cgColor
        subLayer2.shadowOffset = CGSize(width: 4, height: 5)
        subLayer2.shadowRadius = 1
        subLayer2.shadowColor = UIColor.black.cgColor
        subLayer2.shadowOpacity = 0.8
        subLayer2.masksToBounds = true
        subLayer2.frame = CGRect(x: 170, y: 75, width: 120, height: 160)
        view.layer.addSublayer(subLayer2)
        let imgLayer = CALayer()
        imgLayer.contents = UIImage(named: "2")!.cgImage
        imgLayer.frame = subLayer2.bounds
        subLayer2.addSublayer(imgLayer)

        let customLayer = CALayer()
       // customLayer.delegate = self
        customLayer.backgroundColor = UIColor.green.cgColor
        customLayer.frame = CGRect(x: 10, y: 250, width: 100, height: 100)
        customLayer.shadowOffset = CGSize(width: 0, height: 3)
        customLayer.shadowRadius = 5.0
        customLayer.shadowColor = UIColor.black.cgColor
        customLayer.shadowOpacity = 0.8
        customLayer.cornerRadius = 10
        customLayer.borderWidth = 3
        customLayer.borderColor = UIColor.yellow.cgColor
        customLayer.masksToBounds = true
        view.layer.addSublayer(customLayer)
        customLayer.setNeedsDisplay()
        
        
          //使用显式动画
        let anima = CABasicAnimation(keyPath: "opacity")
        anima.fromValue = 1.0
        anima.toValue = 0.0
        anima.autoreverses = true
        anima.repeatCount = 100
        anima.duration = 2.0
        subLayer2.add(anima, forKey: "anim")
        
        //使用Layer绘制文字
        //好像没有用
        let vText = delegateView(frame: CGRect(x: 200, y: 250, width: 100, height:  100))
        view.addSubview(vText)
        
        let squareLayer = CALayer()
        squareLayer.backgroundColor = UIColor.red.cgColor
        squareLayer.frame = CGRect(x: 10, y: 380, width: 20, height: 20)
        view.layer.addSublayer(squareLayer)

        let squareView = UIView()
        squareView.backgroundColor = UIColor.blue
        squareView.frame =  CGRect(x: 50, y: 380, width: 20, height: 20)
        view.addSubview(squareView)
        CATransaction.setAnimationDuration(2.0)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(drop(gesture:))))
        
        
        
        //自定义显式动画
        let animLayer = CALayer()
        animLayer.backgroundColor = UIColor.red.cgColor
        animLayer.frame = CGRect(x: 10, y: 450, width: 20, height: 20)
        animLayer.cornerRadius = 10
        view.layer.addSublayer(animLayer)
        animLayer.opacity = 0.0 //防止闪回
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        //anima.autoreverses = true
        //anima.repeatCount = 100
        animation.duration = 2.0
        animLayer.add(anima, forKey: "anim")
        
        let line = UIView(frame: CGRect(x: 0, y: 500, w: ScreenWidth, h: 44))
//        line.backgroundColor = UIColor.lightGray
//        line.layer.shadowColor = UIColor.lightGray.cgColor
//        line.layer.shadowOffset = CGSize(width: 0, height: -4)
//        line.layer.shadowOpacity = 0.5
//        line.layer.shadowRadius = 5
//        let pathWidth = line.layer.shadowRadius
//        let rect = CGRect(x: 0, y: 0 - pathWidth / 2, w: line.frame.size.width, h: pathWidth)
//        let path = UIBezierPath(rect: rect)
//        line.layer.shadowPath = path.cgPath
        
        let ly2 = CAGradientLayer()
        ly2.startPoint = CGPoint(x: 0.5, y: 0)
        ly2.endPoint = CGPoint(x: 0.5, y: 1)
        ly2.colors = [UIColor.clear.cgColor,UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3).cgColor]
        ly2.frame = CGRect(x: 0, y: 0, w: ScreenWidth, h: 44)
        line.layer.insertSublayer(ly2, at: 0)
        view.addSubview(line)
        
        let vDash = UILabel()
        vDash.text = "我有虚线边框"
        vDash.frame = CGRect(x: 100, y: ScreenHeight - 100, w: 200, h: 50)
        vDash.backgroundColor = UIColor.lightGray
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.purple.cgColor
        borderLayer.fillColor = nil
        borderLayer.lineDashPattern = [4,2]
        borderLayer.path = UIBezierPath(rect: vDash.bounds).cgPath
        borderLayer.frame = vDash.bounds
        vDash.layer.addSublayer(borderLayer)
        view.addSubview(vDash)
        
        
    }

     func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        let bgColor = UIColor(patternImage: UIImage(named: "heart")!)
        ctx.setFillColor(bgColor.cgColor)
        ctx.fillEllipse(in: CGRect(x: 20, y: 20, width: 100, height: 100))
    }


    @objc func drop(gesture:UITapGestureRecognizer){
        var layers = view.layer.sublayers
        layers![4].position = CGPoint(x: 200, y: 380)
        var views = view.subviews
        views[0].center = CGPoint(x: 100, y: 250)
    }
    
    @objc func barTap()  {
        navigationController?.pushViewController(ThreeDViewController(), animated: true)
    }
}


class delegateView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.setNeedsDisplay()
        layer.contentsScale = UIScreen.main.scale
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        UIColor.white.set()
        UIRectFill(layer.bounds)
        let font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        let color = UIColor.purple
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attribs = [NSAttributedString.Key.font:font,NSAttributedString.Key.foregroundColor:color,NSAttributedString.Key.paragraphStyle:style]
        let text = NSMutableAttributedString(string: "Pushing The Limits", attributes: attribs)
        text.draw(in: layer.bounds)
        UIGraphicsPopContext()
    }
    
}
