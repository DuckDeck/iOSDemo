//
//  AssetWriterCoordinator.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
enum WriterStatus:Int{
    case Idle = 0,
    PreparingToRecord,
    Recording,
    FinishingRecordingPart1, // waiting for inflight buffers to be appended
    FinishingRecordingPart2, // calling finish writing on the asset writer
    Finished,
    Failed
}
protocol AssetWriterCoordinatorDelegate :class {
    func writerCoordinatorDidFinishPreparing(coordinator:AssetWriterCoordinator)
    func writerCoordinator(coordinator:AssetWriterCoordinator,error:Error?)
    func writerCoordinatorDidFinishRecording(coordinator:AssetWriterCoordinator)
}
class AssetWriterCoordinator{
    weak var delegate:AssetWriterCoordinatorDelegate?
    var status = WriterStatus.Idle
    var writingQueue:DispatchQueue!
    var delegateCallbackQueue:DispatchQueue!
    var url:URL!
    var assetWriter:AVAssetWriter!
    var haveStartedSession = false
    var audioTrackSourceFormatDescription:CMFormatDescription!
    var audioTrackSettings:[String:Any]!
    var audioInput:AVAssetWriterInput!
    var videoTrackSourceFormatDescription:CMFormatDescription!
    var videoTrackTransform:CGAffineTransform!
    var videoTrackSettings:[String:Any]!
    var videoInput:AVAssetWriterInput!
    init(theUrl:URL) {
        writingQueue = DispatchQueue(label: "stanhu.assetwriter.writing")
        videoTrackTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        url = theUrl
    }
    
    func addVideoTrackWithSourceFormatDescription(formatDescription:CMFormatDescription?,videoSettings:[String:Any]) {
        guard let des = formatDescription else {
            NSException(name: NSExceptionName.invalidArgumentException, reason: "NULL format description", userInfo: nil).raise()
            return
        }
        objc_sync_enter(self)
        if status != .Idle{
             NSException(name: NSExceptionName.internalInconsistencyException, reason: "Cannot add tracks while not idle", userInfo: nil).raise()
            return
        }
        if videoTrackSourceFormatDescription != nil{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Cannot add more than one video track", userInfo: nil).raise()
        }
        videoTrackSourceFormatDescription = des
        self.videoTrackSettings = videoSettings
        objc_sync_exit(self)
    }
    func addAudioTrackWithSourceFormatDescription(formatDescription:CMFormatDescription?,audioSettings:[String:Any]) {
        guard let des = formatDescription else {
            NSException(name: NSExceptionName.invalidArgumentException, reason: "NULL format description", userInfo: nil).raise()
            return
        }
        objc_sync_enter(self)
        if status != .Idle{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Cannot add tracks while not idle", userInfo: nil).raise()
            return
        }
        if audioTrackSourceFormatDescription != nil{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Cannot add more than one video track", userInfo: nil).raise()
        }
        audioTrackSourceFormatDescription = des
        self.audioTrackSettings = audioSettings
        objc_sync_exit(self)
    }
    
    func setDelegate(delegate:AssetWriterCoordinatorDelegate,callbackQueue:DispatchQueue)  {
        objc_sync_enter(self)
        self.delegate = delegate
        if self.delegateCallbackQueue == nil{
            self.delegateCallbackQueue = callbackQueue
        }
        if self.delegateCallbackQueue != nil && self.delegateCallbackQueue != callbackQueue{
            self.delegateCallbackQueue = callbackQueue
        }
        objc_sync_exit(self)
    }
    func prepareToRecord() {
        objc_sync_enter(self)
        if status != .Idle{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Cannot add tracks while not idle", userInfo: nil).raise()
            return
        }
        self.transitionToStatus(newStatus: .PreparingToRecord,error: nil)
        objc_sync_exit(self)
        DispatchQueue.global().async {
            autoreleasepool(invoking: {
                do{
                    if FileManager.default.fileExists(atPath: self.url.absoluteString){
                        try FileManager.default.removeItem(at: self.url)
                    }
                    
                    self.assetWriter = try AVAssetWriter(url: self.url, fileType: AVFileType.mov) // 用mp3
                    var setupSuccess = false
                    if self.videoTrackSourceFormatDescription != nil && self.audioTrackSourceFormatDescription != nil{
                       setupSuccess =  self.setupAssetWriterVideoInputWithSourceFormatDescription(videoFormatDescription: self.videoTrackSourceFormatDescription, transform: self.videoTrackTransform, videoSettings: self.videoTrackSettings) &&  self.setupAssetWriterAudioInputWithSourceFormatDescription(audioFormatDescription: self.audioTrackSourceFormatDescription, audioSettings: self.audioTrackSettings)
                    }
                   
                    if setupSuccess{
                         setupSuccess = self.assetWriter.startWriting()
                    }
                    
                    objc_sync_enter(self)
                    if !setupSuccess{
                        self.transitionToStatus(newStatus: .Failed,error: NSError(domain: "Cannot setup asset writer input ", code: 0, userInfo: nil))
                    }
                    else{
                         print("6")
                        self.transitionToStatus(newStatus: .Recording,error: nil)
                    }
                    objc_sync_exit(self)
                }
                catch{
                    self.transitionToStatus(newStatus: .Failed,error: error)
                }
            })
        }
    }
    
    func appendVideoSampleBuffer(sampleBuffer:CMSampleBuffer)  {
        self.appendSampleBuffer(sampleBuffer: sampleBuffer, mediaType: AVMediaType.video)
    }
    func appendAudioSampleBuffer(sampleBuffer:CMSampleBuffer)  {
         self.appendSampleBuffer(sampleBuffer: sampleBuffer, mediaType: AVMediaType.audio)
    }
    func finishRecording() {
        objc_sync_enter(self)
        var shouldFinishRecording = false
        switch status {
        case .Idle,.PreparingToRecord,.FinishingRecordingPart1,.FinishingRecordingPart2,.Finished:
             NSException(name: NSExceptionName.internalInconsistencyException, reason: "Not recording", userInfo: nil).raise()
        case .Failed:
            print("Recording has failed, nothing to do")
            break
        case .Recording:
            shouldFinishRecording = true
        }
        if shouldFinishRecording{
            self.transitionToStatus(newStatus: .FinishingRecordingPart1,error: nil)
        }
        else{
            return
        }
        objc_sync_exit(self)
        writingQueue.async {
            autoreleasepool(invoking: {
                  objc_sync_enter(self)
                if self.status != .FinishingRecordingPart1{
                    return
                }
                self.transitionToStatus(newStatus: .FinishingRecordingPart2,error: nil)
                  objc_sync_exit(self)
                self.assetWriter.finishWriting(completionHandler: {
                    if let err =  self.assetWriter.error{
                        self.transitionToStatus(newStatus: .Failed,error: err)
                    }
                    else{
                        self.transitionToStatus(newStatus: .Finished,error: nil)
                    }
                })
            })
        }
    }
    
    func appendSampleBuffer(sampleBuffer:CMSampleBuffer,mediaType:AVMediaType)  {
        objc_sync_enter(self)
        if status.rawValue < RecordingStatus.Recoding.rawValue{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Not ready to record yet", userInfo: nil).raise()
            return
        }
        objc_sync_exit(self)
        writingQueue.async {
            objc_sync_enter(self)
            if self.status.rawValue > WriterStatus.FinishingRecordingPart1.rawValue{
                return
            }
            objc_sync_exit(self)
            if !self.haveStartedSession && mediaType == .video{
                self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                self.haveStartedSession = true
            }
            let input = mediaType == .video ? self.videoInput : self.audioInput
            if input!.isReadyForMoreMediaData{
                let success = input!.append(sampleBuffer)
                if !success{
                    objc_sync_enter(self)
                    self.transitionToStatus(newStatus: .Failed,error: self.assetWriter.error!)
                    objc_sync_exit(self)
                }
            }else{
                print("\(mediaType)input not ready for more media data, dropping buffer")
            }
        }
    }
    
    func setupAssetWriterVideoInputWithSourceFormatDescription(videoFormatDescription:CMFormatDescription,transform:CGAffineTransform,videoSettings:[String:Any]?) -> Bool {
        var settings = videoSettings
        if settings == nil || settings!.count <= 0{
            settings = fallbackVideoSettingsForSourceFormatDescription(videoFormatDescription: videoFormatDescription)
        }
        if assetWriter.canApply(outputSettings: settings!, forMediaType: AVMediaType.video){
            videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: settings!, sourceFormatHint: videoFormatDescription)
            videoInput.expectsMediaDataInRealTime = true
            videoInput.transform = transform
            if assetWriter.canAdd(videoInput){
                assetWriter.add(videoInput)
            }
            else{
                return false
            }
        }
        else{
            return false
        }
        return true
    }
    
    func setupAssetWriterAudioInputWithSourceFormatDescription(audioFormatDescription:CMFormatDescription,audioSettings:[String:Any]?) -> Bool {
        var settings = audioSettings
        if settings == nil || settings!.count <= 0{
            settings = [AVFormatIDKey:kAudioFormatMPEGLayer3] //这里用了mp3
        }
        if assetWriter.canApply(outputSettings: settings!, forMediaType: AVMediaType.audio){
            audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: settings!, sourceFormatHint: audioFormatDescription)
            audioInput.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(audioInput){
                assetWriter.add(audioInput)
            }
            else{
                return false
            }
        }
        else{
            return false
        }
        return true

    }
    
    func fallbackVideoSettingsForSourceFormatDescription(videoFormatDescription:CMFormatDescription) ->[String:Any] {
        var bitsPerPixel:Float = 0
        let dimensions = CMVideoFormatDescriptionGetDimensions(videoFormatDescription)
        let numPixels = dimensions.width * dimensions.height
        var bitsPerSecond:Float = 0
        print("no video settings provided, using default settings")
        if numPixels < (640 * 480){
            bitsPerPixel = 4.05 // This bitrate approximately matches the quality produced by AVCaptureSessionPresetMedium or Low.
        }
        else{
            bitsPerPixel = 10.1
        }
        bitsPerSecond = Float(numPixels) * bitsPerPixel
        return [AVVideoAverageBitRateKey:bitsPerSecond,AVVideoExpectedSourceFrameRateKey:30,AVVideoMaxKeyFrameIntervalKey:30]
    }
    
    func transitionToStatus(newStatus:WriterStatus,error:Error?)  {
        var shouldNotifyDelegate = false
        if status != newStatus{
            // terminal states
            if newStatus == .Finished || newStatus == .Failed{
                shouldNotifyDelegate = true
                writingQueue.async {
                    self.assetWriter = nil
                    self.videoInput = nil
                    self.audioInput = nil
                    if newStatus == .Failed{
                       try? FileManager.default.removeItem(at: self.url)
                    }
                }
            }
            else if newStatus == .Recording{
                shouldNotifyDelegate = true
            }
            self.status = newStatus
        }
        if shouldNotifyDelegate && self.delegate != nil{
            delegateCallbackQueue.async {
                 autoreleasepool( invoking: {
                    switch newStatus{
                        case .Recording: self.delegate?.writerCoordinatorDidFinishPreparing(coordinator: self)
                        case .Finished:self.delegate?.writerCoordinatorDidFinishRecording(coordinator: self)
                        case.Failed:  self.delegate?.writerCoordinator(coordinator: self, error: error)
                        default:break
                    }
                })
            }
        }
    }
}
