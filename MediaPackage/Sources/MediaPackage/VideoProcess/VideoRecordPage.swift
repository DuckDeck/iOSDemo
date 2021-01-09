//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//
import UIKit
import GrandTime
import CoreMotion
import CommonLibrary
enum VideoRecordStatus {
    case Prepared,Recording,Finish
}

class VideoRecordViewController: UIViewController {
    
    var captureSessionCoordinator:CaptureSessionCoordinator!
    let vRecordStatus = TouchView()
    let btnRecord = UIButton()
    let btnFlash = UIButton()
    let btnSwitchCamera = UIButton()
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
    var motion:CMMotionManager!
    var viewFocus:FocusFrameView!
    var orientation : UIDeviceOrientation{
        set{
            if _orientation != newValue{
                _orientation = newValue
                updateDeviceOrientation()
            }
        }
        get{
            return  _orientation
        }
    }
    var _orientation = UIDeviceOrientation.portrait
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

            }
        }
    }
    var recordTime = TimeSpan.fromSeconds(0)
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
       timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromTicks(300), target: self, sel: #selector(tick), userInfo: nil, repeats: true,dispatchQueue: DispatchQueue.main)
        let url = FileManager.tempFileURL(extensionName: "mov")
        captureSessionCoordinator = CaptureSessionAssetWriterCoordinator(filePath: url.path)
        captureSessionCoordinator.setDelegate(delegate: self, callbackQueue: DispatchQueue.main)
        
        guard  let previewLayer = captureSessionCoordinator.previewLayer else{
            return
        }
        
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        captureSessionCoordinator.startRunning()
        
        viewFocus = FocusFrameView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
         startMotion()
    }
    
    override var shouldAutorotate: Bool{
        return false //在没有用屏幕关闭旋转 获取手机方向，用一般的方法是不行的
    }
    
  
    func initView() {
       
        
        vRecordControl.bgColor(color: UIColor(gray: 0.5, alpha: 0.3)).addTo(view: view).snp.makeConstraints { (m) in
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
        
        
        vRecordStatus.addTo(view: view).snp.makeConstraints { (m) in
            m.center.equalTo(view)
            m.width.equalTo(ScreenWidth)
            m.height.equalTo(ScreenHeight)
        }
        vRecordStatus.isUserInteractionEnabled = true
        
        sliderProgress.setThumbImage(UIImage(), for: .normal)
        sliderProgress.minimumTrackTintColor = UIColor(hexString: "#48FDFF")
        sliderProgress.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        sliderProgress.maximumValue = 0
        sliderProgress.maximumValue = 600
        sliderProgress.isContinuous = true
        sliderProgress.isUserInteractionEnabled = false
        sliderProgress.isHidden = true
        vRecordStatus.addSubview(sliderProgress)
        sliderProgress.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(15)
            m.height.equalTo(4)
        }
        
        btnBack.setImage(#imageLiteral(resourceName: "public_btn_back_white_solid"), for: .normal)
        btnBack.addTarget(self, action: #selector(back), for: .touchUpInside)
        btnBack.addTo(view: vRecordStatus).snp.makeConstraints { (m) in
            m.left.equalTo(20)
            m.top.equalTo(25)
        }
        
        btnSwitchCamera.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        btnSwitchCamera.setImage(UIImage(named: "camra_preview"), for: .normal)
        btnSwitchCamera.addTo(view: vRecordStatus).snp.makeConstraints { (m) in
            m.right.equalTo(-60)
            m.centerY.equalTo(btnBack)
        }
        
        btnFlash.addTarget(self, action: #selector(switchFlash), for: .touchUpInside)
        btnFlash.setImage(UIImage(named: "btn_flash_on"), for: .selected)
        btnFlash.setImage(#imageLiteral(resourceName: "btn_flash_off"), for: .normal)
        btnFlash.addTo(view: vRecordStatus).snp.makeConstraints { (m) in
            m.right.equalTo(-20)
            m.centerY.equalTo(btnBack)
        }
        
        
        
        lblTime.isHidden = true
        lblTime.text(text: "00:00:00").color(color: UIColor.white).setFont(font: 18).addTo(view: vRecordStatus).snp.makeConstraints { (m) in
            m.centerY.equalTo(btnBack)
            m.centerX.equalTo(vRecordStatus)
        }
        
        vBlink.isHidden = true
        vBlink.bgColor(color: UIColor.red).cornerRadius(radius: 5).addTo(view: vRecordStatus).snp.makeConstraints { (m) in
            m.centerY.equalTo(btnBack)
            m.width.height.equalTo(10)
            m.right.equalTo(lblTime.snp.left).offset(-5)
        }
    }
    

    
    func startMotion() {
        if motion == nil{
            motion = CMMotionManager()
        }
        motion.deviceMotionUpdateInterval = 1 / 15.0
        if motion.isDeviceMotionAvailable{
            motion.startDeviceMotionUpdates(to: OperationQueue.current!) {[weak self] (device, err) in
                guard let d = device else{
                    return
                }
                if fabs(d.gravity.z) > 0.5{
                    return
                }
                let x = d.gravity.x
                let y = d.gravity.y
                print("the z is \(d.gravity.z)")
                if fabs(y) >= fabs(x){
                    if y > 0{
                        self?.orientation = .portraitUpsideDown
                    }
                    else{
                        self?.orientation = .portrait
                    }
                }
                else{
                    if x > 0{
                         self?.orientation = .landscapeRight
                    }
                    else{
                         self?.orientation = .landscapeLeft
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motion.stopDeviceMotionUpdates()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func updateDeviceOrientation()  {
        print(orientation)
        switch orientation {
        case .landscapeLeft:
            UIView.animate(withDuration: 0.2) {
                
                self.vRecordStatus.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                self.vRecordStatus.snp.updateConstraints({ (m) in
                    m.width.equalTo(ScreenHeight)
                    m.height.equalTo(ScreenWidth)
                })
                self.btnUpload.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                self.btnDelete.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                self.view.layoutIfNeeded()
            }
           
        case .portrait:  UIView.animate(withDuration: 0.2) {
            UIView.animate(withDuration: 0.2) {
                self.vRecordStatus.transform = CGAffineTransform(rotationAngle: 0)
                self.vRecordStatus.snp.updateConstraints({ (m) in
                    m.width.equalTo(ScreenWidth)
                    m.height.equalTo(ScreenHeight)
                })
                self.btnUpload.transform = CGAffineTransform(rotationAngle: 0)
                self.btnDelete.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            }
        }
        default:
            break
        }
    }
    
    
    
    @objc func switchFlash()  {
        captureSessionCoordinator.setFlash(turn: !isFlashOn)
        btnFlash.isSelected = isFlashOn
    }
    
    @objc func switchCamera(){
        captureSessionCoordinator.switchCamera()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: view)
        print(touchPoint)
        
        captureSessionCoordinator.focusAtPoint(point: touchPoint)
        viewFocus.startToFocus(point: touchPoint, view: view)
        
        
    }
    
}

class TouchView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}

