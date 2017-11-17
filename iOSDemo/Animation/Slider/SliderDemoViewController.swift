//
//  SliderDemoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 17/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
class SliderDemoViewController: UIViewController {

    var slider:GrandSlider?
    var slider1:GrandSlider?
    var btn:UIBarButtonItem?
    var currentImageNameCount = 1
    var views:[UIView] = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        var img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with:URL(string: "http://img1.gamersky.com/image2015/12/20151219ge_10/gamersky_019origin_037_201512191817808.jpg"))
        // img.image = UIImage(named: "23")
        img.layer.borderWidth = 0.5
        img.layer.borderColor = UIColor.red.cgColor
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/11/20151120ge_4/gamersky_047origin_093_20151120183FDB.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151226ge_6/gamersky_042origin_083_201512261841FA4.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151226ge_6/gamersky_041origin_081_201512261841ABE.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151226ge_6/gamersky_001origin_001_201512261841DFE.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151212ge_8/gamersky_041origin_081_201512121823347.jpg"))
        views.append(img)
        img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151226ge_6/gamersky_028origin_055_201512261841769.jpg"))
        views.append(img)
        slider = GrandSlider(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6),animationDuration:2)
        slider?.views = views
        slider?.tap     = abc
        slider?.dotGap = 10
        slider?.dotWidth = 20
        slider?.normalDotColor = UIColor.blue
        slider?.highlightedDotColor = UIColor.red
        view.addSubview(slider!)
        
        let dView = DotView(frame: CGRect(x: 0, y: 0, width: 16, height: 6), color: UIColor.clear)
        let hdView = DotView(frame: CGRect(x: 0, y: 0, width: 16, height: 6), color: UIColor.white)
        dView.layer.cornerRadius = 3
        dView.layer.borderWidth = 1
        dView.layer.borderColor = UIColor.white.cgColor
        hdView.layer.cornerRadius = 3
        slider1 = GrandSlider(frame: CGRect(x: 0, y: slider!.frame.maxY + 2, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 0.6), animationDuration: 2, dView: dView, hDotView: hdView, dotGap: 8)
        var views1 = [UIView]()
        img = UIImageView()
        img.clipsToBounds = false
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151212ge_8/gamersky_041origin_081_201512121823347.jpg"))
        views1.append(img)
        img = UIImageView()
        img.clipsToBounds = false
        img.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.6)
        img.kf.setImage(with: URL(string: "http://img1.gamersky.com/image2015/12/20151226ge_6/gamersky_028origin_055_201512261841769.jpg"))
        views1.append(img)
        
        slider1?.views = views1
        view.addSubview(slider1!)
        
        
        
        btn = UIBarButtonItem(title: "切换图片数", style: .plain, target: self, action: #selector(SliderDemoViewController.changeView))
        navigationItem.rightBarButtonItems = [btn!]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func abc (_ v:UIView,i:Int){
        print(i)
    }
    @objc func changeView(){
        if currentImageNameCount == 8
        {
            currentImageNameCount = 1
        }
        var surplusViews = [UIView]()
        for i in 1...currentImageNameCount{
            let img = views[i]
            surplusViews.append(img)
        }
        slider?.views = surplusViews
        currentImageNameCount += 1
    }
  




}
