//
//  FFmpegViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/9.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FFmpegViewController: UIViewController {
    var preview:PreviewView?
    var btnStart = UIButton()
    var isH265File = false
    var sortHandler:SortFrameHandler?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        
        
        preview = PreviewView(frame: view.frame)
        view.addSubview(preview!)
        
        sortHandler = SortFrameHandler()
        sortHandler?.delegate = self
        
        _ = UIBarButtonItem(title: "开始", style: .plain, target: self, action: #selector(playVideo))
        
        
        
      
    }
    
    @objc func playVideo() {
        var isUseFFmpeg = false
        if isUseFFmpeg{
            startDecodeByFFmpegWithIsH265Data()
        }
        else{
            startDecodeByVTSessionWithIsH265Data()
        }
    }
    
    func startDecodeByVTSessionWithIsH265Data()  {
        let path = Bundle.main.path(forResource: "test", ofType: "mp4")
        let handle = AVParseHandler(path: path!)
        let decoder = VideoDecoder()
        decoder.delegate = self
        
        handle.startParse { (isVideoFrame, isFinish, videoInfo,  parseInfo) in
            if isFinish{
                decoder.stop()
            }
            if isVideoFrame{
                decoder.startDecodeVideoData(videoInfo)
            }
        }
    }

    func startDecodeByFFmpegWithIsH265Data()  {
        let path = Bundle.main.path(forResource: "test", ofType: "mp4")
        let handle = AVParseHandler(path: path!)
    
    }
}

extension FFmpegViewController:SortFrameHandlerDelegate,VideoDecoderDelegate{
    func getSortedVideoNode(_ videoDataRef: CMSampleBuffer) {
        
    }
    func getVideoDecodeDataCallback(_ sampleBuffer: CMSampleBuffer, isFirstFrame: Bool) {
        
    }
}
