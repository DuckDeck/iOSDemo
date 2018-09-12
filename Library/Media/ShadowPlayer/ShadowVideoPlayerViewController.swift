//
//  ShadowPlayerViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/22.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
//http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4
class ShadowVideoPlayerViewController: UIViewController {
    var url:URL?
    var videoTitle:String?{
        didSet{
            player.title = videoTitle ?? ""
        }
    }
    let btnClose = UIButton()
    
    var player : ShadowVideoPlayerView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(navigationController == nil, "你不能Navigation到这个页面")
        assert(url != nil, "videl url can not be nil")
        player = ShadowVideoPlayerView(frame: CGRect(), url: url!)
 
        player.title = url!.lastPathComponent
        player.backgroundColor = UIColor.black
        view.addSubview(player)
        player.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(50)
            m.bottom.equalTo(-50)
        }
        
        btnClose.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
        view.addSubview(btnClose)
        btnClose.snp.makeConstraints { (m) in
            m.left.top.equalTo(10)
        }
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
    }
    
    @objc func close()  {
        dismiss(animated: true, completion: nil)
    }
}
