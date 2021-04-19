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
        
        let keyboard = NineKeyboard(frame: CGRect(x: 10, y: 100, width: ScreenWidth - 20, height: 300))
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
    var backKeyPosition = CGRect(x: 10, y: 220, width: itemWidth, height: 60)
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
        for rect in positions.enumerated(){
            let las = createTextLayer(text: (rect.offset.toString,"abc"), position: rect.element)
            for la in las {
                layer.addSublayer(la)
            }
        }
        addBackKey()
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
        layerText1.frame = CGRect(origin: CGPoint(x: position.center.x - 5, y:  position.center.y - 15), size: CGSize(width: 10, height: 20))
        layerText1.foregroundColor = UIColor.gray.cgColor
        layerText1.contentsScale = UIScreen.main.scale
        layerText1.string = text.0
        layerText1.fontSize = 13
        layers.append(layerText1)
        let layerText2 =  CATextLayer()
        let size = text.1.boundingRect(with: CGSize(width: 100, height: 100), font: UIFont.systemFont(ofSize: 18))
        
        layerText2.frame = CGRect(origin: CGPoint(x: position.center.x - size.width / 2, y:  position.center.y), size: CGSize(width: 30, height: 20))
        layerText2.foregroundColor = UIColor.gray.cgColor
        layerText2.contentsScale = UIScreen.main.scale
        layerText2.string = text.1
        layerText2.fontSize = 13
        layers.append(layerText2)
        return layers
    }
    
    func addBackKey() {
        let layer1 = CAShapeLayer()
        let rectPath = UIBezierPath(roundedRect: backKeyPosition, cornerRadius: 5)
        layer1.path = rectPath.cgPath
        layer1.fillColor = UIColor.white.cgColor
        layer.addSublayer(layer1)
        let layer2 = CAShapeLayer()
        layer2.lineWidth = 1.5
        layer2.strokeColor = UIColor.gray.cgColor
        layer2.fillColor = UIColor.clear.cgColor
        layer2.lineJoin = .round
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 50, y: backKeyPosition.center.y))
        bezierPath.addLine(to: CGPoint(x: 54, y: backKeyPosition.center.y - 9))
        bezierPath.addLine(to: CGPoint(x: 85, y: backKeyPosition.center.y - 9))
        bezierPath.addLine(to: CGPoint(x: 85, y: backKeyPosition.center.y + 9))
        bezierPath.addLine(to: CGPoint(x: 54, y: backKeyPosition.center.y + 9))
        bezierPath.close()
        
        bezierPath.move(to: CGPoint(x: backKeyPosition.center.x - 4, y: backKeyPosition.center.y - 4))
        bezierPath.addLine(to: CGPoint(x: backKeyPosition.center.x + 4, y: backKeyPosition.center.y + 4))
        bezierPath.move(to: CGPoint(x: backKeyPosition.center.x - 4, y: backKeyPosition.center.y + 4))
        bezierPath.addLine(to: CGPoint(x: backKeyPosition.center.x + 4, y: backKeyPosition.center.y - 4))

        layer2.path = bezierPath.cgPath
        layer.addSublayer(layer2)
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
       pressedLayer?.removeFromSuperlayer()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressedLayer?.removeFromSuperlayer()
    }
}
