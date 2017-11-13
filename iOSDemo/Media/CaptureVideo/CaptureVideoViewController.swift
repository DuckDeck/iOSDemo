//
//  CaptureVideoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
import AVFoundation
class CaptureVideoViewController: UIViewController {

    let btnSwitchCamera = UIButton()
    let btnStartRecord = UIButton()
    let imgVideo = UIImageView()
    var currentCamera = CaptureCamera.BackCamera
    var session:CaptureSession?
    var isVideoOK = false
    var isAudioOK = false
    var isRecoding = false
    override func loadView() {
        let root = TGLinearLayout(frame: UIScreen.main.bounds, orientation: .vert)
        root.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        root.backgroundColor = UIColor.white
        self.view = root
        
        imgVideo.tg_width.equal(.fill)
        imgVideo.tg_height.equal(70%)
        view.addSubview(imgVideo)
    
        btnStartRecord.title(title: "开始采集").color(color: UIColor.blue).addTo(view: view).completed()
        btnStartRecord.tg_width.equal(50%)
        btnStartRecord.tg_height.equal(30)
        btnStartRecord.tg_centerY.equal(view)
        btnStartRecord.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        
        btnSwitchCamera.title(title: "后置").color(color: UIColor.blue).addTo(view: view).completed()
        btnSwitchCamera.tg_width.equal(50%)
        btnSwitchCamera.tg_height.equal(30)
        btnSwitchCamera.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        btnSwitchCamera.tg_centerY.equal(view)
        
        checkAudioAuth()
        checkVideoAuth()
        prepareRecord()
        
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
        }
        else{
            session?.stopRunning()
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
    }
    
    func audioCaptureOutputWithSampleBuffer(sampleBuffer: CMSampleBuffer) {
        
    }
    
    
}
