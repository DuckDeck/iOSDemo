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

    var previewLayer:AVCaptureVideoPreviewLayer? = nil
    var tagLayer:CAShapeLayer? = nil
    var session:AVCaptureSession! = nil
    lazy var frontCameraInput:AVCaptureDeviceInput? = {
        guard let device = cameraWithPosition(position: AVCaptureDevice.Position.front) else{
            print("获取前置摄像头失败")
            return nil
        }
        let input = try? AVCaptureDeviceInput(device: device)
        return input
    }()
     lazy var backCameraInput:AVCaptureDeviceInput? = {
        guard let device = cameraWithPosition(position: AVCaptureDevice.Position.back) else{
            print("获取后置摄像头失败")
            return nil
        }
        let input = try? AVCaptureDeviceInput(device: device)
        return input
    }()
    
    var isDeicePositionFront = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnRight = UIButton(type: .system)
        btnRight.setTitle("切换摄像头", for: .normal)
        btnRight.sizeToFit()
        btnRight.addTarget(self, action: #selector(switchCamera(sender:)), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnRight)
        navigationItem.rightBarButtonItem = item
        
        initVideo()
        
    }
    
    @objc func switchCamera(sender:UIButton)  {
        if isDeicePositionFront{
            session.stopRunning()
            session.removeInput(frontCameraInput!)
            if session.canAddInput(backCameraInput!){
                session.addInput(backCameraInput!)
                session.startRunning()
            }
            isDeicePositionFront = false
        }
        else{
            session.stopRunning()
            session.removeInput(backCameraInput!)
            if session.canAddInput(frontCameraInput!){
                session.addInput(frontCameraInput!)
                session.startRunning()
            }
            isDeicePositionFront = false
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
        output.setSampleBufferDelegate((self as! AVCaptureVideoDataOutputSampleBufferDelegate), queue: DispatchQueue.global(qos: .default))
        
        if session.canAddInput(input!){
            session.addInput(input!)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        
        let _previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        let layerWidth = view.bounds.size.width - 40
        _previewLayer.frame = CGRect(x: 20, y: 70, w: layerWidth, h: layerWidth)
        
        _previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        view.layer.addSublayer(_previewLayer)
        self.previewLayer = _previewLayer
        
        let targetLayer = CAShapeLayer()
        targetLayer.frame = CGRect(x: 20, y: 70 , w: layerWidth, h: layerWidth)
        view.layer.addSublayer(targetLayer)
        targetLayer.backgroundColor = UIColor.clear.cgColor
        tagLayer = targetLayer
        session.startRunning()
        
    }
 
    
    func cameraWithPosition(position:AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: .video)
        for dev in devices{
            if dev.position == position{
                return dev
            }
        }
        return nil
    }

}
