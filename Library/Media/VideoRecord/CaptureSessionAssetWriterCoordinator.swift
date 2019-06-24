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
    var audioCompressionSettings:[String:Any]!
    var recordingStatus = RecordingStatus.Idle
    var recordingURL:URL!
    var outputVideoFormatDescription:CMFormatDescription!
    var outputAudioFormatDescription:CMFormatDescription!
    var assetWriterCoordinator:AssetWriterCoordinator!
    var filePath:String!
    fileprivate override init() {
        super.init()
        videoDataOutputQueue = DispatchQueue(label: "stahu.capturesession.videodata", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: DispatchQueue.global())
        
        //        videoDataOutputQueue.setTarget(queue: DispatchQueue.global(qos: .default))
        audioDataOutputQueue = DispatchQueue(label: "stanhu.capturesession.audiodata")
        addDataOutputsToCaptureSession(captureSession: self.captureSession)
    }
    
    convenience init(filePath:String) {
        self.init()
        self.filePath = filePath
    }

    
    override func startRecording() {
        objc_sync_enter(self)
        if recordingStatus != .Idle{
            NSException(name: NSExceptionName.invalidArgumentException, reason: "Already recording", userInfo: nil).raise()
            return
        }
        transitionToRecordingStatus(newStatus: .StartingRecording, error: nil)
        objc_sync_exit(self)
        recordingURL = URL(fileURLWithPath: filePath)
        assetWriterCoordinator = AssetWriterCoordinator(theUrl: recordingURL)
        if outputAudioFormatDescription != nil{
            assetWriterCoordinator.addAudioTrackWithSourceFormatDescription(formatDescription: outputAudioFormatDescription, audioSettings:  audioCompressionSettings)
        }
        assetWriterCoordinator.addVideoTrackWithSourceFormatDescription(formatDescription: outputVideoFormatDescription, videoSettings: videoCompressionSettings)
        let callbackQueue = DispatchQueue(label: "stanhu.capturesession.writercallback")
        assetWriterCoordinator.setDelegate(delegate: self, callbackQueue: callbackQueue)
        assetWriterCoordinator.prepareToRecord()
    }
    
    override func stopRecording() {
        objc_sync_enter(self)
        if recordingStatus != .Recoding{
            return
        }
        transitionToRecordingStatus(newStatus: .StopingRecording, error: nil)
        objc_sync_exit(self)
        assetWriterCoordinator.finishRecording()
    }
    
    func addDataOutputsToCaptureSession(captureSession:AVCaptureSession) -> Void {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = nil
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:NSNumber(value: cameraModel.videoFormat)] as [String : Any]
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput.setSampleBufferDelegate(self, queue: audioDataOutputQueue)
        _ = addOutput(output: videoDataOutput, captureSession: captureSession)
        videoConnection = videoDataOutput.connection(with: .video)
        _ = addOutput(output: audioDataOutput, captureSession: captureSession)
        audioConnection = audioDataOutput.connection(with: .audio)
        setCompressionSettings()
    }
    
    func setCompressionSettings() {
        videoCompressionSettings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: AVFileType.mov)
        audioCompressionSettings = audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: AVFileType.mov) as? [String : Any]
    }
    
    func setupVideoPipelineWithInputFormatDescription(inputFormatDescription:CMFormatDescription) {
        outputVideoFormatDescription = inputFormatDescription
    }
    
    func teardownVideoPipeline() {
        outputVideoFormatDescription = nil
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
    
    func transitionToRecordingStatus(newStatus:RecordingStatus,error:Error?) -> Void {
        let oldStatus = recordingStatus
        recordingStatus = newStatus
        if newStatus != oldStatus{
            if error != nil && newStatus == .Idle{
                self.delegateCallbackQueue.async {
                    autoreleasepool(invoking: {
                        self.delegate?.coordinator(coordinator: self, outputFileUrl: self.recordingURL, error: error)
                    })
                }
            }
            else{
                if oldStatus == .StartingRecording && newStatus == .Recoding{
                    self.delegateCallbackQueue.async {
                        autoreleasepool(invoking: {
                            self.delegate?.coordinatorDidBeginRecording(coordinator: self)
                        })
                    }
                }
                else if oldStatus == .StopingRecording && newStatus == .Idle{
                    self.delegateCallbackQueue.async {
                        autoreleasepool(invoking: {
                            self.delegate?.coordinator(coordinator: self, outputFileUrl: self.recordingURL, error: nil)
                        })
                    }
                }
            }
        }
    }
    
}

extension CaptureSessionAssetWriterCoordinator:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AssetWriterCoordinatorDelegate{
    func writerCoordinator(coordinator: AssetWriterCoordinator, error: Error?) {
        objc_sync_enter(self)
        assetWriterCoordinator = nil
        transitionToRecordingStatus(newStatus: .Idle, error: error)
        objc_sync_exit(self)

    }
    
    func writerCoordinatorDidFinishPreparing(coordinator: AssetWriterCoordinator) {
        objc_sync_enter(self)
        if recordingStatus != .StartingRecording{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Expected to be in StartingRecording state", userInfo: nil).raise()
            return
        }
        transitionToRecordingStatus(newStatus: .Recoding, error: nil)
        objc_sync_exit(self)
    }

    
    func writerCoordinatorDidFinishRecording(coordinator: AssetWriterCoordinator) {
        objc_sync_enter(self)
        if recordingStatus != .StopingRecording{
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Expected to be in StartingRecording state", userInfo: nil).raise()
            return
        }
        objc_sync_exit(self)
        assetWriterCoordinator = nil
        objc_sync_enter(self)
        transitionToRecordingStatus(newStatus: .Idle, error: nil)
        objc_sync_exit(self)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard  let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else{
            return
        }
        if connection == videoConnection{
            if outputVideoFormatDescription == nil{
                setupVideoPipelineWithInputFormatDescription(inputFormatDescription: formatDescription)
            }
            else{
                outputVideoFormatDescription = formatDescription
            }
            objc_sync_enter(self)
            if recordingStatus == .Recoding{
                assetWriterCoordinator.appendVideoSampleBuffer(sampleBuffer: sampleBuffer)
            }
            objc_sync_exit(self)
        }
        else if connection == audioConnection{
            outputAudioFormatDescription = formatDescription
            objc_sync_enter(self)
            if recordingStatus == .Recoding{
                assetWriterCoordinator.appendAudioSampleBuffer(sampleBuffer:  sampleBuffer)
            }
            objc_sync_exit(self)
        }
    }
   
}
