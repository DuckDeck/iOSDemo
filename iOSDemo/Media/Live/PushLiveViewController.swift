//
//  PushLiveViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/5/7.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import LFLiveKit

class PushLiveViewController: UIViewController {

    
    
    var debugInfo:LFLiveDebug?
    let lblStatus = UILabel()
    var isRunning = false
    var btnPlay:UIButton?
    lazy var session:LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.init()
        audioConfiguration.numberOfChannels = 2
        audioConfiguration.audioBitrate = LFLiveAudioBitRate._128Kbps
        audioConfiguration.audioSampleRate = LFLiveAudioSampleRate._44100Hz
        
        let videoConfiguration = LFLiveVideoConfiguration.init()
        videoConfiguration.videoSize = CGSize(width: 720, height: 1280)
        videoConfiguration.videoBitRate = 800 * 1024
        videoConfiguration.videoMaxBitRate = 1000 * 1024
        videoConfiguration.videoMinBitRate = 500 * 1024
        videoConfiguration.videoFrameRate = 15
        videoConfiguration.videoMaxKeyframeInterval = 30
        videoConfiguration.sessionPreset = LFLiveVideoSessionPreset.captureSessionPreset720x1280
      
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session?.delegate = self
        session?.preView = self.view
        session?.showDebugInfo = true
        return session!
    }()
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLive()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        
        authVideo()
        authAudio()
        
        
        lblStatus.backgroundColor = UIColor(gray: 0.6, alpha: 0.6)
        lblStatus.textColor = UIColor.white
        view.addSubview(lblStatus)
        
        lblStatus.snp.makeConstraints { (m) in
            m.right.equalTo(-10)
            m.top.equalTo(100)
        }
        btnPlay = UIButton(type: .custom)
        btnPlay?.setTitle("准备直播", for: .normal)
        btnPlay?.setTitleColor(UIColor.blue, for: .normal)
        btnPlay?.addTarget(self, action: #selector(startLive), for: .touchUpInside)
        let btnNav = UIBarButtonItem(customView: btnPlay!)
        navigationItem.rightBarButtonItem = btnNav
    }
    
   
    func authVideo() {
        let status = Auth.isAuthCamera()
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Video)
        case .notDetermined:
            Auth.authCamera { (res) in
                if(res){
                    self.startLive()
                }
                else{
                    Toast.showToast(msg: "摄像头授权失败")
                }
            }
        
        default:
            break
        }
    }
    
    func authAudio() {
        let status = Auth.isAuthMicrophone()
        
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Audio)
        case .notDetermined:
            Auth.authMicrophone { (res) in
                if(res){
                    self.startLive()
                }
                else{
                    Toast.showToast(msg: "麦克风授权失败")
                }
            }
            
        default:
            break
        }
    }
    
    @objc func startLive()  {
        let steam = LFLiveStreamInfo()
        steam.url = "rtmp://144.34.157.61:1935/mylive/44"
        session.startLive(steam)
    }
    
    func stopLive() {
        session.stopLive()
    }
    
}

extension PushLiveViewController:LFLiveSessionDelegate{
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        if let info = debugInfo{
            print(info)
        }
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print(errorCode.rawValue)
        isRunning = false
        btnPlay?.setTitle("开始直播", for: .normal)
    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
       
        print("liveStateDidChange\(state.rawValue)")
        
        switch state {
        case .ready:
            lblStatus.text = "未接连"
            isRunning = false
            btnPlay?.setTitle("开始直播", for: .normal)
        case .pending:
            lblStatus.text = "接连中....."
        case .start:
            lblStatus.text = "已接连"
        case .error:
            lblStatus.text = "接连错误"
            isRunning = false
            btnPlay?.setTitle("开始直播", for: .normal)
        case .stop:
            lblStatus.text = "已断开"
            isRunning = false
            btnPlay?.setTitle("开始直播", for: .normal)
        default:
            break
        }
    }
}
