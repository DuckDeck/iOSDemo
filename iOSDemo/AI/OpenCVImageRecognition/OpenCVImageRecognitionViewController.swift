//
//  OpenCVImageRecognitionViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/2/26.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
class OpenCVImageRecognitionViewController: OpenCVBaseViewController {
  
    var previewImage : UIImage?
    var handle:OpenCVHandle!
    override func viewDidLoad() {
        super.viewDidLoad()
     Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setPreviewImage), userInfo: nil, repeats: true)
        handle = OpenCVHandle()
        // Do any additional setup after loading the view.
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
        let image = handle.regImage(previewImage!)
        tagLayer?.contents = image.cgImage
    }

}

extension OpenCVImageRecognitionViewController:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        updatePreviewImage(sampleBuffer: sampleBuffer)
    }
}
