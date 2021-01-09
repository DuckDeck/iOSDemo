//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//

import UIKit
import AVFoundation
import SnapKit
import CommonLibrary
import SwiftUI
class TakePhotoViewController: UIViewController {
    //还需要完成。自动曝光调节 切换前后摄像头
    fileprivate let session = AVCaptureSession()
    var device:AVCaptureDevice!
    var currentInput:AVCaptureDeviceInput!
    let btnClose = UIButton()
    let btnTake = UIButton()
    let btnFlash = UIButton()
    let btnSwitchCamera = UIButton()
    let sc = UIScrollView()
    let vMenu = UIView()
    let imgPreview = UIImageView()
    var isShowing = false
    var isFlashing = false
    var vFocus = UIView()
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
        
        
        vMenu.bgColor(color: UIColor(white: 0.4, alpha: 0.3)).addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.height.equalTo(40)
        }
        btnTake.title(title: "Take").color(color: UIColor.white).addTo(view: vMenu).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.2)
            m.centerY.equalTo(vMenu)
            m.height.equalTo(30)
        }
        btnTake.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        btnSwitchCamera.title(title: "rear").color(color: UIColor.white).addTo(view: vMenu).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.4)
            m.centerY.equalTo(vMenu)
            m.height.equalTo(30)
        }
        btnSwitchCamera.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)

        
        btnClose.title(title: "Close").color(color: UIColor.white).addTo(view: vMenu).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.8)
            m.centerY.equalTo(vMenu)
            m.height.equalTo(30)
        }
        
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        btnFlash.title(title: "FlashOff").color(color: UIColor.white).addTo(view: vMenu).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.6)
            m.centerY.equalTo(vMenu)
            m.height.equalTo(30)
        }
        
        btnFlash.addTarget(self, action: #selector(openFlash), for: .touchUpInside)
        
        vFocus.isHidden = true
        vFocus.bgColor(color: UIColor.clear).borderWidth(width: 2).borderColor(color: UIColor.white).addTo(view: view).completed()
        vFocus.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
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
    
    @objc func switchCamera() {
        //获取摄像头的数量
        let cameraCount = AVCaptureDevice.devices(for: .video)
         //摄像头小于等于1的时候直接返回
        if cameraCount.count <= 1{
            Toast.showToast(msg: "你只有一个摄像头")
            return
        }
        var newCamera:AVCaptureDevice! = nil
        var newInput:AVCaptureDeviceInput! = nil
        let position = device.position
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = 0.5
        animation.type = CATransitionType(rawValue: "ogflip")
        if position == .front{
            guard let camera = cameraWithPosition(position: .back) else {
                return
            }
            newCamera = camera
        }
        else{
            guard let camera = cameraWithPosition(position: .front) else {
                return
            }
            newCamera = camera
        }
        guard let lay = view.layer.sublayers?.first else{
            return
        }
        lay.add(animation, forKey: nil)
        do{
            newInput = try AVCaptureDeviceInput(device: newCamera)
        }
        catch{
            print(error.localizedDescription)
        }
        device = newCamera
        if newInput != nil{
            session.beginConfiguration()
            if currentInput == nil{
                return
            }
             //先移除原来的input
            session.removeInput(currentInput)
            if session.canAddInput(newInput){
                session.addInput(newInput)
                currentInput = newInput
            }
            else{
                //如果不能加现在的input，就加原来的input
                session.addInput(currentInput)
            }
            session.commitConfiguration()
        }
        
    }
    
    func cameraWithPosition(position:AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: .video)
        for d in devices{
            if d.position == position{
                return d
            }
        }
        return nil
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
    
   public func focusAtPoint(point:CGPoint)  {
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
            vFocus.center = point
            vFocus.isHidden = false
            
                UIView.animate(withDuration: 0.5, animations: {
                    self.vFocus.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                }) { (finish) in
                    if finish{
                        self.vFocus.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.vFocus.isHidden = true
                    }
                }
            
            
           
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
            btnSwitchCamera.isEnabled = true
            btnFlash.isEnabled = true
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
                        
                    })
                    self.sc.contentOffset = CGPoint(x: (newSize.width - ScreenWidth) / 2, y: 0)
                    self.btnTake.setTitle("ReTake", for: .normal)
                    self.isShowing = true
                    self.btnSwitchCamera.isEnabled = false
                    self.btnFlash.isEnabled = false

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
            currentInput = input
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
        let output = AVCapturePhotoOutput()
        //output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
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

struct TakePhotoDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = TakePhotoViewController
    
    func makeUIViewController(context: Context) -> TakePhotoViewController {
        return TakePhotoViewController()
    }
}


