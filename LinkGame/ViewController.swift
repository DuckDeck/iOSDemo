//
//  ViewController.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  //  var gameView:GameView?
    var leftTime:Int?
    var timer:Timer?
    var isPlaying = false
    var lostAlert:UIAlertView?
    var successAlert:UIAlertView?
    var btnStart:UIButton?
    var lblTime:UILabel?
    var vMenu:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

