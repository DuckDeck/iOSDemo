
//
//  AudioDecoderViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class AudioDecoderViewController: UIViewController {

    let btnRecord = UIButton()
    let btnStop = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        AudioQueueCaptureManager.getInstance().startAudioCapture()
      
        btnRecord.title(title: "开始录音").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(100)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(50)
        }
        
        btnRecord.addTarget(self, action: #selector(record), for: .touchUpInside)
        
        btnStop.title(title: "开始录音").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(100)
            m.right.equalTo(-100)
            m.width.equalTo(100)
            m.height.equalTo(50)
        }
        
        btnStop.addTarget(self, action: #selector(stop), for: .touchUpInside)

    }
    
    @objc func record()  {
        AudioQueueCaptureManager.getInstance().startRecordFile()
    }
    
    @objc func stop() {
        AudioQueueCaptureManager.getInstance().stopRecordFile()
    }

    deinit {
        AudioQueueCaptureManager.getInstance().stopAudioCapture()
    }

}
