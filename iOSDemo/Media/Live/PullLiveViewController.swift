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
import OCBarrage
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
    let vPanel = UIView()
    let btnPraise = UIButton()
    let btnPushDanmaku = UIButton()
    
    var textLayer:CATextLayer!
    var barrageManager:OCBarrageManager!
    
    override func viewDidLoad() {
       super.viewDidLoad()
       navigationItem.title = "直播流"
       view.backgroundColor = UIColor.white
        
        
        barrageManager = OCBarrageManager()
       
        
        
        
       lblStatus.addTo(view: view).snp.makeConstraints { (m) in
            m.bottom.equalTo(-100)
            m.centerX.equalTo(view)
        }
       
        vPanel.backgroundColor = UIColor(gray: 0.9, alpha: 0.1)
        vPanel.addTo(view: view).snp.makeConstraints { (m) in
            m.bottom.equalTo(-iPhoneBottomBarHeight)
            m.left.right.equalTo(0)
            m.height.equalTo(50)
        }
        
        btnPraise.title(title: "赞").color(color: UIColor.purple).setFont(font: 24).addTo(view: vPanel).snp.makeConstraints { (m) in
            m.left.equalTo(15)
            m.centerY.equalTo(vPanel)
        }
        btnPraise.addTarget(self, action: #selector(praise), for: .touchUpInside)
        btnPushDanmaku.title(title: "发弹幕").color(color: UIColor.purple).setFont(font: 24).addTo(view: vPanel).snp.makeConstraints { (m) in
            m.right.equalTo(-15)
            m.centerY.equalTo(vPanel)
        }
        btnPushDanmaku.addTarget(self, action: #selector(sendDanmaku), for: .touchUpInside)

       initPlayer()
        addNotif()
        view.addSubview(barrageManager.renderView)
        barrageManager.renderView.frame = CGRect(x: 0, y: NavigationBarHeight, w: ScreenWidth, h: ScreenWidth + 100)
        barrageManager.renderView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(notif:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackFinish(notif:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
         NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(notif:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
         NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStatedidChange(notif:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
    
    @objc func loadStateDidChange(notif:Notification)  {
        let loadState = player!.loadState
        if loadState.rawValue & IJKMPMovieLoadState.playthroughOK.rawValue != 0{
             lblStatus.text = "马上开始播放"
            print("loadStateDidChange: IJKMPMovieLoadState.playthroughOK \(loadState)")
        }
        else if loadState.rawValue & IJKMPMovieLoadState.stalled.rawValue != 0{
            lblStatus.text = "暂停播放"
            print("loadStateDidChange: stalled \(loadState)")
        }
        if loadState.rawValue & IJKMPMovieLoadState.playable.rawValue != 0{
            lblStatus.text = "准备播放"
            print("loadStateDidChange: playable \(loadState)")
        }
        
    }
    
    @objc func moviePlayBackFinish(notif:Notification){
        let reason = notif.userInfo![IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! IJKMPMovieFinishReason
        switch reason {
        case IJKMPMovieFinishReason.playbackEnded:
             lblStatus.text = "播放完成"
             print("moviePlayBackFinish: IJKMPMovieFinishReason.playbackEnded \(reason)")
        case IJKMPMovieFinishReason.playbackError:
            lblStatus.text = "播放出现错误"
            print("moviePlayBackFinish: IJKMPMovieFinishReason.playbackError \(reason)")
        case IJKMPMovieFinishReason.userExited:
            lblStatus.text = "用户退出"
            print("moviePlayBackFinish: IJKMPMovieFinishReason.userExited \(reason)")
        }
    }
    
    @objc func mediaIsPreparedToPlayDidChange(notif:Notification){
        print("mediaIsPreparedToPlayDidChange")
    }
    
    @objc func moviePlayBackStatedidChange(notif:Notification){
        switch player!.playbackState {
        case .stopped:
            lblStatus.text = "播放停止"
            print("moviePlayBackStatedidChange: .playbackState . stopped\(player!.playbackState)")
        case .playing:
            lblStatus.text = "正在播放"
            print("moviePlayBackStatedidChange: .playbackState . playing\(player!.playbackState)")
            
        case .paused:
            lblStatus.text = "播放暂停"
            print("moviePlayBackStatedidChange: .playbackState . paused\(player!.playbackState)")
        case .interrupted:
            lblStatus.text = "播放中断"
            print("moviePlayBackStatedidChange: .playbackState . interrupted\(player!.playbackState)")
        case .seekingForward , .seekingBackward:
            lblStatus.text = "播放快进或者快退中"
            print("moviePlayBackStatedidChange: .playbackState . seekingForward or seekingBackward\(player!.playbackState)")
            
        }
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
    
    @objc func praise() {
        let vPraise = HeartView(frame: CGRect(x: 0, y: ScreenHeight - 50, w: 20, h: 24))
        view.addSubview(vPraise)
        vPraise.heartSize = 10
        vPraise.startPraise()
    }
    
    @objc func sendDanmaku() {
        barrageManager.start()
        addBarrage()
    }
    
    func addBarrage(){
        let textDescripor = OCBarrageTextDescriptor()
        textDescripor.text = "晶晶，教教我~我已经学习完《权利的游戏》了"
        textDescripor.textColor = UIColor.red
        textDescripor.positionPriority = .low
        textDescripor.strokeColor = UIColor.blue.withAlphaComponent(0.3)
        textDescripor.strokeWidth = -1
        textDescripor.animationDuration = CGFloat(arc4random() % 5 + 5)
        textDescripor.barrageCellClass = OCBarrageTextCell.self
        barrageManager.renderBarrageDescriptor(textDescripor)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }
}
