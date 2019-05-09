//
//  LivePreview.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/5/9.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import LFLiveKit
class LivePreview: UIView {

    var isRunning = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       backgroundColor = UIColor.clear
        
        
        authVideo()
        authAudio()
        
        session.delegate = self
        session.preView = self
        session.showDebugInfo = false
        
        addSubview(vContainer)
        vContainer.addSubview(lblStatus)
        vContainer.addSubview(btnClose)
        vContainer.addSubview(btnBeauty)
        vContainer.addSubview(btnCamera)
        vContainer.addSubview(btnStartLive)
        
        btnCamera.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        btnBeauty.addTarget(self, action: #selector(switchBeauty), for: .touchUpInside)
        btnStartLive.addTarget(self, action: #selector(startLive), for: .touchUpInside)
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close()  {
        self.viewContainingController()?.navigationController?.popViewController(animated: true)
        session.stopLive()
        session.running = false
    }
    
    
    func authVideo() {
        let status = Auth.isAuthCamera()
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self.viewContainingController()!, authTpye: .Video)
        case .notDetermined:
            Auth.authCamera { (res) in
                if(res){
                    self.session.running = true
                }
                else{
                    Toast.showToast(msg: "摄像头授权失败")
                }
            }
            
        default:
            self.session.running = true
        }
        
    }
    
    func authAudio() {
        let status = Auth.isAuthMicrophone()
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self.viewContainingController()!, authTpye: .Audio)
        case .notDetermined:
            Auth.authMicrophone { (res) in
                if(res){
                    self.session.running = true
                }
                else{
                    Toast.showToast(msg: "麦克风授权失败")
                }
            }
        default:
            self.session.running = true
        }
    }
    
    
    @objc func startLive()  {
        btnStartLive.isSelected = !btnStartLive.isSelected
        if btnStartLive.isSelected{
            let steam = LFLiveStreamInfo()
            steam.url = "rtmp://144.34.157.61:1935/mylive/44"
            session.startLive(steam)
        }
        else{
            stopLive()
        }
        
    }
    
    func stopLive() {
        session.stopLive()
    }
    
    @objc func switchCamera(){
        let position = session.captureDevicePosition
        session.captureDevicePosition = (position == .back) ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
      
    }
    
    @objc func switchBeauty(){
        session.beautyFace = !session.beautyFace
        btnBeauty.isSelected = !btnBeauty.isSelected
    }
    
    
    var session:LFLiveSession = {
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
        videoConfiguration.outputImageOrientation = UIInterfaceOrientation.portrait
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        
       
        
        return session!
    }()
    
    
    var vContainer: UIView = {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        containerView.backgroundColor = UIColor.clear
        containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleHeight]
        return containerView
    }()
    
    var lblStatus: UILabel = {
        let stateLabel = UILabel(frame: CGRect(x: 20, y: 30, width: 80, height: 40))
        stateLabel.text = "未连接"
        stateLabel.textColor = UIColor.white
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        return stateLabel
    }()
    
    
    var btnClose: UIButton = {
        let closeButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 10 - 44, y: 30, width: 44, height: 44))
        closeButton.setImage(UIImage(named: "close_preview"), for: .normal)
        return closeButton
    }()
    
    var btnCamera: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54 * 2, y: 30, width: 44, height: 44))
        cameraButton.setImage(UIImage(named: "camra_preview"), for: .normal)
        return cameraButton
    }()
    
    var btnBeauty: UIButton = {
        let beautyButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 54 * 3, y: 30, width: 44, height: 44))
        beautyButton.setImage(UIImage(named: "camra_beauty"), for: .selected)
        beautyButton.setImage(UIImage(named: "camra_beauty_close"), for: .normal)
        return beautyButton
    }()
    
    
    var btnStartLive: UIButton = {
        let startLiveButton = UIButton(frame: CGRect(x: 30, y: ScreenHeight - 80, width: UIScreen.main.bounds.width - 10 - 44, height: 44))
        startLiveButton.layer.cornerRadius = 22
        startLiveButton.setTitleColor(UIColor.black, for:.normal)
        startLiveButton.setTitle("开始直播", for: .normal)
        startLiveButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
        startLiveButton.backgroundColor = UIColor.lightGray
        return startLiveButton
    }()
    
}


extension LivePreview:LFLiveSessionDelegate{
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        if let info = debugInfo{
            print(info)
        }
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print(errorCode.rawValue)
        isRunning = false
        btnStartLive.setTitle("开始直播", for: .normal)
    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        
        print("liveStateDidChange\(state.rawValue)")
        
        switch state {
        case .ready:
            lblStatus.text = "未接连"
            isRunning = false
            btnStartLive.setTitle("开始直播", for: .normal)
        case .pending:
            lblStatus.text = "接连中....."
        case .start:
            lblStatus.text = "已接连"
            btnStartLive.setTitle("正在直播", for: .normal)
        case .error:
            lblStatus.text = "接连错误"
            isRunning = false
            btnStartLive.setTitle("开始直播", for: .normal)
        case .stop:
            lblStatus.text = "已断开"
            isRunning = false
            btnStartLive.setTitle("开始直播", for: .normal)
        default:
            break
        }
    }
}
