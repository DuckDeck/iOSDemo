//
//  opencvViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/10/24.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
class opencvViewController: UIViewController {

    let session = AVCaptureSession()
    var previewImage : UIImage?
    let imgView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.addTo(view: view).snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        startLiveVideo()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setPreviewImage), userInfo: nil, repeats: true)
        
    }
    
    func startLiveVideo()  {
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else{
            return
        }
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        session.startRunning()
    }
    
    func updatePreviewImage(sampleBuffer:CMSampleBuffer)  {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
            return
        }
        let ciimage = CIImage(cvImageBuffer: imageBuffer)
        previewImage = convertCIImageToUIImage(cimage: ciimage)
    }

    func convertCIImageToUIImage(cimage:CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(cimage, from: cimage.extent) else{
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIImage.Orientation.right)
        return image
    }
    
    @objc func setPreviewImage()  {
        if previewImage == nil{
            return
        }
        let image = opencvTool.getBinaryImage(previewImage!)
        imgView.image = image
    }
}

extension opencvViewController:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        updatePreviewImage(sampleBuffer: sampleBuffer)
    }
}
