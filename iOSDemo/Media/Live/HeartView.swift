//
//  HeartView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/5/10.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class HeartView: UIView {

    var strokeColor = UIColor.red
    var fillColor = UIColor.pink
    var heartSize:CGFloat = 10
    var animationDuration:TimeInterval = 3.0
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startPraise() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform.identity
            self.alpha = 0.9
        }, completion: nil)
        let i = CGFloat(arc4random_uniform(2))
        let rotationDirection : CGFloat = 1 - (2 * i) //这个地方总是莫名奇妙挂,我写成CGFloat(arc4random_uniform(2))就不会挂，真是TMD神奇了
        let rotationFraction : CGFloat = CGFloat(arc4random_uniform(10))
        UIView.animate(withDuration: animationDuration, animations: {
            self.transform = CGAffineTransform(rotationAngle: rotationDirection * CGFloat.pi / (16 + rotationFraction * 0.2))
        }, completion: nil)

        let heartTravelPath = UIBezierPath()
        heartTravelPath.move(to: center)

        let endPoint = CGPoint(x: centerX +  rotationDirection * CGFloat(arc4random_uniform( UInt32(2 * heartSize))),y: size.height / 6 + CGFloat(arc4random_uniform(UInt32(size.height / 4))))
        let j = CGFloat(arc4random_uniform(2))
        let travelDirection : CGFloat = 1 - (2 * j)
        let xDelta = (heartSize / 2.0 + CGFloat(arc4random_uniform( UInt32(2 * heartSize)))) * travelDirection
        let yDelta = max(endPoint.y, CGFloat(max(arc4random_uniform( UInt32(8 * heartSize)), UInt32(heartSize))))

        let controlPoint1 = CGPoint(x: centerX + xDelta, y: size.height - yDelta)
        let controlPoint2 = CGPoint(x: centerX - 2 * xDelta, y: yDelta)

        heartTravelPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)


        let keyFrameAnimation = CAKeyframeAnimation.init(keyPath: "position")
        keyFrameAnimation.path = heartTravelPath.cgPath
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)]
        keyFrameAnimation.duration = CFTimeInterval(CGFloat(animationDuration) + endPoint.y / size.height)
        layer.add(keyFrameAnimation, forKey: "positionOnPath")
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha =  0
        }) { (finish) in
            self.removeSubviews()
        }
    }
    
    override func draw(_ rect: CGRect) {
        strokeColor.setStroke()
        fillColor.setFill()
        
        let drawingPadding:CGFloat = 4.0
        let curveRadius = floor((rect.width - 2 * drawingPadding) / 4.0)
        let heartPath = UIBezierPath()
        let tipLocation = CGPoint(x: floor(rect.width / 2.0), y: rect.height - drawingPadding)
        heartPath.move(to: tipLocation)
        
        let topLeftCurveStart = CGPoint(x: drawingPadding, y: floor(rect.height / 2.4))
        heartPath.addQuadCurve(to: topLeftCurveStart, controlPoint: CGPoint(x: topLeftCurveStart.x, y: topLeftCurveStart.y + curveRadius))
        heartPath.addArc(withCenter: CGPoint(x: topLeftCurveStart.x + curveRadius, y: topLeftCurveStart.y), radius: curveRadius, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
        let topRightCurveStart = CGPoint(x: topLeftCurveStart.x + 2 * curveRadius, y: topLeftCurveStart.y)
        heartPath.addArc(withCenter: CGPoint(x: topRightCurveStart.x + 2 * curveRadius, y: topRightCurveStart.y), radius: curveRadius, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
        let topRightCurveEnd = CGPoint(x: topLeftCurveStart.x + 4 * curveRadius, y: topRightCurveStart.y)
        heartPath.addQuadCurve(to: tipLocation, controlPoint: CGPoint(x: topRightCurveEnd.x, y: topRightCurveEnd.y + curveRadius))
        
        heartPath.fill()
        heartPath.lineWidth = 1
        heartPath.lineCapStyle = .round
        heartPath.lineJoinStyle = .round
        heartPath.stroke()
    }
}
