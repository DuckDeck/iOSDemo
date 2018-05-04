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

class CaptureSessionAssetWriterCoordinator {
    var videoDataOutputQueue:DispatchQueue!
    var audioDataOutputQueue:DispatchQueue!
    var videoDataOutput:AVCaptureVideoDataOutput!
    var audioDataOutput:AVCaptureAudioDataOutput!
    var audioConnection:AVCaptureConnection!
    var videoConnection:AVCaptureConnection!
    var videoCompressionSettings:[String:String]!
    var audioCompressionSettings:[String:String]!
    var assetWriter:AVAssetWriter!
    var recordingStatus = RecordingStatus.Idle
    var recordingURL:URL!
    var outputVideoFormatDescription:CMFormatDescription!
    var outputAudioFormatDescription:CMFormatDescription!
 
}
