//
//  ImageTransformViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class ImageTransformViewController: UIViewController {

    var imgRaw:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "图片变换"
        view.backgroundColor = UIColor.white
        imgRaw =  UIImage(named: "2")
        let img1 = UIImageView(image: imgRaw?.imageRotatedByDegrees(degrees: 30))
        img1.frame = CGRect(x: 30, y: 80, width: 100, height: 100)
        view.addSubview(img1)
        
        let img2 = UIImageView(image: imgRaw?.imageByScalingToSize(targetSize: CGSize(width: 130, height: 130)))
        img2.frame = CGRect(x: 150, y: 60, width: 130, height: 130)
        view.addSubview(img2)
        
        let img3 = UIImageView(image: imgRaw?.imageByScalingAspectToMaxSize(targetSize: CGSize(width: 110, height: 110)))
        img3.frame = CGRect(x: 30, y: 200, width: 140, height: 140)
        view.addSubview(img3)
        
        let img4 = UIImageView(image: imgRaw?.imageAtRect(rect: CGRect(x: 50, y: 100, width: 960, height: 960)))
        img4.frame = CGRect(x: 150, y: 200, width: 120, height: 120)
        view.addSubview(img4)
    
    }


}
