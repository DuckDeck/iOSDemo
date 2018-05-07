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
class SoundRecordViewController: UIViewController {
    
    let btnRecord = UIButton()
    let btnStop = UIButton()
    let btnPlay = UIButton()
    let btnSave = UIButton()
    let vAni = RippleAnimtaionView(frame: CGRect(x: 20, y: 120, width: 50, height: 50))
    let lblTimer = UILabel()
    var timer:GrandTimer!
    
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    var soundFileURL: URL!
    var recordTime = TimeSpan.fromSeconds(0){
        didSet{
            if recordTime == TimeSpan.fromSeconds(0){
                lblTimer.text = recordTime.format(format: "mm:ss")
                
            }
            else{
                let rt = recordTime.minus(TimeSpan.fromSeconds(1))
                lblTimer.text = rt.format(format: "mm:ss")
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromSeconds(1), target: self, sel: #selector(tick), userInfo: nil, repeats: true, dispatchQueue: DispatchQueue.main)
        //真神奇，返回时APP会挂，不知道为什么，我全部把代码注释还会这样，但是另一个测试的不会挂，这就奇怪了
        //这个问题目前没有解，我只能加一个暂停的标记来修正这个问题
        setSessionPlayAndRecord()
        askForNotifications()
        checkHeadphones()
    }
    
    func initView() {
        let btnNav = UIBarButtonItem(title: "已有录音", style: .plain, target: self, action: #selector(gotoRecordList))
        navigationItem.rightBarButtonItem = btnNav
        btnRecord.setTitleColor(UIColor.lightGray, for: .disabled)
        btnRecord.title(title: "开始录音").color(color: UIColor.purple).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.height.equalTo(30)
            m.top.equalTo(80)
            m.left.equalTo(10)
            m.width.equalTo(100)
        }
        btnRecord.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        
        btnStop.setTitleColor(UIColor.lightGray, for: .disabled)
        btnStop.isEnabled = false
        btnStop.title(title: "停止录音").color(color: UIColor.purple).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(btnRecord.snp.right).offset(20)
            m.width.equalTo(100)
            m.height.equalTo(30)
            m.top.equalTo(80)
        }
        btnStop.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        
        btnPlay.isEnabled = false
        btnPlay.setTitleColor(UIColor.lightGray, for: .disabled)
        btnPlay.title(title: "开始播放").color(color: UIColor.purple).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(btnStop.snp.right).offset(20)
            m.width.equalTo(100)
            m.height.equalTo(30)
            m.top.equalTo(80)
        }
        btnPlay.addTarget(self, action: #selector(playRecord), for: .touchUpInside)
        
        btnSave.title(title: "保存到媒体").color(color: UIColor.purple).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.right.equalTo(-20)
            m.width.equalTo(100)
            m.height.equalTo(30)
            m.top.equalTo(140)
        }
        btnSave.addTarget(self, action: #selector(saveToAlbum), for: .touchUpInside)
        
        vAni.isHidden = true
        view.addSubview(vAni)
        
        lblTimer.text(text: "00:00").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(90)
            m.top.equalTo(140)
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
            btnRecord.setTitle("暂停录音", for: .normal)
            btnStop.isEnabled = true
            recordWithPermission(setup: true)
            return
        }
        if recorder != nil && recorder.isRecording{
            Log(message: "record is recording need pause")
            recorder.pause()
            timer.pause()
            vAni.isHidden = true
            btnRecord.setTitle("继续录音", for: .normal)
        }
        else{
            Log(message: "record is need proceed")
            vAni.isHidden = false
            btnRecord.setTitle("暂停录音", for: .normal)
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
    
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
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
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        let  documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url:  '\(soundFileURL)'")
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString){
            print("soundfile url:  '\(soundFileURL)' exists")
        }
        let recordSettings:[String:Any] = [AVFormatIDKey:kAudioFormatAppleLossless,
                                           AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue,
                                           AVEncoderBitRateKey:32000,
                                           AVNumberOfChannelsKey:2,
                                           AVSampleRateKey:44100.0]
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
        recordTime =  recordTime.add(TimeSpan.fromSeconds(1))
    }
    
    @objc func stopRecord()  {
        Log(message: "Stop record")
        recorder?.stop()
        player?.stop()
        recordTime = TimeSpan.fromSeconds(0)
        vAni.isHidden = true
        timer.invalidate()
        btnRecord.setTitle("开始录音", for: .normal)
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
            btnPlay.setTitle("继续播放", for: .normal)
            player.pause()
        }
        else if player != nil && btnPlay.title(for: .normal)! == "继续播放"{
            player.play()
        }
        else{
            
            do{
                btnPlay.setTitle("暂停播放", for: .normal)
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
            let startTime = CMTimeMake(0, 1)
            let stopTime = CMTimeMake(5, 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            exporter.exportAsynchronously(completionHandler: {
                print("export complete \(exporter.status)")
                
                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:
                    
                    if let e = exporter.error {
                        print("export failed \(e)")
                    }
                    
                case AVAssetExportSessionStatus.cancelled:
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
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SoundRecordViewController.foreground(_:)),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SoundRecordViewController.routeChange(_:)),
                                               name: NSNotification.Name.AVAudioSessionRouteChange,
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
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
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
                if description.portType == AVAudioSessionPortHeadphones {
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
}











extension SoundRecordViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Log(message: "finished recording \(flag)")
        btnStop.isEnabled = false
        btnPlay.isEnabled = true
        btnRecord.setTitle("开始录音", for: .normal)
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
