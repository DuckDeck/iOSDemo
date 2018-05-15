//
//  TakePhotoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/10.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
class TakePhotoViewController: BaseViewController {
    //还需要完成。对焦与自动曝光调节 切换前后摄像头，保存相片不知道为什么不行
    fileprivate let session = AVCaptureSession()
    var device:AVCaptureDevice!
    let btnClose = UIButton()
    let btnTake = UIButton()
    let btnFlash = UIButton()
    let sc = UIScrollView()
    let imgPreview = UIImageView()
    var isShowing = false
    var isFlashing = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        
        sc.delegate = self
        sc.addTo(view: view).snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        imgPreview.contentMode = .scaleAspectFit
        imgPreview.addTo(view: sc).snp.makeConstraints { (m) in
            m.center.equalTo(sc)
        }
        
      
        btnTake.title(title: "Take").bgColor(color: UIColor(white: 0.5, alpha: 0.3)).color(color: UIColor.white).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.5)
            m.bottom.equalTo(-20)
            m.height.equalTo(30)
        }
        btnTake.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        
        btnClose.title(title: "Close").bgColor(color: UIColor(white: 0.5, alpha: 0.3)).color(color: UIColor.white).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.75)
            m.bottom.equalTo(-20)
            m.height.equalTo(30)
        }
        
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        btnFlash.title(title: "FlashOff").color(color: UIColor.white).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.75)
            m.top.equalTo(30)
        }
        
        btnFlash.addTarget(self, action: #selector(openFlash), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
    
    @objc func openFlash() {
        isFlashing = !isFlashing
        btnFlash.setTitle(isFlashing ? "FlashOff" : "FlashOn", for: .normal)
        do{
           try device.lockForConfiguration()
            if isFlashing{
                if device.isFlashModeSupported(.on){
                    device.flashMode = .on
                    device.torchMode = .on
                }
            }
            else{
                if device.isFlashModeSupported(.off){
                    device.flashMode = .off
                    device.torchMode = .off
                }
            }
            device.unlockForConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    @objc func takePhoto() {
        if isShowing{
            self.sc.isHidden = true
            self.imgPreview.image = nil
            isShowing = false
            self.btnTake.setTitle("Take", for: .normal)
        }
        else{
            if let output = session.outputs.first as? AVCaptureStillImageOutput {
                print(output.connections.first!)
                output.captureStillImageAsynchronously(from: output.connections.first!) {
                    guard let buffer = $0 else {
                        print($1?.localizedDescription ?? "")
                        return
                    }
                    guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer) else {
                        return
                    }
                    guard let image = UIImage(data: data) else {
                        return
                    }
                    print("Image Size \(image.size)")
                    self.sc.isHidden = false
                    self.imgPreview.image = image.fixImageOrientation() //加了转，可是没有用
                   
                    self.btnTake.setTitle("ReTake", for: .normal)
                    self.isShowing = true
                    self.saveToAlbum(img: image)
                    //拍出来的照片 是 Image Size (3024.0, 4032.0) ，很大，可能要特别处理事情
                    // 还有就是照片方向问题
                }
            }
        }
        
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    func saveToAlbum(img:UIImage) {
        DispatchQueue.main.async {
           let s = UIAlertController.title(title: "保存图片", message: nil).action(title: "取消", handle: nil).action(title: "确定", handle: {(action:UIAlertAction) in
                img.saveToAlbum()
            })
            self.present(s, animated: true, completion: nil)
        }
       
    }
    

}
extension TakePhotoViewController:UIScrollViewDelegate {
    func setupCaptureSession() {
        var successful = true
        defer {
            if !successful {
                // log error msg...
                print("error setting capture session")
            }
        }
        
        guard let device = tunedCaptureDevice() else {
            successful = false
            return
        }
        
        // begin configuration
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        // preset
        session.sessionPreset = .photo
        // add input
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                successful = false
                return
            }
        } catch {
            print(error.localizedDescription)
            successful = false
            return
        }
        // add output
        let output = AVCaptureStillImageOutput()
        output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            successful = false
            return
        }
        
        // insert preview layer
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
    }
    
    private func tunedCaptureDevice() -> AVCaptureDevice? {
        guard let d = AVCaptureDevice.default(for: .video)  else {
            return nil
        }
        device = d
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            device.unlockForConfiguration()
            return device
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgPreview
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        CGFloat offsetX = (self.bounds.size.width>self.contentSize.width)?(self.bounds.size.width-self.contentSize.width)*0.5:0.0;
//        CGFloat offsetY = (self.bounds.size.height>self.contentSize.height)?(self.bounds.size.height-self.contentSize.height)*0.5:0.0;
//        _imageView.center = CGPointMake(scrollView.contentSize.width*0.5+offsetX, scrollView.contentSize.height*0.5+offsetY);

        
//        let offsetX = bounds.size.width > self.sc.contentSize.width ? (self.bounds.size.width - self.sc.contentSize.width) / 2 : 0
      
    }
}
