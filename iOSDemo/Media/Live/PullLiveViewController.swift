//
//  PullLiveViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/5/7.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import IJKMediaFramework
import AVKit

class PullLiveViewController: UIViewController {

    let url = "rtmp://bqbbq.com/mylive/44"
    var player:IJKMediaPlayback?
    var option:IJKFFOptions?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setPlayerOption()
       initPlayer()
        
        
    }
    
    func initPlayer(){
        player = IJKFFMoviePlayerController(contentURLString: url, with: self.option!)
        
       
        let vDisplay = UIView(frame: CGRect(x: 0, y: NavigationBarHeight, w: ScreenWidth, h: ScreenHeight - NavigationBarHeight))
        vDisplay.backgroundColor = UIColor.black
        view.addSubview(vDisplay)
        
        player!.view.frame = vDisplay.bounds
        player!.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        vDisplay.insertSubview(player!.view, at: 1)
        player?.shouldAutoplay = true
        view.autoresizesSubviews = true
        player?.scalingMode = .aspectFill
    }
    
    func setPlayerOption(){
        guard let option = IJKFFOptions.byDefault() else{
            return
        }
        
        //硬解码
        option.setPlayerOptionIntValue(0, forKey: "videotoolbox")
        //
        option.setPlayerOptionIntValue(512, forKey: "vol")
        option.setPlayerOptionIntValue(30, forKey: "max-fps")
        option.setPlayerOptionIntValue(0, forKey: "framedrop")
        option.setPlayerOptionIntValue(960, forKey: "videotoolbox-max-frame-width")
        option.setFormatOptionIntValue(0, forKey: "auto_convert")
        option.setFormatOptionIntValue(1, forKey: "reconnect")
        option.setFormatOptionIntValue(30 * 1000 * 1000, forKey: "timeout")
        //option.setPlayerOptionIntValue(29.97, forKey: "r") ???
        
        option.setFormatOptionValue("tcp", forKey: "rtsp_transport")
        option.setFormatOptionIntValue(1024 * 16, forKey: "probesize")
        option.setFormatOptionIntValue(50000, forKey: "analyzeduration")
       
        self.option = option
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.prepareToPlay()
        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
}
