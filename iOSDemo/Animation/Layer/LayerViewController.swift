//
//  LayerViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class LayerViewController: UIViewController,CALayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.gray
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
        subLayer.frame = CGRect(x: 30, y: 65, width: 120, height: 160)
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
        subLayer2.frame = CGRect(x: 170, y: 65, width: 120, height: 160)
        view.layer.addSublayer(subLayer2)
        let imgLayer = CALayer()
        imgLayer.contents = UIImage(named: "2")!.cgImage
        imgLayer.frame = subLayer2.bounds
        subLayer2.addSublayer(imgLayer)
        
        let customLayer = CALayer()
        customLayer.delegate = self
        customLayer.backgroundColor = UIColor.green.cgColor
        customLayer.frame = CGRect(x: 30, y: 230, width: 260, height: 210)
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
    }

     func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        let bgColor = UIColor(patternImage: UIImage(named: "heart")!)
        ctx.setFillColor(bgColor.cgColor)
        ctx.fillEllipse(in: CGRect(x: 20, y: 20, width: 100, height: 100))
    }

}
