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
enum PlayerStatus:Int{
    case Failed = 0,GetInfo, ReadyToPlay,Unknown,Buffering,Playing,Paused, Stopped,Finished
}

enum ShadowUIConfig {
    case HideFullScreenButton
}

protocol ShadowPlayDelegate:class {
    func bufferProcess(current:Float,duration:Float)
    func playStateChange(status:PlayerStatus,info:MediaInfo?)
    func playProcess(current:Float,duration:Float)
}

struct MediaInfo {
    let mediaType:AVMediaType
    let resolution:String?
    let duration:Double
    let frameRate:Float
    let bitRate:Float
}

class ShadowPlayer:NSObject {
//目前这个方法还不支持缓存到本地，需要改进
    var playbackTimerObserver:Any! = nil
    fileprivate var item:AVPlayerItem! //AVPlayer的播放item
    var totalTime:CMTime! //总时长
    fileprivate var anAsset:AVURLAsset! //资产AVURLAsset
    var _player:AVPlayer!
    var player:AVPlayer!{
        get{
            if playerLayer != nil{
                return playerLayer.player!
            }
            else{
                return _player
            }
        }
        set{
            if playerLayer != nil{
                playerLayer.player = newValue
            }
            else{
                _player = newValue
            }
        }
    }
    var playerLayer:AVPlayerLayer!
    var status = PlayerStatus.Unknown     //播放状态
    fileprivate var url:URL!
    var isCached = false
    var cachePath:String?
    var dataManager:ShadowDataManager?
    var lastToEndDownloader:ShadowDownloader?
    var nonToEndDownloaderArray:[ShadowDownloader]?
    var isFileExist = false
    var isFileCacheComplete = false
    var isAutoCache = true

    weak var delegate:ShadowPlayDelegate?
    var isSeeking = false
    var currentTime:Double
    {
        get{
            return item.currentTime().seconds
        }
        set{
            let tmp = status
            if status == .Playing{
                pause()
            }
            if isSeeking {
                return
            }
            if let timeScale = player.currentItem?.asset.duration.timescale {
                print("seek 到 \(newValue)timescale \(timeScale) ")
                isSeeking = true
                player.seek(to: CMTimeMakeWithSeconds(newValue, preferredTimescale: timeScale), completionHandler: {[weak self] (complete) in
                    self?.isSeeking = false
                    if tmp == .Playing{
                        self?.play()
                    }
                })
            }
        }
    }
    
    var rate:Float //播放器Playback Rate
    {
        get{
            return self.player.rate
        }
        set{
            self.player.rate = newValue
        }
    }
    
    var isPlaying:Bool{
        get{
            return player.rate > 0
        }
    }
    
    fileprivate override init() {}
    
    //与url初始化,目前只支持HTTP协议和FILE协议
    //这个用于播放音频
    convenience init(url:URL,autoCache:Bool = true)  {
        self.init()
        self.url = url
        self.isAutoCache = autoCache
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        self.assetWithURL(url: url)
    }
    //这个用于播放视频
    convenience init(url:URL,playerLayer:AVPlayerLayer,autoCache:Bool = true)  {
        self.init()
        self.url = url
        self.playerLayer = playerLayer
        self.assetWithURL(url: url)
    }
    
    //还要一个可以配置的初始化
    
    func replaceWithUrl(url:URL){
        stop()
        assetWithURL(url: url)
    }
   
    
    func assetWithURL(url:URL) {
        isFileCacheComplete = false
        let dict = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        
//        if url.absoluteString.hasPrefix("http"){
//             let filePath = ShadowDataManager.checkCached(urlStr: url.absoluteString)
//             if filePath.1 {
//                anAsset = AVURLAsset(url: URL(fileURLWithPath: filePath.0), options: dict)
//                isFileExist = true
//             }
//             else{
//                self.dataManager = ShadowDataManager(urlStr: url.absoluteString, cachePath: filePath.0)!
//                self.dataManager?.delegate = self
//                //此处需要将原始的url的协议头处理成系统无法处理的自定义协议头，此时才会进入AVAssetResourceLoaderDelegate的代理方法中
//                //目前这个无解，从dataManager获取的数据无法播放，
//                let schemaUrl = url.changeSchema(targetSchema: "streaming")
//                anAsset = AVURLAsset(url: schemaUrl!, options: nil)
//                anAsset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
//             }
//        }
//        else{
//            anAsset = AVURLAsset(url: url, options: dict)
//        }
        anAsset = AVURLAsset(url: url, options: dict)
       
        let keys = ["duration"]
        weak var weakself = self
        //如果使用第三方下载这个就不能用了
        anAsset.loadValuesAsynchronously(forKeys: keys) {
            var error:NSError? = nil
            guard let tracksStatus = weakself?.anAsset.statusOfValue(forKey: "duration", error: &error) else{
                return
            }
            switch tracksStatus{
            case .loaded:
                DispatchQueue.main.async {
                    guard let mediaInfo = weakself?.anAsset.tracks.first?.formatDescriptions.first else{
                        weakself?.delegate?.playStateChange(status: .GetInfo, info: nil)//表示fail
                        return
                    }
                    let format = mediaInfo as! CMFormatDescription
                    let type = CMFormatDescriptionGetMediaType(format)
                    if type == kCMMediaType_Video{
                        guard let track = weakself?.anAsset.tracks(withMediaType: .video).first else{
                            return
                        }
                        let res = track.naturalSize
                        weakself?.totalTime = track.timeRange.duration
                        let info = MediaInfo(mediaType: AVMediaType.video, resolution: "\(res.width) * \(res.height)", duration: track.timeRange.duration.seconds, frameRate: track.nominalFrameRate, bitRate: track.estimatedDataRate)
                        
                        weakself?.delegate?.playStateChange(status: .GetInfo, info: info)
                        
                    }
                    else if type == kCMMediaType_Audio{
                        guard let track = weakself?.anAsset.tracks(withMediaType: .audio).first else{
                            return
                        }
                        weakself?.totalTime = track.timeRange.duration
                        let info = MediaInfo(mediaType: AVMediaType.audio, resolution: "", duration: track.timeRange.duration.seconds, frameRate: track.nominalFrameRate, bitRate: track.estimatedDataRate)
                        weakself?.delegate?.playStateChange(status: .GetInfo, info: info)
                    }
                    
                  
                }
            case .failed:
               // weakself?.showErrorInfo(info: error?.localizedDescription ?? "视频出现错误，请检查后重新播放")
                print(error?.localizedDescription ?? "")
            case .unknown:
                // weakself?.showErrorInfo(info: "未知视频格式，请检查后重新播放")
                print(error?.localizedDescription ?? "")
            default:
                break
            }
        }
        setupPlayerWithAsset(asset: anAsset)
    }
    
    func setupPlayerWithAsset(asset:AVURLAsset)  {
        item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        if #available(iOS 10.0, *) {
            player.automaticallyWaitsToMinimizeStalling = false
        } else {
            // Fallback on earlier versions
        }
      
        addPeriodicTimeObserver()
        addKVO()
        addNotificationCenter()

    }
    
    func addPeriodicTimeObserver()  {
        weak var weakself = self
        playbackTimerObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: nil, using: { (time) in
            //ISSUE 当在滑动的时侯，又会反馈带动这里滑动，所以会出现一跳一跳的情况。
            if weakself!.isSeeking{
                return
            }
            let value = Float(weakself!.item.currentTime().value / Int64(weakself!.item.currentTime().timescale))
            weakself?.delegate?.playProcess(current: value, duration: Float(weakself!.item.duration.seconds))
        })
    }
    
    func addKVO()  {
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else {
            return
        }
        if key == "status"{
            guard let itemStatus = AVPlayerItem.Status(rawValue: change![NSKeyValueChangeKey.newKey] as! Int) else{
                return
            }
            switch itemStatus{
            case .unknown:
                status = .Unknown
                print("status出现unknow")
            case .readyToPlay:
                status = .ReadyToPlay
                print("缓冲达到可播放")
            case .failed:
                status = .Failed
                print("status出现fail")
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
            print("缓冲到\(timeInterval)")
            delegate?.bufferProcess(current: Float(timeInterval), duration:  Float(totalDuration))
        }
        else if key == "playbackBufferEmpty"{
            status = .Buffering
            pause()
        }
        else if key == "playbackLikelyToKeepUp"{
            print("缓冲达到可播放")
            status = .ReadyToPlay
        }
        else if key == "rate"{
            if change![NSKeyValueChangeKey.newKey] as! Int == 0{
                status = .Playing
            }
            else{
                status = .Stopped
            }
        }
        delegate?.playStateChange(status: status, info: nil)
    }
    
    func addNotificationCenter()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ShadowPlayerItemDidPlayToEndTimeNotification(notif:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func convertTime(second:Float)->String{
        let d = Date(timeIntervalSince1970: TimeInterval(second))
        let format = DateFormatter()
        if second / 3600 >= 1{
            format.dateFormat = "HH:mm:ss"
        }
        else{
            format.dateFormat = "mm:ss"
        }
        return format.string(from: d)
    }
        
 
   
    func play()  {
        if self.player != nil{
            self.player.play()
            status = .Playing
            delegate?.playStateChange(status: status, info: nil)
        }
        else{
            setupPlayerWithAsset(asset: anAsset)
            self.player.play()
            status = .Playing
            delegate?.playStateChange(status: status, info: nil)
        }
    }
    
    func pause() {
        if self.player != nil{
            self.player.pause()
            status = .Paused
            delegate?.playStateChange(status: status, info: nil)
        }
       
    }
    
    func stop() {
        item.removeObserver(self, forKeyPath: "status")
        player.removeTimeObserver(playbackTimerObserver)
        item.removeObserver(self, forKeyPath: "loadedTimeRanges")
        item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        player.removeObserver(self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentTime())
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        if player != nil{
            pause()
            anAsset = nil
            item = nil
            _player = nil
        }
        status = .Stopped
        delegate?.playStateChange(status: status, info: nil)
        dataManager = nil
        lastToEndDownloader?.cancel()
        lastToEndDownloader = nil
        if let arr = nonToEndDownloaderArray{
            for downloader in arr{
                downloader.cancel()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}



extension ShadowPlayer{
    @objc func ShadowPlayerItemDidPlayToEndTimeNotification(notif:Notification)  {
        item.seek(to: CMTime.zero)
        self.player.pause()
        status = .Finished
        delegate?.playStateChange(status: status, info: nil)
    }
   

}

extension ShadowPlayer:ShadowDataManagerDelegate,AVAssetResourceLoaderDelegate{
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        handleLoadingRequest(loadingRequest: loadingRequest)
        Log(message: "开始请求，当前位置\(loadingRequest.dataRequest!.currentOffset)---请求长度\(loadingRequest.dataRequest!.requestedLength)----请求偏移\(loadingRequest.dataRequest!.requestedOffset)")
        //Issue1 目前对于测试视频来说，不会做分片请求，第二次就直接全部请求了。
        //Issue2还有问题就是请求完的数据不会推过来，播放器接收不到数据无法播放
        //Issue3视频暂时有问题，用音频试试
        //Issue4需要处理后缀没有的问题，如果保存的文件没有后缀好像不能播放
        return true
    }
    
    func handleLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest)  {
        //取消上一个requestsAllDataToEndOfResource的请求
        if loadingRequest.dataRequest!.requestsAllDataToEndOfResource{
            if lastToEndDownloader != nil{
                let lastRequestedOffset = lastToEndDownloader!.loadingRequest.dataRequest!.requestedOffset
                let lastRequestedLength = lastToEndDownloader!.loadingRequest.dataRequest?.requestedLength
                let lastCurrentOffset = lastToEndDownloader?.loadingRequest.dataRequest!.currentOffset
                let currentRequestedOffset = loadingRequest.dataRequest!.requestedOffset
                let currentRequestedLength = loadingRequest.dataRequest!.requestedLength
                let currentCurrentOffset = loadingRequest.dataRequest!.currentOffset
                if lastRequestedOffset == currentRequestedOffset && lastRequestedLength == currentRequestedLength && lastCurrentOffset == currentCurrentOffset{
                    //在弱网络情况下，下载文件最后部分时，会出现所请求数据完全一致的loadingRequest（且requestsAllDataToEndOfResource = YES），此时不应取消前一个与其相同的请求；否则会无限生成相同的请求范围的loadingRequest，无限取消，产生循环
                    return
                }
                lastToEndDownloader?.cancel()
                
            }
        }
        let rangeModelArray = ShadowRangeManager.shareInstance!.calculateRangeModelArrayForLoadingRequest(loadingRequest: loadingRequest)
        //如果rangeModelArray返回为空，说明这次请示已经被缓存，那么就不需要
        let urlScheme = url.scheme
        let downloader = ShadowDownloader(loadingRequest: loadingRequest, rangeInfoArray: rangeModelArray, urlSchema: urlScheme!, dataManager: dataManager!)
        if loadingRequest.dataRequest!.requestsAllDataToEndOfResource{
            lastToEndDownloader = downloader
        }
        else{
            if nonToEndDownloaderArray == nil{
                nonToEndDownloaderArray = [ShadowDownloader]()
            }
            nonToEndDownloaderArray?.append(downloader!)
        }
    }
    
    func fileDownloadAndSaveSuccess() {
        if !isFileExist{
            isFileCacheComplete = true
        }
    }
}
