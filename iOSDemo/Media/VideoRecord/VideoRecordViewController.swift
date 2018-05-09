//
//  VideoRecordViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class VideoRecordViewController: UIViewController {
    
    var captureSessionCoordinator:CaptureSessionCoordinator!
    var isRecording = false
    var isDismissing = false
    let btnRecord = UIButton()
    let btnClose = UIButton()
    var isAudioOK = false
    var isVideoOK = false
    override func viewDidLoad() {
        super.viewDidLoad()

        let btnBar = UIBarButtonItem(title: "已有视频", style: .plain, target: self, action: #selector(setRecordSetting))
        navigationItem.rightBarButtonItem = btnBar
        
        Auth.isAuthCamera { (result) in
            if !result{
                GrandCue.toast("需要视频权限")
            }
            self.isVideoOK = true
        }
        
        Auth.isAuthMicrophone { (result) in
            if !result{
                GrandCue.toast("需要麦克风权限")
            }
            self.isAudioOK = true
        }
        captureSessionCoordinator = CaptureSessionAssetWriterCoordinator()
        captureSessionCoordinator.setDelegate(delegate: self, callbackQueue: DispatchQueue.main)
       
        guard  let previewLayer = captureSessionCoordinator.previewLayer else{
            return
        }
        
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        captureSessionCoordinator.startRunning()
        
        btnRecord.title(title: "Record").bgColor(color: UIColor.yellow).color(color: UIColor.red).setFont(font: 17).addTo(view: view).snp.makeConstraints { (m) in
            m.right.equalTo(-10)
            m.bottom.equalTo(-10)
        }

        btnRecord.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        
        btnClose.title(title: "Close").bgColor(color: UIColor.yellow).color(color: UIColor.red).setFont(font: 17).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.bottom.equalTo(-10)
        }
        
        btnClose.addTarget(self, action: #selector(closeRecordPage), for: .touchUpInside)
        
       
    }
    @objc func setRecordSetting()  {
        
    }
    
    @objc func closeRecordPage() {
        if isRecording{
            isDismissing = true
            captureSessionCoordinator.stopRecording()
        }
        else{
            stopPipelineAndDismiss()
        }
    }
 
    
    @objc func recordVideo()  {
        if isVideoOK && isAudioOK{
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
        
    }

    func stopPipelineAndDismiss()  {
        captureSessionCoordinator.stopRunning()
        dismiss(animated: true, completion: nil)
        isDismissing = false
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
        btnRecord.setTitle("Record", for: .normal)
        isRecording = false
        UIAlertController.title(title: "保存视频", message: nil).action(title: "取消", handle: nil).action(title: "确定", handle: {(action:UIAlertAction) in
           CVFileManager.copyFileToCameraRoll(fileUrl: outputFileUrl)
        }).show()
        if isDismissing{
            stopPipelineAndDismiss()
        }
    }
    
    
}
