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
  
    
    var handle:OpenCVHandle!
    var previewImage : UIImage?
   let imgView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let layerWidth = view.bounds.size.width - 40
        imgView.addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(layerWidth + 100)
            m.centerX.equalTo(view)
            m.width.height.equalTo(layerWidth)
        }
        handle = OpenCVHandle()
        // Do any additional setup after loading the view.
    }

   

    func updatePreviewImage(sampleBuffer:CMSampleBuffer)  {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
            return
        }
        let ciimage = CIImage(cvImageBuffer: imageBuffer)
        previewImage = convertCIImageToUIImage(cimage: ciimage)
        let img = handle.regImage2(previewImage!)
        DispatchQueue.main.sync {
           
            tagLayer?.contents = img.cgImage
        }
    }

    func convertCIImageToUIImage(cimage:CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(cimage, from: cimage.extent) else{
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIImage.Orientation.right)
        return image
    }

}

extension OpenCVImageRecognitionViewController:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
//        let img = handle.regImage(sampleBuffer)
//        tagLayer?.contents = img.cgImage
        
        updatePreviewImage(sampleBuffer: sampleBuffer)
    }
}
