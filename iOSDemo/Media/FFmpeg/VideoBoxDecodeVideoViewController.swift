//
//  VideoBoxDecodeVideoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/18.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class VideoBoxDecodeVideoViewController: UIViewController {

    var preview:PreviewView?
    var btnStart = UIButton()
    var isH265File = false
    var sortHandler:SortFrameHandler?
    static var lastpts = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        
        
        preview = PreviewView(frame: view.frame)
        view.addSubview(preview!)
        
        sortHandler = SortFrameHandler()
        sortHandler?.delegate = self
        
        let btnPlay = UIBarButtonItem(title: "开始", style: .plain, target: self, action: #selector(playVideo))
        navigationItem.rightBarButtonItem = btnPlay
        
        
        
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
        let decoder = FFmpegVideoDecoder(formatContext: handle.getFormatContext(), videoStreamIndex: handle.getVideoStreamIndex())
        decoder.delegate = self
        handle.startParseGetAVPacke { (isVideoFrame, isFinish, packet) in
            if isFinish{
                decoder.stop()
            }
            if isVideoFrame{
                decoder.startDecodeVideoData(with: packet)
            }
        }
    }
}

extension VideoBoxDecodeVideoViewController:SortFrameHandlerDelegate,VideoDecoderDelegate,FFmpegVideoDecoderDelegate{
    func getSortedVideoNode(_ videoDataRef: CMSampleBuffer) {
        
        
        let pts = Int(CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(videoDataRef)) * 1000)
        print("Test margin \(pts - VideoBoxDecodeVideoViewController.lastpts)")
        VideoBoxDecodeVideoViewController.lastpts = pts
        preview?.display(CMSampleBufferGetImageBuffer(videoDataRef)!)
        
        
    }
    func getVideoDecodeDataCallback(_ sampleBuffer: CMSampleBuffer, isFirstFrame: Bool) {
        let pix = CMSampleBufferGetImageBuffer(sampleBuffer)
        preview?.display(pix!)
        
    }
    
    func getDecodeVideoData(byFFmpeg sampleBuffer: CMSampleBuffer?) {
        if let sam = sampleBuffer{
            let pix = CMSampleBufferGetImageBuffer(sam)
            preview?.display(pix!)
        }
    }
}
