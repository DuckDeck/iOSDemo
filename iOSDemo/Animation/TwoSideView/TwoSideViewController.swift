//
//  TwoSideViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class TwoSideViewController: UIViewController {

    let vTwoSide = TwoSideView()
    
    let imgFront = UIImageView()
    let imgBack = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        vTwoSide.frame = CGRect(x: 0, y: 100, width: ScreenWidth, height: 300)
        view.addSubview(vTwoSide)
        
        imgFront.image = UIImage(named: "1")
        imgBack.image = UIImage(named: "2")
        imgFront.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300)
        imgBack.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300)
        
        vTwoSide.frontView = imgFront
        vTwoSide.backView = imgBack
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "turn", style: .plain, target: self, action: #selector(turn))
        
        
    }

    @objc func turn()  {
        vTwoSide.turn(duration: 1.5) {
            print("turn completed")
        }
    }
    
    deinit {
        print("TwoSideViewController deinit")
    }
}
