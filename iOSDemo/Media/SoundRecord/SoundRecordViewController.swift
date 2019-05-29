//
//  SoundRecordViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 12/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import GrandTime
class SoundRecordViewController: UIViewController {
    
    let btnRecord = UIButton()
    let btnStop = UIButton()
    let btnPlay = ProgressButton()
    let btnSave = UIButton()
    let vAni = RippleAnimtaionView(frame: CGRect(x: ScreenWidth / 2 - 30, y: ScreenHeight - 100, width: 60, height: 60)) //这个色后面再改改
    let lblTimer = UILabel()
    var timer:GrandTimer!
    
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var soundFileURL: URL!
    

    
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
        let btnNav = UIBarButtonItem(title: "已有录音", style: .plain, target: self, action: #selector(gotoRecordList))
        navigationItem.rightBarButtonItem = btnNav
        
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
        
    }
   
    @objc func gotoRecordList() {
        navigationController?.pushViewController(RecordListViewController(), animated: true)
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
                                               selector: #selector(SoundRecordViewController.background(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SoundRecordViewController.foreground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SoundRecordViewController.routeChange(_:)),
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











extension SoundRecordViewController:AVAudioRecorderDelegate{
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





extension SoundRecordViewController:AVAudioPlayerDelegate{
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

