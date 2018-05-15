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
        
        let tapFocus = UITapGestureRecognizer(target: self, action: #selector(focusTap(ges:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapFocus)
        
        setupCaptureSession()
        sc.isHidden = true
        sc.backgroundColor = UIColor.white
        sc.delegate = self
        sc.maximumZoomScale = 4
        sc.contentSize = CGSize(width: ScreenWidth + 1, height: ScreenHeight  + 1)
        sc.addTo(view: view).snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        imgPreview.contentMode = .scaleAspectFill
        imgPreview.addTo(view: sc).snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.top.equalTo(0)
            m.width.equalTo(ScreenWidth)
            m.height.equalTo(ScreenHeight)
        }
        imgPreview.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(ges:)))
        tapGes.numberOfTapsRequired = 2
        tapGes.numberOfTouchesRequired = 1
        imgPreview.addGestureRecognizer(tapGes)
        
        
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
    
    @objc func doubleTapAction(ges:UIGestureRecognizer)  {
        var newScale:CGFloat = 1
        if sc.zoomScale <= 1{
            newScale = 4
        }
        let zoomRect = zoomRectForScale(scale: newScale, center: ges.location(in: ges.view!))
        sc.zoom(to: zoomRect, animated: true)
    }
    
    func zoomRectForScale(scale:CGFloat,center:CGPoint) -> CGRect {
        let height = sc.frame.size.height / scale
        let width = sc.frame.size.width / scale
        let x = center.x - width / 2
        let y = center.y - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
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
    
    @objc func focusTap(ges:UITapGestureRecognizer)  {
        let point = ges.location(in: ges.view!)
        focusAtPoint(point: point)
    }
    
    func focusAtPoint(point:CGPoint)  {
        let s = view.bounds.size
        let focusPoint = CGPoint(x: point.y / s.height, y: 1 - point.x / s.width)
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.autoFocus){
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            if device.isExposureModeSupported(.autoExpose){
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
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
                    let img = image.fixImageOrientation()
                    let ratio = img.size.width / img.size.height
                    let newSize = CGSize(width: ScreenHeight * ratio, height: ScreenHeight)
                    self.sc.contentSize = newSize
                    self.imgPreview.image = img //加了转，可是没有用
                    self.imgPreview.snp.updateConstraints({ (m) in
                        m.width.equalTo(newSize.width)
                        m.height.equalTo(newSize.height)
                        m.left.equalTo((ScreenWidth - newSize.width) / 2)
                    })
                    self.btnTake.setTitle("ReTake", for: .normal)
                    self.isShowing = true
                   
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
        var xCenter = scrollView.center.x
        var yCenter = scrollView.center.y
        xCenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : xCenter
        yCenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height / 2 : yCenter
        imgPreview.center = CGPoint(x: xCenter, y: yCenter)    }
}
