//
//  VideoRecordViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import GrandTime
enum VideoRecordStatus {
    case Prepared,Recording,Finish
}

class VideoRecordViewController: UIViewController {
    
    var captureSessionCoordinator:CaptureSessionCoordinator!
    let btnRecord = UIButton()
    let btnFlash = UIButton()
    let sliderProgress = UISlider()
    let lblTime = UILabel()
    let vBlink = UIView()
    let btnDelete = UIButton()
    let btnUpload = UIButton()
    let btnBack = UIButton()
    var debtId = 0
    var isRecording = false
    var isDismissing = false
    let vRecordControl = UIView()
    var timer:GrandTimer!
    var tmpVideoFile:URL!
    var isFlashOn = false
    var uploadVideoBlock:((_ url:URL)->Void)?
    var oldConstriants:[NSLayoutConstraint]!
    var recordStatus = VideoRecordStatus.Prepared
    {
        didSet{
            switch recordStatus {
            case .Prepared:
                sliderProgress.isHidden = true
                vBlink.isHidden = true
                lblTime.isHidden = true
                btnBack.isHidden = false
                btnFlash.isHidden = false
                btnDelete.isHidden = true
                btnUpload.isHidden = true
                btnRecord.isSelected = false
                btnRecord.isHidden = false
                sliderProgress.value = 0
                recordTime = TimeSpan.fromSeconds(0)
                lblTime.text = "00:00:00"
            case .Recording:
                btnRecord.isSelected = true
                btnBack.isHidden = true
                btnFlash.isHidden = true
                btnDelete.isHidden = true
                btnDelete.isSelected = false
                btnUpload.isHidden = true
                sliderProgress.isHidden = false
                vBlink.isHidden = false
                lblTime.isHidden = false
            case .Finish:
                btnBack.isHidden = false
                btnRecord.isHidden = true
                btnRecord.isSelected = false
                btnDelete.isHidden = false
                btnUpload.isHidden = false
                vBlink.isHidden = true
                lblTime.isHidden = true
            }
        }
    }
    var recordTime = TimeSpan.fromSeconds(0)
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
       timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromTicks(300), target: self, sel: #selector(tick), userInfo: nil, repeats: true,dispatchQueue: DispatchQueue.main)
        let url = CVFileManager.tempFileURL(extensionName: "mov")
        captureSessionCoordinator = CaptureSessionAssetWriterCoordinator(filePath: url.path)
        captureSessionCoordinator.setDelegate(delegate: self, callbackQueue: DispatchQueue.main)
        
        guard  let previewLayer = captureSessionCoordinator.previewLayer else{
            return
        }
        
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        captureSessionCoordinator.startRunning()
        
       NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(notif:)), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
  
    func initView() {
        sliderProgress.setThumbImage(UIImage(), for: .normal)
        sliderProgress.minimumTrackTintColor = UIColor(hexString: "#48FDFF")
        sliderProgress.maximumTrackTintColor = UIColor(gray: 1, alpha: 0.5)
        sliderProgress.maximumValue = 0
        sliderProgress.maximumValue = 600
        sliderProgress.isContinuous = true
        sliderProgress.isUserInteractionEnabled = false
        sliderProgress.isHidden = true
        view.addSubview(sliderProgress)
        sliderProgress.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(35)
            m.height.equalTo(4)
        }
        
        btnBack.setImage(#imageLiteral(resourceName: "public_btn_back_white_solid"), for: .normal)
        btnBack.addTarget(self, action: #selector(back), for: .touchUpInside)
        btnBack.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(15)
            m.top.equalTo(45)
        }
        
        btnFlash.addTarget(self, action: #selector(switchFlash), for: .touchUpInside)
        btnFlash.setImage(#imageLiteral(resourceName: "btn_flash_on"), for: .selected)
        btnFlash.setImage(#imageLiteral(resourceName: "btn_flash_off"), for: .normal)
        btnFlash.addTo(view: view).snp.makeConstraints { (m) in
            m.right.equalTo(-15)
            m.centerY.equalTo(btnBack)
        }
        
        vBlink.isHidden = true
        vBlink.bgColor(color: UIColor.red).cornerRadius(radius: 5).addTo(view: view).snp.makeConstraints { (m) in
            m.centerY.equalTo(btnBack)
            m.width.height.equalTo(10)
            m.left.equalTo(ScreenWidth / 2 - 40)
        }
        
        lblTime.isHidden = true
        lblTime.text(text: "00:00:00").color(color: UIColor.white).setFont(font: 18).addTo(view: view).snp.makeConstraints { (m) in
            m.centerY.equalTo(btnBack)
            m.left.equalTo(vBlink.snp.right).offset(5)
        }
        
        vRecordControl.bgColor(color: UIColor(gray: 0.7, alpha: 0.7)).addTo(view: view).snp.makeConstraints { (m) in
            m.bottom.left.right.equalTo(0)
            m.height.equalTo(125)
        }
        
        btnRecord.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        btnRecord.setImage(#imageLiteral(resourceName: "btn_start_record_video"), for: .normal)
        btnRecord.setImage(#imageLiteral(resourceName: "btn_recording_video"), for: .selected)
        btnRecord.addTo(view: vRecordControl).snp.makeConstraints { (m) in
            m.center.equalTo(vRecordControl)
        }
        
        btnDelete.setImage(#imageLiteral(resourceName: "btn_video_delete_normal"), for: .normal)
        btnDelete.setImage(#imageLiteral(resourceName: "btn_video_delete_confirm"), for: .selected)
        btnDelete.isHidden = true
        btnDelete.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnDelete.addTarget(self, action: #selector(deleteRecord), for: .touchUpInside)
        btnDelete.addTo(view: vRecordControl).snp.makeConstraints { (m) in
            m.centerY.equalTo(vRecordControl)
            m.left.equalTo(37)
        }
        
        
        btnUpload.setImage(#imageLiteral(resourceName: "btn_video_uploading"), for: .normal)
        btnUpload.isHidden = true
        btnUpload.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnUpload.addTarget(self, action: #selector(uploadRecord), for: .touchUpInside)
        btnUpload.addTo(view: vRecordControl).snp.makeConstraints { (m) in
            m.centerY.equalTo(vRecordControl)
            m.right.equalTo(-37)
        }
    }
    
    @objc func deviceOrientationDidChange(notif:Notification){
        let _interfaceOrientation = UIApplication.shared.statusBarOrientation
        switch _interfaceOrientation {
        case .landscapeLeft,.landscapeRight:
            if let previewLayer = view.layer.sublayers?.first{
                previewLayer.frame = CGRect(x: 0, y: 0, w: view.bounds.height, h: view.bounds.width)
            }
            if oldConstriants == nil{
                oldConstriants = view.constraints
            }
           
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.transitionCurlUp, animations: {
               
             
            }, completion: nil)
        case .portraitUpsideDown,.portrait:
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: UIViewKeyframeAnimationOptions.calculationModeLinear, animations: {
             
            }, completion: nil)
        case .unknown:
            print("UIInterfaceOrientationUnknown")
            break
        }
    }
    
    @objc func switchFlash()  {
        captureSessionCoordinator.setFlash(turn: !isFlashOn)
        btnFlash.isSelected = isFlashOn
    }
    
    @objc func tick()  {
        recordTime =  recordTime.add(TimeSpan.fromTicks(300))
        sliderProgress.value = Float(recordTime.seconds)
        lblTime.text = recordTime.format(format: "HH:mm:ss")
        vBlink.isHidden = !vBlink.isHidden
        if recordTime.seconds > 600 {
            startRecord()
        }
    }
    
    @objc func setRecordSetting()  {
        
    }
    
    @objc func back() {
        if isRecording{
            isDismissing = true
            captureSessionCoordinator.stopRecording()
        }
        else{
            stopPipelineAndDismiss()
        }
    }
    
    @objc func startRecord() {
        if isRecording{
            if recordTime < TimeSpan.fromSeconds(10){
                Toast.showToast(msg: "录制时间太短")
                return
            }
            captureSessionCoordinator.stopRecording()
            isRecording = false
            recordStatus = .Finish
            timer.pause()
        }
        else{
            UIApplication.shared.isIdleTimerDisabled = true
            captureSessionCoordinator.startRecording()
            isRecording = true
            recordStatus = .Recording
            timer.fire()
        }
    }
    
    @objc func deleteRecord() {
        if !btnDelete.isSelected{
            btnDelete.isSelected = true
            return
        }
        if btnDelete.isSelected{
            recordStatus = .Prepared
            if tmpVideoFile != nil{
                try? FileManager.default.removeItem(at: tmpVideoFile)
            }
        }
    }
 
    
    @objc func recordVideo()  {
       
        if isRecording{
            captureSessionCoordinator.stopRecording()
            isRecording = false
        }
        else{
            UIApplication.shared.isIdleTimerDisabled = true
            btnRecord.setTitle("Stop", for: .normal)
            captureSessionCoordinator.startRecording()
            isRecording = true
        }
    }

    func stopPipelineAndDismiss()  {
        captureSessionCoordinator.stopRunning()
        dismiss(animated: true, completion: nil)
        isDismissing = false
    }
    
    @objc func uploadRecord() {
        uploadVideoBlock?(tmpVideoFile)
        dismiss(animated: true, completion: nil)
    }
    
}
extension VideoRecordViewController:CaptureSessionCoordinatorDelegate{
    func coordinatorDidBeginRecording(coordinator: CaptureSessionCoordinator) {
        btnRecord.isEnabled = true
    }
    
    func coordinator(coordinator: CaptureSessionCoordinator, outputFileUrl: URL, error: Error?) {
        if error != nil{
            GrandCue.toast("发生错误:\(error!.localizedDescription)")
            return
        }
        
        UIApplication.shared.isIdleTimerDisabled = false
        recordStatus = .Finish
        btnRecord.isSelected = false
        isRecording = false
        tmpVideoFile = outputFileUrl
    }
    
    
}
