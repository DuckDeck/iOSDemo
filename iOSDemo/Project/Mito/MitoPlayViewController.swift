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
    override func viewDidLoad() {
        super.viewDidLoad()
        player = ShadowVideoPlayerView(frame: CGRect(), url: URL(string: item!.videoLink)!)
        player.title = item!.title
        player.backgroundColor = UIColor.black
        view.addSubview(player)
        player.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(10)
            m.bottom.equalTo(iPhoneBottomBarHeight)
        }
        
    }
}
