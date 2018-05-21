//
//  ShadowPlayer.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/21.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
import AVKit

enum VideoGravity {
    case ResizeAspect,ResizeAspectFill,Resize
}
enum PlayerStatus{
    case Failed,ReadyToPlay,Unknown,Bufferin,Playing,Stopped
}
class ShadowPlayer: UIView {
    var playbackTimerObserver:Any! = nil
    var player:AVPlayer!{
        set{
            self.playerLayer.player = newValue
        }
        get{
            return self.playerLayer.player!
        }
    }
    var playerLayer:AVPlayerLayer{
        get{
            return self.layer as! AVPlayerLayer
        }
    }
    var item:AVPlayerItem! //AVPlayer的播放item
    var totalTime:CMTime! //总时长
    var currentTime:CMTime! //当前时间
    var anAsset:AVURLAsset! //资产AVURLAsset
    var rate:Float //播放器Playback Rate
    {
        get{
            return self.player.rate
        }
        set{
            self.player.rate = newValue
        }
    }
    var status = PlayerStatus.Unknown     //播放状态
    var mode = VideoGravity.ResizeAspect  //videoGravity设置屏幕填充模式，（只写）
    {
        didSet{
            switch mode {
            case .ResizeAspect:
                self.playerLayer.videoGravity = .resizeAspect
            case .Resize:
                self.playerLayer.videoGravity = .resize
            case .ResizeAspectFill:
                self.playerLayer.videoGravity = .resizeAspectFill
            }
        }
    }
    var oldConstriants:[NSLayoutConstraint]!
    var isPlaying = false
    var isFullScreen = false
    var title:String{
        set{
            lblTitle.text = newValue
        }
        get{
            return lblTitle.text!
        }
    }
    let vPlay = ShadowPlayView(frame: CGRect())
    let vControl = ShadowControlView(frame:CGRect())
    private var url:URL!
    private let lblTitle = UILabel()
    private let vActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    static var count = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    //与url初始化
    convenience init(url:URL)  {
        self.init(frame: CGRect())
        self.url = url
        setupPlayerUI()
        assetWithURL(url: url)
    }
    //公用同一个资产请使用此方法初始化
    convenience init(asset:AVURLAsset){
        self.init(frame: CGRect())
        setupPlayerUI()
        setupPlayerWithAsset(asset: asset)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupPlayerUI() {
        self.vActivity.startAnimating()
        //添加标题
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.font = UIFont.systemFont(ofSize: 15)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor.white
        lblTitle.numberOfLines = 2
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(12)
            m.width.equalTo(self)
        }
         //添加点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(ges:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        //添加播放和暂停按钮
        vPlay.backgroundColor = UIColor.clear
        vPlay.playBlock = {[weak self](view:ShadowPlayView,state:Bool) in
            ShadowPlayer.count = 0
            if state{
                self?.play()
            }
            else{
                self?.pause()
            }
        }
        addSubview(vPlay)
        vPlay.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
         //添加控制视图
        vControl.delegate = self
        vControl.backgroundColor = UIColor.clear
        if let ges = self.vPlay.btnImage.gestureRecognizers?.first{
             vControl.tapGesture?.require(toFail: ges)
        }
        addSubview(vControl)
        vControl.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.height.equalTo(44)
        }
        layoutIfNeeded()
         //添加加载视图
        vActivity.hidesWhenStopped = true
        addSubview(vActivity)
        vActivity.snp.makeConstraints { (m) in
            m.width.height.equalTo(80)
            m.center.equalTo(self)
        }
         //初始化时间
        vControl.currentTime = "00:00"
        vControl.totalTime = "00:00"
    }
   
    @objc func handleTapAction(ges:UIGestureRecognizer) {
        
    }
    
    func assetWithURL(url:URL) {
        let dict = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        anAsset = AVURLAsset(url: url, options: dict)
        let keys = ["duration"]
        weak var weakself = self
        anAsset.loadValuesAsynchronously(forKeys: keys) {
            let error:NSErrorPointer! = nil
            guard let tracksStatus = weakself?.anAsset.statusOfValue(forKey: "duration", error: error) else{
                return
            }
            switch tracksStatus{
            case .loaded:
                DispatchQueue.main.async {
                    if  !weakself!.anAsset.duration.isIndefinite{
                        let second = weakself!.anAsset.duration.value / Int64(weakself!.anAsset.duration.timescale)
                        weakself?.vControl.totalTime = weakself!.convertTime(second: Float(second))
                        weakself?.vControl.minValue = 0
                        weakself?.vControl.maxValue = Float(second)
                    }
                }
            default:
                break
            }
        }
    }
    
    func setupPlayerWithAsset(asset:AVURLAsset)  {
        item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playerLayer.displayIfNeeded()
        playerLayer.videoGravity = .resizeAspectFill
        
    }
    
    func addPeriodicTimeObserver()  {
         weak var weakself = self
        playbackTimerObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: nil, using: { (time) in
            weakself?.vControl.value = Float(weakself!.item.currentTime().value / Int64(weakself!.item.currentTime().timescale))
            if !weakself!.anAsset.duration.isIndefinite{
                weakself?.vControl.currentTime = weakself!.convertTime(second: weakself!.vControl.value)
            }
            if ShadowPlayer.count >= 5 {
                weakself?.setSubViewsIsHide(isHide: true)
            }
            else{
                weakself?.setSubViewsIsHide(isHide: false)
            }
            ShadowPlayer.count += 1
        })
    }
    
    func addKVO()  {
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    func addNotificationCenter()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ShadowPlayerItemDidPlayToEndTimeNotification(notif:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentTime())
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(notif:)), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(notif:)), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func convertTime(second:Float)->String{
        let d = Date(timeIntervalSince1970: TimeInterval(second))
        let format = DateFormatter()
        if second / 3600 >= 1{
            format.dateFormat = "HH:mm:ss"
        }
        else{
            format.dateFormat = "mnm:ss"
        }
        return format.string(from: d)
    }
        
        
    func play()  {
        if self.player != nil{
            self.player.play()
        }
    }
    
    func pause() {
        if self.player != nil{
            self.player.pause()
        }

    }
    
    func stop() {
        item.removeObserver(self, forKeyPath: "statue")
        player.removeTimeObserver(playbackTimerObserver)
        item.removeObserver(self, forKeyPath: "loadedTimeRanges")
        item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentTime())
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        if player != nil{
            pause()
            anAsset = nil
            item = nil
            vControl.value = 0
            vControl.currentTime = "00:00"
            vControl.totalTime = "00:00"
            player = nil
            removeSubviews()
        }
    }
    
    func setSubViewsIsHide(isHide:Bool){
        vControl.isHidden = isHide
        vPlay.isHidden = isHide
        lblTitle.isHidden = isHide
    }
    
  
    func interfaceOrientation(orientation:UIInterfaceOrientation)  {
        //有一些判断
        if orientation == .landscapeRight || orientation == .landscapeLeft{
            
        }else if orientation == .portrait{
            
        }else if orientation == .portraitUpsideDown{
            
        }
    }
}

extension ShadowPlayer:UIGestureRecognizerDelegate,ShadowControlViewDelegate{
    func controlView(view: ShadowControlView, pointSliderLocationWithCurrentValue: Float) {
        ShadowPlayer.count = 0
        let pointTime = CMTimeMake(Int64(pointSliderLocationWithCurrentValue) * Int64(item.currentTime().timescale), item.currentTime().timescale)
        item.seek(to: pointTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func controlView(view: ShadowControlView, draggedPositionWithSlider: UISlider) {
        ShadowPlayer.count = 0
        let pointTime = CMTimeMake(Int64(view.value) * Int64(item.currentTime().timescale), item.currentTime().timescale)
        item.seek(to: pointTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func controlView(view: ShadowControlView, withLargeButton: UIButton) {
        ShadowPlayer.count = 0
        if ScreenWidth < ScreenHeight{
            
        }
        else{
            
        }
    }
    
    
}

extension ShadowPlayer{
    @objc func ShadowPlayerItemDidPlayToEndTimeNotification(notif:Notification)  {
        item.seek(to: kCMTimeZero)
        setSubViewsIsHide(isHide: false)
        ShadowPlayer.count = 0
        pause()
        vPlay.btnImage.isSelected = false
    }
    @objc func deviceOrientationDidChange(notif:Notification)  {
        let _interfaceOrientation = UIApplication.shared.statusBarOrientation
        switch _interfaceOrientation {
        case .landscapeLeft,.landscapeRight:
            isFullScreen = true
            if oldConstriants == nil{
                
            }
        default:
            
        }
    }
    @objc func willResignActive(notif:Notification)  {
        
    }
}
