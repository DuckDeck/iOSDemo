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
    var player:IJKMediaPlayback!
    var option:IJKFFOptions = {
         let option = IJKFFOptions.byDefault()!
        
        //硬解码
        option.setPlayerOptionIntValue(1, forKey: "videotoolbox")
        //
        //        option.setPlayerOptionIntValue(512, forKey: "vol")
        //        option.setPlayerOptionIntValue(30, forKey: "max-fps")
        //        option.setPlayerOptionIntValue(0, forKey: "framedrop")
        //        option.setPlayerOptionIntValue(960, forKey: "videotoolbox-max-frame-width")
        //        option.setFormatOptionIntValue(0, forKey: "auto_convert")
        //        option.setFormatOptionIntValue(1, forKey: "reconnect")
        //        option.setFormatOptionIntValue(30 * 1000 * 1000, forKey: "timeout")
        //        //option.setPlayerOptionIntValue(29.97, forKey: "r") ???
        //
        //        option.setFormatOptionValue("tcp", forKey: "rtsp_transport")
        //        option.setFormatOptionIntValue(1024 * 16, forKey: "probesize")
        //        option.setFormatOptionIntValue(50000, forKey: "analyzeduration")
        
        return option
    }()
    let lblStatus = UILabel()
    override func viewDidLoad() {
       super.viewDidLoad()
       navigationItem.title = "直播流"
       view.backgroundColor = UIColor.white
       lblStatus.addTo(view: view).snp.makeConstraints { (m) in
            m.bottom.equalTo(-100)
            m.centerX.equalTo(view)
        }
       
       initPlayer()
        addNotif()
        
    }
    
    func initPlayer(){
        player = IJKFFMoviePlayerController(contentURLString: url, with: self.option)
        
        player.view.frame = CGRect(x: 0, y: NavigationBarHeight, w: ScreenWidth, h: ScreenWidth + 100)
        //player!.view.backgroundColor = UIColor.white
        player.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        
        player.shouldAutoplay = true
        view.autoresizesSubviews = true
        player.scalingMode = .aspectFit
        view.addSubview(player.view)
    }
 
    
    
    func addNotif()  {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackFinish), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
         NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
         NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStatedidChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
    
    @objc func loadStateDidChange()  {
        let loadState = player!.loadState
        switch loadState {
        case IJKMPMovieLoadState.playthroughOK:
            lblStatus.text = "马上开始播放"
        case IJKMPMovieLoadState.playable:
            lblStatus.text = "准备播放"
        case IJKMPMovieLoadState.stalled:
            lblStatus.text = "暂停播放"
        default:
            break
        }
    }
    
    @objc func moviePlayBackFinish(){
        
    }
    
    @objc func mediaIsPreparedToPlayDidChange(){
        
    }
    
    @objc func moviePlayBackStatedidChange(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player?.prepareToPlay()
        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        player?.shutdown()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
}
