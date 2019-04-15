//
//  TextLayoutViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 17/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class TextLayoutViewController: UIViewController {

    let lbl = UILabel()
    let vf = FlowView(frame: CGRect(x: 0, y: 100, w: ScreenWidth, h: 300))
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        lbl.text = "我来试试"
        view.addSubview(lbl)
//        lbl.layer.borderWidth = 1
//        lbl.TwoSideAligment()
//        lbl.snp.makeConstraints { (m) in
//            m.left.equalTo(10)
//            m.top.equalTo(100)
//            m.width.equalTo(150)
//            m.height.equalTo(20)
//        }
        // Do any additional setup after loading the view.
        
        
        view.addSubview(vf)
        vf.itemHeight = 30
        vf.backgroundColor = UIColor.lightGray
        vf.horizontalSpace = 10
        vf.verticalSpace = 10
        
        vf.fetchViewBlock = {(index:Int) in
            let lbl = UILabel()
            lbl.textColor = UIColor.random
            lbl.layer.borderWidth = 1
            lbl.layer.borderColor = UIColor.random.cgColor
            lbl.text = "你我他好好".repeatTimes(4.random())
            let width = lbl.text!.textSizeWithFont(font: lbl.font, constrainedToSize: CGSize(width: 200, height: 20))
            return (lbl,Float(width.width),index == 10 )
            
        }

        vf.loadView()
    }


}
