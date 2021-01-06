//
//  ShadowPlayer.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/21.
//  Copyright © 2018 Stan Hu. All rights reserved.
//
/*
import Foundation
import AVKit

enum VideoGravity {
    case ResizeAspect,ResizeAspectFill,Resize
}
enum PlayerStatus{
    case Failed,ReadyToPlay,Unknown,Buffering,Playing,Stopped
}
class ShadowPlayer: UIView {
    //目前这个方法还不支持缓存到本地，需要改进
    var playbackTimerObserver:Any! = nil
    var item:AVPlayerItem! //AVPlayer的播放item
    var totalTime:CMTime! //总时长
    var currentTime:CMTime! //当前时间
    var anAsset:AVURLAsset! //资产AVURLAsset
    var status = PlayerStatus.Unknown     //播放状态
    var oldConstriants:[NSLayoutConstraint]!
    var isPlaying = false
    var isFullScreen = false
    var isDraging = false
    private var url:URL!
    private let lblTitle = UILabel()
    private let btnVideoInfo = UIButton()
    private let vScInfo = UIScrollView()
    private let vErrorVideo = UIView()
    private let lblError = UILabel()
    private let vActivity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    weak private var currentVC:UIViewController? = nil
    static var count = 0
    var isCached = false
    var cachePath:String?
    var dataManager:ShadowDataManager?
    var lastToEndDownloader:ShadowDownloader?
    var nonToEndDownloaderArray:[ShadowDownloader]?
    var isFileExist = false
    var isFileCacheComplete = false
    override class var layerClass: AnyClass {
        get{
            return AVPlayerLayer.self
        }
        
    }
    
    
    var player:AVPlayer!{
        set{
            self.playerLayer.player = newValue
        }
        get{
            return self.playerLayer.player!
        }
    }
    private var playerLayer:AVPlayerLayer{
        get{
            return self.layer as! AVPlayerLayer
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
    
    var title:String{
        set{
            lblTitle.text = newValue
        }
        get{
            return lblTitle.text ?? ""
        }
    }
    let vPlay = ShadowPlayView(frame: CGRect())
    let vControl = ShadowControlView(frame:CGRect())
    
    
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
    
    func replaceWithUrl(url:URL){
        assetWithURL(url: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupPlayerUI() {
        self.vActivity.startAnimating()
        //添加标题
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.font = UIFont.systemFont(ofSize: 15)
        lblTitle.textAlignment = .left
        lblTitle.textColor = UIColor.white
        lblTitle.numberOfLines = 2
        addSubview(lblTitle)
        lblTitle.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.top.equalTo(10)
            m.right.equalTo(-30)
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
        vPlay.isHidden = true
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
        
        btnVideoInfo.setImage(#imageLiteral(resourceName: "info"), for: .normal)
        addSubview(btnVideoInfo)
        btnVideoInfo.snp.makeConstraints { (m) in
            m.right.equalTo(-10)
            m.top.equalTo(10)
            m.width.height.equalTo(20)
        }
        btnVideoInfo.addTarget(self, action: #selector(showVideoInfo), for: .touchUpInside)
        
        
        vScInfo.backgroundColor = UIColor(gray: 0.3, alpha: 0.5)
        addSubview(vScInfo)
        vScInfo.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(handleTapInfo(ges:)))
        vScInfo.addGestureRecognizer(tapInfo)
        vScInfo.isHidden = true
        let infos = getVideoInfo()
        var tmp:UIView! = nil
        
        for info in infos{
            let lbl = UILabel()
            lbl.text = "\(info.0) : \(info.1)"
            lbl.textColor = UIColor.white
            lbl.font = UIFont.systemFont(ofSize: 14)
            vScInfo.addSubview(lbl)
            lbl.snp.makeConstraints { (m) in
                m.left.equalTo(15)
                if tmp == nil{
                    m.top.equalTo(10)
                }
                else{
                    m.top.equalTo(tmp.snp.bottom).offset(5)
                }
                m.width.equalTo(ScreenWidth - 30)
                m.height.equalTo(18)
            }
            tmp = lbl
        }
        if tmp != nil{
            tmp.snp.makeConstraints { (m) in
                m.bottom.equalTo(-10)
            }
        }
        vErrorVideo.isHidden = true
        vErrorVideo.backgroundColor = UIColor(gray: 0.3, alpha: 0.5)
        addSubview(vErrorVideo)
        let tapError = UITapGestureRecognizer(target: self, action: #selector(handleTapError(ges:)))
        vErrorVideo.addGestureRecognizer(tapError)
        vErrorVideo.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
        let imgError = UIImageView(image: #imageLiteral(resourceName: "icon_error"))
        vErrorVideo.addSubview(imgError)
        imgError.snp.makeConstraints { (m) in
            m.center.equalTo(self)
        }
        
        lblError.textColor = UIColor.white
        lblError.font = UIFont.systemFont(ofSize: 18)
        lblError.textAlignment = .center
        vErrorVideo.addSubview(lblError)
        lblError.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(imgError.snp.bottom).offset(4)
        }
    }
    
    @objc func handleTapAction(ges:UIGestureRecognizer) {
        setSubViewsIsHide(isHide: false)
        ShadowPlayer.count = 0
    }
    
    @objc func showVideoInfo()  {
        pause()
        vScInfo.isHidden = false
        
    }
    
    @objc func handleTapInfo(ges:UIGestureRecognizer)  {
        vScInfo.isHidden = true
        play()
    }
    
    
    @objc func handleTapError(ges:UIGestureRecognizer)  {
        vErrorVideo.isHidden = true
        //先这样吧
    }
    
    func assetWithURL(url:URL) {
        isFileCacheComplete = false
        let dict = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
        if url.absoluteString.hasPrefix("http"){
            let filePath = ShadowDataManager.checkCached(urlStr: url.absoluteString)
            if filePath.1 {
                anAsset = AVURLAsset(url: URL(fileURLWithPath: filePath.0), options: dict)
                isFileExist = true
            }
            else{
                self.dataManager = ShadowDataManager(urlStr: url.absoluteString, cachePath: filePath.0)!
                self.dataManager?.delegate = self
                //此处需要将原始的url的协议头处理成系统无法处理的自定义协议头，此时才会进入AVAssetResourceLoaderDelegate的代理方法中
                let schemaUrl = url.changeSchema(targetSchema: "streaming")
                anAsset = AVURLAsset(url: schemaUrl!, options: nil)
                anAsset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            }
        }
        else{
            anAsset = AVURLAsset(url: url, options: dict)
        }
        //anAsset = AVURLAsset(url: url, options: dict)
        let keys = ["duration"]
        weak var weakself = self
        //如果使用第三方下载这个就不能用了
        
        anAsset.loadValuesAsynchronously(forKeys: keys) {
            var error:NSError? = nil
            guard let tracksStatus = weakself?.anAsset.statusOfValue(forKey: "duration", error: &error) else{
                weakself?.showErrorInfo(info: error?.localizedDescription ?? "视频出现错误，请检查后重新播放")
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
            case .failed:
                // weakself?.showErrorInfo(info: error?.localizedDescription ?? "视频出现错误，请检查后重新播放")
                print(error?.localizedDescription)
            case .unknown:
                // weakself?.showErrorInfo(info: "未知视频格式，请检查后重新播放")
                print(error?.localizedDescription)
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
        playerLayer.displayIfNeeded()
        playerLayer.videoGravity = .resizeAspectFill
        addPeriodicTimeObserver()
        addKVO()
        addNotificationCenter()
        
    }
    
    func addPeriodicTimeObserver()  {
        weak var weakself = self
        playbackTimerObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: nil, using: { (time) in
            //ISSUE 当在滑动的时侯，又会反馈带动这里滑动，所以会出现一跳一跳的情况。
            //let value = Float(weakself!.item.currentTime().value / Int64(weakself!.item.currentTime().timescale))
            
            if !weakself!.isDraging{
                weakself?.vControl.value = Float(weakself!.item.currentTime().value / Int64(weakself!.item.currentTime().timescale))
            }
            
            
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
                status = .Unknown
                print("AVPlayerItemStatusUnknown")
            case .readyToPlay:
                status = .ReadyToPlay
                print("AVPlayerItemStatusReadyToPlay")
                vPlay.isHidden = false
            case .failed:
                status = .Failed
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
            vControl.bufferValue = Float(timeInterval / totalDuration)
        }
        else if key == "playbackBufferEmpty"{
            status = .Buffering
            if !vActivity.isAnimating{
                vActivity.startAnimating()
            }
        }
        else if key == "playbackLikelyToKeepUp"{
            print("缓冲达到可播放")
            vActivity.stopAnimating()
            vPlay.isHidden = false
        }
        else if key == "rate"{
            if change![NSKeyValueChangeKey.newKey] as! Int == 0{
                isPlaying = false
                status = .Playing
            }
            else{
                isPlaying = true
                status = .Stopped
            }
        }
    }
    
    func addNotificationCenter()  {
        NotificationCenter.default.addObserver(self, selector: #selector(ShadowPlayerItemDidPlayToEndTimeNotification(notif:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
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
            format.dateFormat = "mm:ss"
        }
        return format.string(from: d)
    }
    
    
    func showErrorInfo(info:String)  {
        lblError.text = info
        vErrorVideo.isHidden = false
        vPlay.isHidden = true
        vActivity.stopAnimating()
    }
    
    func play()  {
        if self.player != nil{
            self.player.play()
            vPlay.btnImage.isSelected = true
        }
    }
    
    func pause() {
        if self.player != nil{
            self.player.pause()
            vPlay.btnImage.isSelected = false
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
        dataManager = nil
        lastToEndDownloader?.cancel()
        lastToEndDownloader = nil
        if let arr = nonToEndDownloaderArray{
            for downloader in arr{
                downloader.cancel()
            }
        }
    }
    
    func setSubViewsIsHide(isHide:Bool){
        vControl.isHidden = isHide
        vPlay.isHidden = isHide
        lblTitle.isHidden = isHide
        btnVideoInfo.isHidden = isHide
    }
    
    
    func interfaceOrientation(orientation:UIInterfaceOrientation)  {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        //有一些判断
        if orientation == .landscapeRight || orientation == .landscapeLeft{
            
        }else if orientation == .portrait{
            
        }else if orientation == .portraitUpsideDown{
            
        }
    }
    
    func getVideoInfo() -> [(String,String)]{
        var info = [(String,String)]()
        if url.absoluteString.starts(with: "file"){
            if let attr = try? FileManager.default.attributesOfItem(atPath: url.path){
                let size = attr[FileAttributeKey.size] as! Int
                info.append(("文件大小","\(size / 1000000)M"))
                info.append(("创建日期","\(attr[FileAttributeKey.creationDate]!)"))
                info.append(("扩展名",url.pathExtension))
            }
        }
        
        
        let assert = AVURLAsset(url: url)
        
        guard let a = assert.tracks.first?.formatDescriptions.first else{
            return info
        }
        
        let format = a as! CMFormatDescription
        
        let type = CMFormatDescriptionGetMediaType(format)
        if type == kCMMediaType_Video{
            info.append(("类型","视频"))
            guard let track = assert.tracks(withMediaType: .video).first else{
                return info
            }
            
            let res = track.naturalSize
            info.append(("分辨率","\(res.width) * \(res.height)"))
            info.append(("时长","\(track.timeRange.duration.seconds)秒"))
            info.append(("帧率","\(track.nominalFrameRate)帧每秒"))
            info.append(("码率","\(track.estimatedDataRate / 8000000) M每秒"))
        }
        else if type == kCMMediaType_Audio{
            info.append(("类型","音频"))
            guard let track = assert.tracks(withMediaType: .audio).first else{
                return info
            }
            info.append(("时长","\(track.timeRange.duration.seconds)秒"))
            info.append(("帧率","\(track.nominalFrameRate)帧每秒"))
            info.append(("码率","\(track.estimatedDataRate / 8000000) M每秒"))
        }
        return info
    }
    
    func clearCache(){
        
    }
}

extension ShadowPlayer:UIGestureRecognizerDelegate,ShadowControlViewDelegate{
    func controlView(view: ShadowControlView, pointSliderLocationWithCurrentValue: Float) {
        ShadowPlayer.count = 0
        let pointTime = CMTimeMake(Int64(pointSliderLocationWithCurrentValue) * Int64(item.currentTime().timescale), item.currentTime().timescale)
        item.seek(to: pointTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
    }
    
    func controlView(view: ShadowControlView, draggedPositionWithSlider: UISlider) {
        isDraging = true
        ShadowPlayer.count = 0
        let pointTime = CMTimeMake(Int64(view.value) * Int64(item.currentTime().timescale), item.currentTime().timescale)
        item.seek(to: pointTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func controlView(view: ShadowControlView, draggedPositionExitWithSlider: UISlider) {
        isDraging = false
    }
    
    func controlView(view: ShadowControlView, withLargeButton: UIButton) {
        ShadowPlayer.count = 0
        let ori = UIDevice.current.orientation
        if ori == .portrait || ori == .portraitUpsideDown{
            interfaceOrientation(orientation: .landscapeRight)
        }
        else if ori == .landscapeLeft || ori == .landscapeRight{
            interfaceOrientation(orientation: .portrait)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is ShadowControlView{
            return false
        }
        return true
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
        if currentVC == nil{
            currentVC = self.topMostController()
            if currentVC == nil{
                return
            }
        }
        
        let _interfaceOrientation = UIApplication.shared.statusBarOrientation
        switch _interfaceOrientation {
        case .landscapeLeft,.landscapeRight:
            isFullScreen = true
            if oldConstriants == nil{
                oldConstriants = currentVC!.view.constraints
            }
            vControl.updateConstraintsIfNeeded()
            //删除UIView animate可以去除横竖屏切换过渡动画
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
                UIApplication.shared.keyWindow?.addSubview(self)
                self.snp.makeConstraints({ (m) in
                    m.edges.equalTo(UIApplication.shared.keyWindow!)
                })
                self.layoutIfNeeded()
            }, completion: nil)
        case .portraitUpsideDown,.portrait:
            isFullScreen = false
            currentVC!.view.addSubview(self)
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: UIViewKeyframeAnimationOptions.calculationModeLinear, animations: {
                if self.oldConstriants != nil{
                    self.currentVC!.view.addConstraints(self.oldConstriants)
                }
                self.layoutIfNeeded()
            }, completion: nil)
        case .unknown:
            print("UIInterfaceOrientationUnknown")
            break
        }
    }
    @objc func willResignActive(notif:Notification)  {
        if isPlaying{
            setSubViewsIsHide(isHide: false)
            ShadowPlayer.count = 0
            pause()
            
        }
    }
}

extension ShadowPlayer:ShadowDataManagerDelegate,AVAssetResourceLoaderDelegate{
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        handleLoadingRequest(loadingRequest: loadingRequest)
        Log(message: "开始请求，当前位置\(loadingRequest.dataRequest!.currentOffset)---请求长度\(loadingRequest.dataRequest!.requestedLength)----请求偏移\(loadingRequest.dataRequest!.requestedOffset)")
        //Issue 目前对于测试视频来说，不会做分片请求，第二次就直接全部请求了。
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
*/
