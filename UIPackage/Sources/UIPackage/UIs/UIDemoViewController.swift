//
//  File.swift
//  
//
//  Created by chen liang on 2021/3/17.
//

import UIKit
import CommonLibrary
import SnapKit
import SwiftUI
import GrandTime
class UIDemoViewController: UIViewController {
    var tick:Double = 1
    var timer:GrandTimer!
  
    var areas = [CGRect(x: 10, y: 10, width: (ScreenWidth - 40) / 3, height: 30)]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let circle = CircleProgressView()
        view.addSubview(circle)
        circle.snp.makeConstraints { (m) in
            m.left.equalTo(50)
            m.top.equalTo(100)
            m.width.height.equalTo(100)
        }
        
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromSeconds(1), block: {
            circle.progress = self.tick / 100.0
            self.tick += 1.0
        }, repeats: true, dispatchQueue: DispatchQueue.global())
        timer.fire()
        
        let keyboard = NineKeyboard(frame: CGRect(x: 10, y: 400, width: ScreenWidth - 20, height: 300))
        view.addSubview(keyboard)
    }
    
}


struct UIDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIDemoViewController, context: Context) {
        
    }
    typealias UIViewControllerType = UIDemoViewController
    
    func makeUIViewController(context: Context) -> UIDemoViewController {
        return UIDemoViewController()
    }
}

var itemWidth = (ScreenWidth - 60) / 3

class NineKeyboard: UIView {
    var pressedLayer:CAShapeLayer?
    var positions = [CGRect(x: 10, y: 10, width: itemWidth, height: 60),
                     CGRect(x: itemWidth + 20, y: 10, width: itemWidth, height: 60),
                     CGRect(x: 2 * itemWidth + 30, y: 10, width: itemWidth, height: 60),
                     CGRect(x: 10, y: 80, width: itemWidth, height: 60),
                     CGRect(x: itemWidth + 20, y: 80, width: itemWidth, height: 60),
                     CGRect(x: 2 * itemWidth + 30, y: 80, width: itemWidth, height: 60),
                     CGRect(x: 10, y: 150, width: itemWidth, height: 60),
                     CGRect(x: itemWidth + 20, y: 150, width: itemWidth, height: 60),
                     CGRect(x: 2 * itemWidth + 30, y: 150, width: itemWidth, height: 60)]
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        for rect in positions{
            let las = createTextLayer(text: ("1","分割"), position: rect)
            for la in las {
                layer.addSublayer(la)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createTextLayer(text:(String,String),position:CGRect) -> [CALayer] {
        var layers = [CALayer]()
        let layerFrame = CAShapeLayer()
        layerFrame.fillColor = UIColor.white.cgColor
        let path1 = UIBezierPath(roundedRect: position, cornerRadius: 5)
        layerFrame.path = path1.cgPath
        layers.append(layerFrame)
        let layerText1 =  CATextLayer()
        layerText1.frame = CGRect(origin: CGPoint(x: position.center.x - 5, y:  position.center.y - 20), size: CGSize(width: 10, height: 20))
        layerText1.foregroundColor = UIColor.gray.cgColor
        layerText1.contentsScale = UIScreen.main.scale
        layerText1.string = text.0
        layerText1.fontSize = 13
        layers.append(layerText1)
        let layerText2 =  CATextLayer()
        layerText2.frame = CGRect(origin: CGPoint(x: position.center.x - 15, y:  position.center.y - 10), size: CGSize(width: 30, height: 20))
        layerText2.foregroundColor = UIColor.gray.cgColor
        layerText2.contentsScale = UIScreen.main.scale
        layerText2.string = text.1
        layerText2.fontSize = 13
        layers.append(layerText2)

        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 16 * 1, y: 32 * 1))
        bezierPath.addLine(to: CGPoint(x: 38 * 1, y: 32 * 1))
        bezierPath.addCurve(to: CGPoint(x: 44 * 1, y: 26 * 1), controlPoint1: CGPoint(x: 38 * 1, y: 32 * 1), controlPoint2: CGPoint(x: 44 * 1, y: 32 * 1))
        bezierPath.addCurve(to: CGPoint(x: 44 * 1, y: 6 * 1), controlPoint1: CGPoint(x: 44 * 1, y: 22 * 1), controlPoint2: CGPoint(x: 44 * 1, y: 6 * 1))
        bezierPath.addCurve(to: CGPoint(x: 36 * 1, y: 0 * 1), controlPoint1: CGPoint(x: 44 * 1, y: 6 * 1), controlPoint2: CGPoint(x: 44 * 1, y: 0 * 1))
        bezierPath.addCurve(to: CGPoint(x: 16 * 1, y: 0 * 1), controlPoint1: CGPoint(x: 32 * 1, y: 0 * 1), controlPoint2: CGPoint(x: 16 * 1, y: 0 * 1))
        bezierPath.addLine(to: CGPoint(x: 0 * 1, y: 18 * 1))
        bezierPath.addLine(to: CGPoint(x: 16 * 1, y: 32 * 1))
        bezierPath.close()
        color.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 20 * 1, y: 10 * 1))
        bezier2Path.addLine(to: CGPoint(x: 34 * 1, y: 22 * 1))
        bezier2Path.addLine(to: CGPoint(x: 20 * 1, y: 10 * 1))
        bezier2Path.close()
        UIColor.gray.setFill()
        bezier2Path.fill()
        color2.setStroke()
        bezier2Path.lineWidth = 2.5 * lineWidthScalingFactor
        bezier2Path.stroke()
        
        
        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 20 * 1, y: 22 * 1))
        bezier3Path.addLine(to: CGPoint(x: 34 * 1, y: 10 * 1))
        bezier3Path.addLine(to: CGPoint(x: 20 * 1, y: 22 * 1))
        bezier3Path.close()
        UIColor.red.setFill()
        bezier3Path.fill()
        color2.setStroke()
        bezier3Path.lineWidth = 2.5 * lineWidthScalingFactor
        bezier3Path.stroke()
        
        
        
        return layers
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self){
            for item in positions {
                if item.contains(point){
                    if pressedLayer == nil{
                        pressedLayer = CAShapeLayer()
                        
                        pressedLayer!.fillColor = UIColor.gray.withAlphaComponent(0.4).cgColor
                    }
                    
                    let path1 = UIBezierPath(roundedRect: item, cornerRadius: 5)
                    pressedLayer!.path = path1.cgPath
                    layer.addSublayer(pressedLayer!)
                    break
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self){
            print(point)
           
            pressedLayer?.removeFromSuperlayer()
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressedLayer?.removeFromSuperlayer()
    }
}
