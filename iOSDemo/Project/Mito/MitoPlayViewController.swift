//
//  MitoPlayViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/10.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class MitoPlayViewController: UIViewController {

    var item:ImageSet?
    var player:ShadowVideoPlayerView! = nil
    var btnClost = UIButton()
    var btnDownload = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        player = ShadowVideoPlayerView(frame: CGRect(x: 0, y: 80, width: ScreenWidth, height: ScreenHeight - 140 - iPhoneBottomBarHeight), url: URL(string: item!.videoLink)!)
        player.title = item!.title
        player.backgroundColor = UIColor.black
        view.addSubview(player)
       
        
    }
}
