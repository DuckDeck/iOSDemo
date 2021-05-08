//
//  File.swift
//  
//
//  Created by chen liang on 2021/5/6.
//


import UIKit
import AVFoundation
import SwiftUI
import CommonLibrary
import GrandTime
class SweepCodeVC: UIViewController {
    
    var code:String?
    //扫描相关变量
    var device:AVCaptureDevice?
    var input:AVCaptureDeviceInput?
    var outPut:AVCaptureMetadataOutput?
    var session:AVCaptureSession?
    var preview:AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "扫描快递单号"
        initView()
        setupCamera()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stopRunning()
    }
    
    func initView() {
        let vScanFrame = ScanView()
        view.addSubview(vScanFrame)
        vScanFrame.snp.makeConstraints { (m) in
            m.center.equalTo(view)
            m.width.equalTo(UIScreen.main.bounds.width / 1.3)
            m.height.equalTo(170)
        }
    }

    func setupCamera() {
        #if arch(x86_64) || arch(i386)
            let vc = UIAlertController(title: "你正在使用模拟器", message: "模拟器无法使用摄像头", preferredStyle: .alert)
            vc.action(title: "确定") { (alert) in
            }.show()
            return
        #endif
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
        preview?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
            
        }
        return arr
    }
}

extension SweepCodeVC:AVCaptureMetadataOutputObjectsDelegate {
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session?.stopRunning()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        if let last = metadataObjects.last{
          
            if let str = last.value(forKey: "stringValue") as? String{
                Toast.showToast(msg: "扫出\(str)\n 类型是\(last.type.rawValue)")
                session?.startRunning()
            }
            else{
                Toast.showToast(msg:"未扫出信息")
                session?.startRunning()
            }
            
        }
        else{
            session?.startRunning()
        }
    }
}
class ScanView: UIView {
    let vMobile = UIView()
    var timer : GrandTimer?
    var  lineY:CGFloat = 3
    let sweepLine = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        sweepLine.fillColor = UIColor.green.cgColor
        layer.addSublayer(sweepLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timer = GrandTimer.every(TimeSpan.fromTicks(10), block: { [weak self] in
            guard let self = self else{return}
            if self.lineY >= self.frame.size.height - 6{
                self.lineY = 3
            }
            let r = CGRect(x: 3, y: self.lineY, width: self.frame.size.width - 6, height: 3)
            let path1 = UIBezierPath(roundedRect: r, cornerRadius: 0)
            self.sweepLine.path = path1.cgPath
            self.lineY = self.lineY + 1
        })
        timer?.fire()
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let border = UIColor(red: 0.0, green: 159.0/255.0, blue: 223.0/255.0, alpha: 1)
        ctx?.setStrokeColor(border.cgColor)
        ctx?.setLineWidth(10)
        ctx?.move(to: CGPoint(x: 20, y: 0))
        ctx?.addLine(to: CGPoint(x: 0, y: 0))
        ctx?.addLine(to: CGPoint(x: 0, y: 20))

        ctx?.move(to: CGPoint(x: rect.size.width - 20, y: 0))
        ctx?.addLine(to: CGPoint(x: rect.size.width, y: 0))
        ctx?.addLine(to: CGPoint(x: rect.size.width, y: 20))
        
        ctx?.move(to: CGPoint(x: rect.size.width, y: rect.size.height - 20))
        ctx?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        ctx?.addLine(to: CGPoint(x: rect.size.width - 20, y: rect.size.height))
        
        ctx?.move(to: CGPoint(x: 20, y: rect.size.height))
        ctx?.addLine(to: CGPoint(x: 0, y: rect.size.height ))
        ctx?.addLine(to: CGPoint(x: 0, y: rect.size.height - 20))
        ctx?.strokePath()
        ctx?.setStrokeColor(UIColor.red.cgColor)
        ctx?.setLineWidth(3)
        ctx?.strokePath()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
struct SweepCodeDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = SweepCodeVC
    
    func makeUIViewController(context: Context) -> SweepCodeVC {
        return SweepCodeVC()
    }
}


