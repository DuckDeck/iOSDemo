//
//  ShadowAudioPlayer.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/6/6.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
import AVKit


class ShadowAudioPlayer: AVPlayer {
    var playbackTimerObserver:Any! = nil
    var item:AVPlayerItem! //AVPlayer的播放item
    var totalTime:CMTime! //总时长
    var currentTime:CMTime! //当前时间
    var anAsset:AVURLAsset! //资产AVURLAsset
    var playerStatus = PlayerStatus.Unknown{     //播放状态
        didSet{
            stateChange?(playerStatus)
        }
    }
    var isPlaying = false
    var bufferProcess:((_ bufferTime:Double,_ totalTime:Double)->Void)?
    var playProcess:((_ playTime:Double,_ totalTime:Double)->Void)?
    var stateChange:((_ state:PlayerStatus)->Void)?
    private var url:URL!
    //与url初始化
//    init(stringUrl:String)  {
//        let u = URL(string: stringUrl)!
//        super.init(url: u)
//        assetWithURL(url: u)
//    }
    
    override init() {
        super.init()
    }
    
    override init(url URL: URL) {
        super.init(url: URL)
        assetWithURL(url: URL)
    }
    
    //公用同一个资产请使用此方法初始化
    convenience init(asset:AVURLAsset){
        let it = AVPlayerItem(asset: asset)
        self.init(playerItem: it)
        setupPlayerWithAsset(asset: asset)
    }

    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
    }
    
    func assetWithURL(url:URL) {
        let dict = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        anAsset = AVURLAsset(url: url, options: dict)
        let keys = ["duration"]
        weak var weakself = self
        anAsset.loadValuesAsynchronously(forKeys: keys) {
            var error:NSError? = nil
            guard let tracksStatus = weakself?.anAsset.statusOfValue(forKey: "duration", error: &error) else{
                print("audio file error")
                weakself?.playerStatus = .Failed
                return
            }
            switch tracksStatus{
            case .loaded:
                DispatchQueue.main.async {
                    if  !weakself!.anAsset.duration.isIndefinite{
                        //let second = weakself!.anAsset.duration.value / Int64(weakself!.anAsset.duration.timescale)
                        weakself?.totalTime = weakself!.anAsset.duration
                    }
                    weakself?.playerStatus = .ReadyToPlay
                }
            case .failed:
              weakself?.playerStatus = .Failed
             print("audio file load fail")
            case .unknown:
               weakself?.playerStatus = .Unknown
               print("audio file load unknow")
                
            default:
                break
            }
        }
        setupPlayerWithAsset(asset: anAsset)
    }
    
    func setupPlayerWithAsset(asset:AVURLAsset)  {
        item = AVPlayerItem(asset: asset)
        addPeriodicTimeObserver()
        addKVO()
        addNotificationCenter()
    }
  
    func addPeriodicTimeObserver()  {
        weak var weakself = self
        playbackTimerObserver = self.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: nil, using: { (time) in
            //ISSUE 当在滑动的时侯，又会反馈带动这里滑动，所以会出现一跳一跳的情况。
            //let value = Float(weakself!.item.currentTime().value / Int64(weakself!.item.currentTime().timescale))
            
            //这里看情况
        })
    }
    
    
    func addKVO()  {
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else {
            return
        }
        if key == "status"{
            guard let itemStatus = AVPlayerItemStatus(rawValue: change![NSKeyValueChangeKey.newKey] as! Int) else{
                return
            }
            switch itemStatus{
            case .unknown:
                playerStatus = .Unknown
                print("AVPlayerItemStatusUnknown")
            case .readyToPlay:
                playerStatus = .ReadyToPlay
                print("AVPlayerItemStatusReadyToPlay")
            case .failed:
                playerStatus = .Failed
                print("AVPlayerItemStatusFailed")
            }
        }
        else if key == "loadedTimeRanges"{ //监听播放器的下载进度
            let loadedTimeRanges = item.loadedTimeRanges
            let timeRange = loadedTimeRanges.first!.timeRangeValue // 获取缓冲区域
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            let timeInterval = startSeconds + durationSeconds // 计算缓冲总进度
            let duration = item.duration
            let totalDuration = CMTimeGetSeconds(duration)
            bufferProcess?(timeInterval,totalDuration)
        }
        else if key == "playbackBufferEmpty"{
            playerStatus = .Buffering
           
        }
        else if key == "playbackLikelyToKeepUp"{
            print("缓冲达到可播放")
            playerStatus = .ReadyToPlay
        }
        else if key == "rate"{
            if change![NSKeyValueChangeKey.newKey] as! Int == 0{
                isPlaying = false
                playerStatus = .Playing
            }
            else{
                isPlaying = true
                playerStatus = .Stopped
            }
        }
    }
    
    func addNotificationCenter()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ShadowPlayerItemDidPlayToEndTimeNotification(notif:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentTime())
    }
    
    
    func stop() {
        item.removeObserver(self, forKeyPath: "status")
        self.removeTimeObserver(playbackTimerObserver)
        item.removeObserver(self, forKeyPath: "loadedTimeRanges")
        item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentTime())
        pause()
        anAsset = nil
        item = nil
    }
}



extension ShadowAudioPlayer{
    @objc func ShadowPlayerItemDidPlayToEndTimeNotification(notif:Notification)  {
        item.seek(to: kCMTimeZero)
        pause()
        playerStatus = .ReadyToPlay
    }
}
