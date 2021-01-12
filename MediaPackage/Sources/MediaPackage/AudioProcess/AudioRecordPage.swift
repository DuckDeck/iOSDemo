//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/12.
//

import UIKit
import SnapKit
import AVFoundation
import GrandTime
import CommonLibrary
import SwiftUI
class AudioRecordViewController: UIViewController {
    
    let btnRecord = UIButton()
    let btnStop = UIButton()
    let btnPlay = ProgressButton()
    let btnSave = UIButton()
    let vAni = RippleAnimtaionView(frame: CGRect(x: ScreenWidth / 2 - 30, y: ScreenHeight - 100, width: 60, height: 60)) //这个色后面再改改
    let lblTimer = UILabel()
    var timer:GrandTimer!
    let vPlayNetAudio = UIView()
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var soundFileURL: URL!
    var audioPlayView:ShadowAudioPlayerView?

    
    private var vWave: VolumeView!
    private var soundMeters =  [Float].init(repeating: -42, count: 38)
    private let updateFequency = 0.05
    private let soundMeterCount = 40
    private var recordingTime = 0.00
    
    var recordTime = TimeSpan.fromSeconds(0){
        didSet{
            lblTimer.text = recordTime.format(format: "mm:ss")
//            if recordTime == TimeSpan.fromSeconds(0){
//                lblTimer.text = recordTime.format(format: "mm:ss")
//
//            }
//            else{
//                let rt = recordTime - TimeSpan.fromSeconds(1)
//                lblTimer.text = rt.format(format: "mm:ss")
//            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromTicks(50), target: self, sel: #selector(tick), userInfo: nil, repeats: true, dispatchQueue: DispatchQueue.main)
        //真神奇，返回时APP会挂，不知道为什么，我全部把代码注释还会这样，但是另一个测试的不会挂，这就奇怪了
        //这个问题目前没有解，我只能加一个暂停的标记来修正这个问题
       
       
        setSessionPlayAndRecord()
        askForNotifications()
        checkHeadphones()
        
    }
    
    func initView() {
        let btnNetAudio = UIBarButtonItem(title: "网络音频", style: .plain, target: self, action: #selector(gotoNetAudio))
        
        let btnNav = UIBarButtonItem(title: "已有录音", style: .plain, target: self, action: #selector(gotoRecordList))
        navigationItem.rightBarButtonItems = [btnNetAudio,btnNav]
        
        vWave = VolumeView(frame: CGRect(x: 0, y: 400, w: ScreenWidth, h: 100), type: .bar)
        vWave.barGap = 8
        vWave.barWidth = 2
        view.addSubview(vWave)

        
        vAni.isHidden = true
        view.addSubview(vAni)
        btnRecord.setImage(#imageLiteral(resourceName: "btn_recording_audio"), for: .normal)
        btnRecord.setImage(#imageLiteral(resourceName: "btn_pause_recording_audio"), for: .selected)
        btnRecord.addTo(view: view).snp.makeConstraints { (m) in
            m.bottom.equalTo(-100)
            m.centerX.equalTo(view)
            m.width.height.equalTo(80)
        }
        btnRecord.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        

        btnStop.setTitleColor(UIColor.lightGray, for: .disabled)
        btnStop.isEnabled = false
        btnStop.title(title: "停止录音").color(color: UIColor.purple).setFont(font: 16).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.top.equalTo(btnRecord.snp.bottom).offset(30)
        }
        
        btnStop.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        
        btnPlay.tintColor = UIColor.blue
        btnPlay.bgTintColor = UIColor.lightGray
        btnPlay.lineWidth = 2
        btnPlay.isEnabled = false
        btnPlay.setImage(#imageLiteral(resourceName: "btn_play_small"), for: .normal)
        btnPlay.setImage(#imageLiteral(resourceName: "btn_play_small_disable"), for: .disabled)
        btnPlay.setImage(#imageLiteral(resourceName: "btn_pause_small"), for: .selected)
        btnPlay.addTo(view: view).snp.makeConstraints { (m) in
            m.centerY.equalTo(btnRecord)
            m.centerX.equalTo(ScreenWidth * 0.80)
        }
        btnPlay.addTarget(self, action: #selector(playRecord), for: .touchUpInside)
        
        btnSave.title(title: "保存到媒体").color(color: UIColor.purple).setFont(font: 16).addTo(view: view).snp.makeConstraints { (m) in
            m.centerY.equalTo(btnRecord)
            m.centerX.equalTo(ScreenWidth * 0.20)
        }
        btnSave.addTarget(self, action: #selector(saveToAlbum), for: .touchUpInside)
        
       
        
        lblTimer.text(text: "00:00").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.bottom.equalTo(btnRecord.snp.top).offset(-20)
            m.centerX.equalTo(view)
        }
        
        vPlayNetAudio.backgroundColor = UIColor(gray: 0.5, alpha: 0.3)
        vPlayNetAudio.isHidden = true
        view.addSubview(vPlayNetAudio)
        vPlayNetAudio.snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        vPlayNetAudio.isUserInteractionEnabled = true
        vPlayNetAudio.addTapGesture { (ges) in
            self.removeNetAudio()
        }
    }
   
    @objc func gotoRecordList() {
        navigationController?.pushViewController(RecordListViewController(), animated: true)
    }
    
    @objc func gotoNetAudio(){
        let url = "https://lovelive.ink:19996/file/1593677674plants.mp3"
        let playAudio = ShadowAudioPlayerView(frame: CGRect(x: 10, y: 300, w: ScreenWidth - 20, h: 50), url: URL(string: url)!)
        self.audioPlayView = playAudio
        vPlayNetAudio.addSubview(playAudio)
        audioPlayView?.backgroundColor = UIColor.white
        vPlayNetAudio.isHidden = false
    }
    func removeNetAudio() {
        audioPlayView?.stop()
        audioPlayView?.removeFromSuperview()
        audioPlayView = nil
        vPlayNetAudio.isHidden = true
    }
    
    @objc func startRecord()  {
        if player != nil && player.isPlaying{
            Log(message: "player is playing")
            player.stop()
        }
        if recorder == nil{
            Log(message: "record is nil, init record")
            vAni.isHidden = false
            btnRecord.isSelected = true
            btnStop.isEnabled = true
            recordWithPermission(setup: true)
            return
        }
        if recorder != nil && recorder.isRecording{
            Log(message: "record is recording need pause")
            recorder.pause()
            timer.pause()
            vAni.isHidden = true
            btnRecord.isSelected = false
        }
        else{
            Log(message: "record is need proceed")
            vAni.isHidden = false
            btnRecord.isSelected = true
            btnStop.isEnabled = true
            recordWithPermission(setup: false)
        }
    }
    
    func recordWithPermission(setup:Bool)  {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self](granted) in
            if granted{
                DispatchQueue.main.async {
                    Log(message: "Permisson to record granted")
                    self?.setSessionPlayAndRecord()
                    if setup{
                        self?.setupRecorder()
                    }
                    self?.recorder.record()
                    self?.timer.fire()
                }
            }
        }
    }
    
    
    
    

    
    private func addSoundMeter(item: Float) {
        print(item)
        if soundMeters.count < soundMeterCount {
            soundMeters.append(item)
        } else {
            for (index, _) in soundMeters.enumerated() {
                if index < soundMeterCount - 1 {
                    soundMeters[index] = soundMeters[index + 1]
                }
            }
            // 插入新数据
            soundMeters[soundMeterCount - 1] = item
            NotificationCenter.default.post(name: NSNotification.Name.init("updateMeters"), object: soundMeters)
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do{
            
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        }
        catch{
            Log(message: "could not set session category")
            Log(message: error.localizedDescription)
        }
        do{
            try session.setActive(true)
        }
        catch{
            Log(message: "could not make session active")
            Log(message: error.localizedDescription)
        }
    }
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).caf"
        let  documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentDirectory.appendingPathComponent(currentFileName)
     
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString){
            print("soundfile url:  '\(soundFileURL.absoluteString)' exists")
        }
        let recordSettings:[String:Any] = [AVFormatIDKey : NSNumber(value: kAudioFormatLinearPCM),
                                           AVSampleRateKey : NSNumber(value: 11025.0),
                                           AVNumberOfChannelsKey : NSNumber(value: 2),
                                           AVEncoderBitDepthHintKey : NSNumber(value: 16),
                                           AVEncoderAudioQualityKey : NSNumber(value: AVAudioQuality.high.rawValue)]
        do{
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        }
        catch{
            Log(message: error.localizedDescription)
            recorder = nil
        }
    }
    
    @objc func tick()  {
        Log(message: recordTime)
        recordTime =  recordTime.add(TimeSpan.fromTicks(50))
        recorder.updateMeters()
        recordingTime += updateFequency
        addSoundMeter(item: recorder.averagePower(forChannel: 0))
    }
    
    @objc func stopRecord()  {
        Log(message: "Stop record")
        recorder?.stop()
        player?.stop()
        recordTime = TimeSpan.fromSeconds(0)
        vAni.isHidden = true
        timer.invalidate()
        btnRecord.isSelected = false
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setActive(false)
            btnStop.isEnabled = false
        }
        catch{
            Log(message: "Could not make session inactive")
            Log(message: error.localizedDescription)
        }
    }
    
    @objc func playRecord()  {
        Log(message: "Play Audio")
        var url:URL?
        if self.recorder != nil{
            url = recorder.url
        }
        else{
            url = soundFileURL
        }
        Log(message: "url:\(url!.absoluteString)")
        
        if player != nil && player.isPlaying{
            btnPlay.isSelected = false
            player.pause()
        }
        else if player != nil && btnPlay.isSelected{
            player.play()
        }
        else{
            
            do{
                btnPlay.isSelected = true
                player = try AVAudioPlayer(contentsOf: url!)
                btnStop.isEnabled = true
                player.delegate = self
                player.prepareToPlay()
                player.volume = 1.0
                player.play()
                
            }
            catch{
                player = nil
                Log(message: error.localizedDescription)
            }
        }
        
    }
    
    @objc func saveToAlbum() {
        if self.soundFileURL == nil {
            print("no sound file")
            return
        }
        
        print("trimming \(soundFileURL!.absoluteString)")
        print("trimming path \(soundFileURL!.lastPathComponent)")
        let asset = AVAsset(url: self.soundFileURL!)
        exportAsset(asset, fileName: "trimmed.m4a")
    }
    
    func exportAsset(_ asset: AVAsset, fileName: String) {
        print("\(#function)")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
            do {
                if try trimmedSoundFileURL.checkResourceIsReachable() {
                    print("is reachable")
                }
                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
            } catch {
                print("could not remove \(trimmedSoundFileURL)")
                print(error.localizedDescription)
            }
        }
        
        print("creating export session for \(asset)")
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = trimmedSoundFileURL
            
            let duration = CMTimeGetSeconds(asset.duration)
            if duration < 5.0 {
                print("sound is not long enough")
                return
            }
            // e.g. the first 5 seconds
            let startTime = CMTimeMake(value: 0, timescale: 1)
            let stopTime = CMTimeMake(value: 5, timescale: 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
            exporter.exportAsynchronously(completionHandler: {
                print("export complete \(exporter.status)")
                
                switch exporter.status {
                case  AVAssetExportSession.Status.failed:
                    
                    if let e = exporter.error {
                        print("export failed \(e)")
                    }
                    
                case AVAssetExportSession.Status.cancelled:
                    print("export cancelled \(String(describing: exporter.error))")
                default:
                    print("export complete")
                }
            })
        } else {
            print("cannot create AVAssetExportSession for asset \(asset)")
        }
        
    }
    
    
    func askForNotifications() {
        print("\(#function)")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AudioRecordViewController.background(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AudioRecordViewController.foreground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AudioRecordViewController.routeChange(_:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }
    
    
    
    
    @objc func background(_ notification: Notification) {
        print("\(#function)")
        
    }
    
    @objc func foreground(_ notification: Notification) {
        print("\(#function)")
        
    }
    
    
    @objc func routeChange(_ notification: Notification) {
        print("\(#function)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            print("routeChange \(userInfo)")
            
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSession.RouteChangeReason(rawValue: reason)! {
                case AVAudioSession.RouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSession.RouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSession.RouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSession.RouteChangeReason.override:
                    print("Override")
                case AVAudioSession.RouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSession.RouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSession.RouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSession.RouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        print("\(#function)")
        
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if !currentRoute.outputs.isEmpty {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSession.Port.headphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnPlay.isEnabled = false
    }
}











extension AudioRecordViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Log(message: "finished recording \(flag)")
        btnStop.isEnabled = false
        btnPlay.isEnabled = true
        btnPlay.maxValue = recordTime.totalSeconds
        btnRecord.isSelected = false
        timer.invalidate()
        UIAlertController.title(title: "录音器", message: "录音已经结束").action(title: "保存", handle: {(action:UIAlertAction) in
            self.recorder = nil
        }).action(title: "删除", handle: {(action:UIAlertAction) in
            self.recorder.deleteRecording()
        }).show()
    }
}





extension AudioRecordViewController:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Log(message: "finished playing(\(flag)")
        btnRecord.isEnabled = true
        btnStop.isEnabled = false
        btnPlay.setTitle("开始播放", for: .normal)
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error{
            Log(message: e.localizedDescription)
        }
    }
}


class RippleAnimtaionView: UIView {

    var multiple:Double = 1.423
    let pulsingCount = 4
    let animationDuration = 2.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let animationLayer = CALayer()
        // 新建缩放动画
        //let animation = scaleAnimation
        // 新建一个动画 Layer，将动画添加上去
        //let layer = pulsingLayer(rect: rect, animation: animation)
        //animationLayer.addSublayer(layer)
        //将动画 Layer 添加到 animationLayer
        
        
        
        // 这里同时创建[缩放动画、背景色渐变、边框色渐变]三个简单动画
//        let arrAnimations = groupAnimations(arr: arrAnimraion)
//        let layer = pulsingLayer(rect: rect, animationGroup: arrAnimations)
//        animationLayer.addSublayer(layer)
        
        // 利用 for 循环创建三个动画 Layer
        for i in 0..<pulsingCount{
            let group = groupAnimations(arr: arrAnimraion, index: i)
            let layer = pulsingLayer(rect: rect, animationGroup: group)
            layer.borderColor = UIColor.clear.cgColor
            animationLayer.addSublayer(layer)
        }
        
        self.layer.addSublayer(animationLayer)
    }
    
    
    var arrAnimraion:[CAAnimation]{
        get{
            
            let scale = scaleAnimation
            let backgroundColor = backgroundColorAnimation
            let borderColor = borderColorAnimation
            let arr:[CAAnimation] = [scale,backgroundColor,borderColor]
            return arr
        }
    }
    
    func groupAnimations(arr:[CAAnimation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 3
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
        return group
    }
    
    func groupAnimations(arr:[CAAnimation],index:Int) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime() + index * animationDuration / pulsingCount
        group.duration = CFTimeInterval(animationDuration)
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
         // 添加动画曲线。关于其他的动画曲线，也可以自行尝试
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        return group
    }
    
    var scaleAnimation:CABasicAnimation{
        get{
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = 1
            scale.toValue = multiple
//            scale.beginTime = CACurrentMediaTime()
//            scale.duration = 3
//            scale.repeatCount = Float.infinity
            return scale
        }
    }
    
    var backgroundColorAnimation:CAKeyframeAnimation{
        get{
            let ani = CAKeyframeAnimation()
            ani.keyPath = "backgroundColor"
            let color1 = UIColor(red: 255.0/255.0, green: 216.0/255.0, blue: 87.0/255.0, alpha: 0.5).cgColor
            let color2 = UIColor(red: 255.0/255.0, green: 231.0/255.0, blue: 152.0/255.0, alpha: 0.5).cgColor
            let color3 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0.5).cgColor
            let color4 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0).cgColor
            ani.values = [color1,color2,color3,color4]
            ani.keyTimes = [0.3,0.6,0.9,1]
            return ani
        }
    }
    
    var borderColorAnimation:CAKeyframeAnimation{
        get{
            let ani = CAKeyframeAnimation()
            ani.keyPath = "borderColor"
            let color1 = UIColor(red: 255.0/255.0, green: 216.0/255.0, blue: 87.0/255.0, alpha: 0.5).cgColor
            let color2 = UIColor(red: 255.0/255.0, green: 231.0/255.0, blue: 152.0/255.0, alpha: 0.5).cgColor
            let color3 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0.5).cgColor
            let color4 = UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 197.0/255.0, alpha: 0).cgColor
            ani.values = [color1,color2,color3,color4]
            ani.keyTimes = [0.3,0.6,0.9,1]
            return ani
        }
    }
    
    func pulsingLayer(rect:CGRect,animation:CABasicAnimation) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animation, forKey: "pulsing")
        return pulsingLayer
    }
    
    func pulsingLayer(rect:CGRect,animationGroup:CAAnimationGroup) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animationGroup, forKey: "pulsing")
        return pulsingLayer
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class RippleAnimtaionView2: UIView {
    
    var multiple:Double = 1.423
    let pulsingCount = 4
    let animationDuration = 2.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let animationLayer = CALayer()
        // 新建缩放动画
        //let animation = scaleAnimation
        // 新建一个动画 Layer，将动画添加上去
        //let layer = pulsingLayer(rect: rect, animation: animation)
        //animationLayer.addSublayer(layer)
        //将动画 Layer 添加到 animationLayer
        
        
        
        // 这里同时创建[缩放动画、背景色渐变、边框色渐变]三个简单动画
        //        let arrAnimations = groupAnimations(arr: arrAnimraion)
        //        let layer = pulsingLayer(rect: rect, animationGroup: arrAnimations)
        //        animationLayer.addSublayer(layer)
        
        // 利用 for 循环创建三个动画 Layer
        for i in 0..<pulsingCount{
            let group = groupAnimations(arr: arrAnimraion, index: i)
            let layer = pulsingLayer(rect: rect, animationGroup: group)
            layer.borderColor = UIColor.clear.cgColor
            animationLayer.addSublayer(layer)
        }
        
        self.layer.addSublayer(animationLayer)
    }
    
    
    var arrAnimraion:[CAAnimation]{
        get{
            
            let scale = scaleAnimation
            let borderColor = borderColorAnimation
            let arr:[CAAnimation] = [scale,borderColor]
            return arr
        }
    }
    
    func groupAnimations(arr:[CAAnimation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 3
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
        return group
    }
    
    func groupAnimations(arr:[CAAnimation],index:Int) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime() + index * animationDuration / pulsingCount
        group.duration = CFTimeInterval(animationDuration)
        group.repeatCount = Float.infinity
        group.animations = arr
        group.isRemovedOnCompletion = false
        // 添加动画曲线。关于其他的动画曲线，也可以自行尝试
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        return group
    }
    
    var scaleAnimation:CABasicAnimation{
        get{
            let scale = CABasicAnimation(keyPath: "transform.scale")
            scale.fromValue = 1
            scale.toValue = multiple
            //            scale.beginTime = CACurrentMediaTime()
            //            scale.duration = 3
            //            scale.repeatCount = Float.infinity
            return scale
        }
    }
    
    
    var borderColorAnimation:CAKeyframeAnimation{
        get{
            let ani = CAKeyframeAnimation()
            ani.keyPath = "borderColor"
            let color1 = UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 0.5).cgColor
            let color2 = UIColor(red: 99.0/255.0, green: 99.0/255.0, blue: 99.0/255.0, alpha: 0.5).cgColor
            let color3 = UIColor(red: 145.0/255.0, green: 145.0/255.0, blue: 145.0/255.0, alpha: 0.5).cgColor
            let color4 = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 0).cgColor
            ani.values = [color1,color2,color3,color4]
            ani.keyTimes = [0.3,0.6,0.9,1]
            return ani
        }
    }
    
    func pulsingLayer(rect:CGRect,animation:CABasicAnimation) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animation, forKey: "pulsing")
        return pulsingLayer
    }
    
    func pulsingLayer(rect:CGRect,animationGroup:CAAnimationGroup) -> CALayer {
        let pulsingLayer = CALayer()
        pulsingLayer.borderWidth = 0.5
        pulsingLayer.borderColor = UIColor.black.cgColor
        pulsingLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        pulsingLayer.cornerRadius = rect.size.height / 2
        pulsingLayer.add(animationGroup, forKey: "pulsing")
        return pulsingLayer
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
struct AudioRecordDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = AudioRecordViewController
    
    func makeUIViewController(context: Context) -> AudioRecordViewController {
        return AudioRecordViewController()
    }
}


