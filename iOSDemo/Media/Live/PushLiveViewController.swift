//
//  PushLiveViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/5/7.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import LFLiveKit

class PushLiveViewController: UIViewController {

    
    
    var debugInfo:LFLiveDebug?
    
    
    lazy var session:LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .low3, outputImageOrientation: .portrait)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session?.delegate = self
        session?.preView = self.view
        session?.showDebugInfo = true
        return session!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLive()
    }
    
    func startLive()  {
        let steam = LFLiveStreamInfo()
        steam.url = "rtmp://144.34.157.61:1935/mylive/44"
        session.startLive(steam)
    }
    
    func stopLive() {
        session.stopLive()
    }
    
}

extension PushLiveViewController:LFLiveSessionDelegate{
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print(errorCode.rawValue)
    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        
    }
}
