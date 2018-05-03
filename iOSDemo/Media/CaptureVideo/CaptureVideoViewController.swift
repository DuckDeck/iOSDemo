//
//  CaptureVideoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
class CaptureVideoViewController: UIViewController {

    let btnSwitchCamera = UIButton()
    let btnStartRecord = UIButton()
    let btnStopRecord = UIButton()
    let imgVideo = UIImageView()
    var currentCamera = CaptureCamera.BackCamera
    var session:CaptureSession?
    var isVideoOK = false
    var isAudioOK = false
    var isRecoding = false

   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
      
        view.addSubview(imgVideo)
        imgVideo.snp.makeConstraints { (m) in
            m.left.top.equalTo(0)
            m.width.equalTo(ScreenWidth)
            m.height.equalTo(ScreenHeight * 0.7)
        }
        
        btnStartRecord.title(title: "开始采集").color(color: UIColor.darkGray).addTo(view: view).completed()
        btnStartRecord.snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.bottom.equalTo(-10)
            m.width.equalTo(100)
            m.height.equalTo(30)
        }
        btnStartRecord.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        
        
//        btnStopRecord.title(title: "暂停采集").color(color: UIColor.darkGray).addTo(view: view).completed()
//        btnStopRecord.isEnabled = false
//        btnStopRecord.snp.makeConstraints { (m) in
//            m.left.equalTo(130)
//            m.bottom.equalTo(-10)
//            m.width.equalTo(100)
//            m.height.equalTo(30)
//        }
       // btnStopRecord.addTarget(self, action: #selector(pauseRecord), for: .touchUpInside)
        
        btnSwitchCamera.title(title: "后置").color(color: UIColor.darkGray).addTo(view: view).completed()
      
        btnSwitchCamera.snp.makeConstraints { (m) in
            m.left.equalTo(btnStartRecord.snp.right).offset(30)
            m.bottom.equalTo(-10)
            m.width.equalTo(200)
            m.height.equalTo(39)
        }
        
        btnSwitchCamera.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
      
        
        let btnBar = UIBarButtonItem(title: "已有视频", style: .plain, target: self, action: #selector(gotoAlreadyExistVideo))
        navigationItem.rightBarButtonItem = btnBar
        checkAudioAuth()
        checkVideoAuth()
        prepareRecord()
    }
    
    @objc func gotoAlreadyExistVideo()  {
        
    }
    
    
    func checkVideoAuth()  {
        let res = AVCaptureDevice.authorizationStatus(for: .video)
        switch res {
            case .authorized:
                isVideoOK = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: {[weak self] (granted) in
                    self?.isVideoOK = granted
                    if !granted{
                        Auth.showEventAccessDeniedAlert(view: self!, authTpye: .Video)
                    }
                })

            default:
                Auth.showEventAccessDeniedAlert(view: self, authTpye: .Video)

        }
    
    }
    
    func checkAudioAuth(){
        let res = AVCaptureDevice.authorizationStatus(for: .audio)
        switch res {
        case .authorized:
            isAudioOK = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: {[weak self] (granted) in
                self?.isAudioOK = granted
                if !granted{
                    Auth.showEventAccessDeniedAlert(view: self!, authTpye: .Audio)
                }
            })
            
        default:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Audio)
            
        }
    }
    
    func prepareRecord() {
        if isAudioOK && isVideoOK {
            session = CaptureSession(sessionPreset: .CaptureSessionPreset540x960)
            session?.preView = view
            session?.delegate = self
            view.bringSubview(toFront: imgVideo)
            view.bringSubview(toFront: btnStartRecord)
            view.bringSubview(toFront: btnSwitchCamera)
        }
    }
    
    @objc func startRecord()  {
        if !isRecoding{
            session?.startRunning()
            btnStartRecord.setTitle("停止采集", for: .normal)
        }
        else{
            session?.stopRunning()
            btnStartRecord.setTitle("开始采集", for: .normal)
            
            UIAlertController.title(title: "保存该视频", message: nil).action(title: "取消", handle: nil).action(title: "确定", handle: {(acttion:UIAlertAction) in
                
                
            }).show()
        }
        isRecoding = !isRecoding
    }
    
   
    
    @objc func switchCamera()  {
        if currentCamera == .BackCamera {
            session?.captureCamera = .FrontCamera
            currentCamera = .FrontCamera
        }
        else{
            session?.captureCamera = .BackCamera
            currentCamera = .BackCamera
        }
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
    }
}

extension CaptureVideoViewController:CaptureSessionDelegate{
    func videoCaptureOutputWithSampleBuffer(sampleBuffer: CMSampleBuffer) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let ciImage = CIImage(cvImageBuffer: imageBuffer!)
        let img = UIImage(ciImage: ciImage)
        DispatchQueue.main.async {
            self.imgVideo.image = img
        }
        
        print("fire img")
    }
    
    func audioCaptureOutputWithSampleBuffer(sampleBuffer: CMSampleBuffer) {
        
    }
    
    
}
