//
//  3DViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 28/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class ThreeDViewController: UIViewController {
    var contentLayer:CATransformLayer?
    var topLayer:CALayer?
    var bottomLayer:CALayer?
    var leftLayer:CALayer?
    var rightLayer:CALayer?
    var frontLayer:CALayer?
    var backLayer:CALayer?
    let kSize:CGFloat = Scale*180.0
    let kPanScale:CGFloat = 1.0/180.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let theContentLayer = CATransformLayer()
        theContentLayer.frame = view.layer.bounds
        let size = theContentLayer.bounds.size
        theContentLayer.transform = CATransform3DMakeTranslation(size.width / 2, size.height / 2, 0)
        view.layer.addSublayer(theContentLayer)
        contentLayer = theContentLayer
        topLayer = createLayer(x: 0, y: -kSize / 2, z: 0, color: UIColor.red, transform: ThreeDViewController.makeSideRotation(x: 1, y: 0, z: 0))
        bottomLayer = createLayer(x: 0, y: kSize / 2, z: 0, color: UIColor.green, transform: ThreeDViewController.makeSideRotation(x: 1, y: 0, z: 0))
        rightLayer = createLayer(x: kSize / 2, y: 0, z: 0, color: UIColor.blue, transform: ThreeDViewController.makeSideRotation(x: 0, y: 1, z: 0))
        leftLayer = createLayer(x: -kSize / 2, y: 0, z: 0, color: UIColor.cyan, transform: ThreeDViewController.makeSideRotation(x: 0, y: 1, z: 0))
        backLayer = createLayer(x: 0, y: 0, z: -kSize / 2, color: UIColor.yellow, transform: CATransform3DIdentity)
        frontLayer = createLayer(x: 0, y: 0, z: kSize / 2, color: UIColor.magenta, transform: CATransform3DIdentity)
        
        view.layer.sublayerTransform = ThreeDViewController.makePerspectiveTransform()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:))))
    }

  
    func createLayer(color:UIColor,transform:CATransform3D)->CALayer{
        let layer = CALayer()
        layer.backgroundColor = color.cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: kSize, height: kSize)
        layer.position = view.center
        layer.transform = transform
        view.layer.addSublayer(layer)
        return layer
    }
    
    func createLayer(x:CGFloat,y:CGFloat,z:CGFloat,color:UIColor,transform:CATransform3D)->CALayer{
        let layer = CALayer()
        layer.backgroundColor = color.cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: kSize, height: kSize)
        layer.position = CGPoint(x: x, y: y)
        layer.zPosition = z
        layer.transform = transform
        contentLayer?.addSublayer(layer)
        //view.layer.addSublayer(layer)
        
        return layer
    }
    
    static func makePerspectiveTransform()->CATransform3D{
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 2000.0
        return perspective
    }
    
    static func makeSideRotation(x:CGFloat,y:CGFloat,z:CGFloat)->CATransform3D{
        return CATransform3DMakeRotation(CGFloat(Double.pi / 2), x, y, z)
    }
    
    @objc func pan(gesture:UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        // var transform = ThreeDViewController.makePerspectiveTransform()
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, kPanScale * translation.x, 0, 1, 0)
        transform = CATransform3DRotate(transform, -kPanScale * translation.y, 1, 0, 0)
        view.layer.sublayerTransform = transform
    }


}
