//
//  CaptureSessionAssetWriterCoordinator.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
enum  RecordingStatus :Int{
    case Idle = 0,StartingRecording,Recoding,StopingRecording
}

class CaptureSessionAssetWriterCoordinator:CaptureSessionCoordinator {
    var videoDataOutputQueue:DispatchQueue!
    var audioDataOutputQueue:DispatchQueue!
    var videoDataOutput:AVCaptureVideoDataOutput!
    var audioDataOutput:AVCaptureAudioDataOutput!
    var audioConnection:AVCaptureConnection!
    var videoConnection:AVCaptureConnection!
    var videoCompressionSettings:[String:Any]!
    var audioCompressionSettings:[AnyHashable:Any]!
    var assetWriter:AVAssetWriter!
    var recordingStatus = RecordingStatus.Idle
    var recordingURL:URL!
    var outputVideoFormatDescription:CMFormatDescription!
    var outputAudioFormatDescription:CMFormatDescription!
    var assetWriterCoordinator:AssetWriterCoordinator!
    
    override init() {
        super.init()
        videoDataOutputQueue = DispatchQueue(label: "stahu.capturesession.videodata")
        videoDataOutputQueue.setTarget(queue: DispatchQueue.global())
        audioDataOutputQueue = DispatchQueue(label: "stanhu.capturesession.audiodata")
        addDataOutputsToCaptureSession(captureSession: self.captureSession)
    }
    
    override func startRecording() {
        
    }
    
    func addDataOutputsToCaptureSession(captureSession:AVCaptureSession) -> Void {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = nil
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput.setSampleBufferDelegate(self, queue: audioDataOutputQueue)
        _ = addOutput(output: videoDataOutput, captureSession: self.captureSession)
        videoConnection = videoDataOutput.connection(with: .video)
        _ = addOutput(output: audioDataOutput, captureSession: captureSession)
        audioConnection = audioDataOutput.connection(with: .audio)
        setCompressionSettings()
    }
    
    func setCompressionSettings() {
        videoCompressionSettings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: AVFileType.mov)
        audioCompressionSettings = audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: AVFileType.mov)
    }
    
    override func addOutput(output:AVCaptureOutput,captureSession:AVCaptureSession) -> Bool {
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
            return true
        }
        else{
            print("can't add output\(output.description)")
        }
        return false
    }
    
}

extension CaptureSessionAssetWriterCoordinator:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
   
}
