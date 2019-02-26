//
//  OpenCVBaseViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/2/26.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
class OpenCVBaseViewController: BaseViewController {

    var previewLayer:AVCaptureVideoPreviewLayer
    var tagLayer:CAShapeLayer
    
    fileprivate var session:AVCaptureSession
    fileprivate var frontCameraInput:AVCaptureDeviceInput
    fileprivate var backCameraInput:AVCaptureDeviceInput
    
    fileprivate var isDeicePositionFront = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnRight = UIButton(type: .system)
        btnRight.setTitle("切换rr摄像头", for: .normal)
        btnRight.sizeToFit()
        btnRight.addTarget(self, action: #selector(switchCamera(sender:)), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnRight)
        navigationItem.rightBarButtonItem = item
        
        initVideo()
        
    }
    
    @objc func switchCamera(sender:UIButton)  {
        if isDeicePositionFront{
            session.stopRunning()
            session.removeInput(frontCameraInput)
            if session.canAddInput(backCameraInput){
                session.addInput(backCameraInput)
                session.startRunning()
            }
        }
        else{
            session.stopRunning()
            session.removeInput(backCameraInput)
            if session.canAddInput(frontCameraInput){
                session.addInput(frontCameraInput)
                session.startRunning()
            }
        }
    }

    func initVideo() {
        let _session = AVCaptureSession()
        _session.sessionPreset = AVCaptureSession.Preset.medium
        self.session = _session
        
        
        let input = backCameraInput
        let output = AVCaptureVideoDataOutput()
        
        let setting = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
        output.videoSettings = setting
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
        
        if session.canAddInput(input){
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        
        let _previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        let layerWidth = view.bounds.size.width - 40
        previewLayer.frame = CGRect(x: 20, y: 70, w: layerWidth, h: layerWidth)
        
        _previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        view.layer.addSublayer(_previewLayer)
        self.previewLayer = _previewLayer
        
        let targetLayer = CAShapeLayer()
        targetLayer.frame = previewLayer.frame
        view.layer.addSublayer(targetLayer)
        targetLayer.backgroundColor = UIColor.clear.cgColor
        tagLayer = targetLayer
        session.startRunning()
        
    }
 

}
extension OpenCVBaseViewController:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        updatePreviewImage(sampleBuffer: sampleBuffer)
    }
}
