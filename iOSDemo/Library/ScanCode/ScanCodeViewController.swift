//
//  ScanCodeViewController.swift
//  iOSDemo
//
//  Created by shadowedge on 2020/10/13.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
class ScanCodeViewController: UIViewController {
    var code:String?
    //扫描相关变量
    var device:AVCaptureDevice?
    var input:AVCaptureDeviceInput?
    var outPut:AVCaptureMetadataOutput?
    var session:AVCaptureSession?
    var preview:AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "扫码"
        initView()
        setupCamera()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.startRunning()
    }
    
    func initView() {
        let vScanFrame = ScanView()
        view.addSubview(vScanFrame)
        vScanFrame.snp.makeConstraints { (m) in
            m.center.equalTo(view)
            m.width.height.equalTo(ScreenWidth / 2)
        }
    }

    func setupCamera() {
        device = AVCaptureDevice.default(for: AVMediaType.video)
        
        input = try? AVCaptureDeviceInput(device: device!)
        outPut = AVCaptureMetadataOutput()
        outPut?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session = AVCaptureSession()
        session?.sessionPreset = .high
        if input != nil && session!.canAddInput(input!) {
            session?.addInput(input!)
        }
        if session!.canAddOutput(outPut!) {
            session?.addOutput(outPut!)
        }
        outPut?.metadataObjectTypes = getMetadataObjectTypes()
        preview = AVCaptureVideoPreviewLayer(session: session!)
        preview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview?.frame = CGRect(x: 0, y: NavigationBarHeight, width: ScreenWidth, height: ScreenHeight - NavigationBarHeight)
        view.layer.insertSublayer(preview!, at: 0)
        session?.startRunning()
    }

    func getMetadataObjectTypes() -> [AVMetadataObject.ObjectType] {
        var arr = [AVMetadataObject.ObjectType]()
        
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.ean13) {
            arr.append(AVMetadataObject.ObjectType.ean13)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.code39) {
            arr.append(AVMetadataObject.ObjectType.code39)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.ean8) {
            arr.append(AVMetadataObject.ObjectType.ean8)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.code128) {
            arr.append(AVMetadataObject.ObjectType.code128)
        }
        if outPut!.availableMetadataObjectTypes.contains(AVMetadataObject.ObjectType.qr) {
            arr.append(AVMetadataObject.ObjectType.qr)
        }
        if arr.count == 0 {
            Auth.showEventAccessDeniedAlert(view: self, authTpye: AuthType.Camera)
        }
        return arr
    }
}

extension ScanCodeViewController:AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session?.stopRunning()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        if metadataObjects.count > 0 {
            print(metadataObjects.last!)
            if let val = metadataObjects.last!.value(forKey: "stringValue"){
                let vc = ScanResultViewController()
                vc.res = val as! String
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else{
            session?.startRunning()
        }
    }
}

class ScanView: UIView {
    let vMobile = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = UIColor.red.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
