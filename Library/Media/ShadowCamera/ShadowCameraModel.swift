//
//  ShadowCameraModel.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/6/24.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
class ShadowCameraModel: NSObject {
    var previewView:UIView
    var preset:AVCaptureSession.Preset!
    var frameRate = 30
    var resolutionHeight = 1920
    var videoFormat:OSType
    var torchMode:AVCaptureDevice.TorchMode
    var focusMode:AVCaptureDevice.FocusMode
    var exposureMode:AVCaptureDevice.ExposureMode
    var flashMode:AVCaptureDevice.FlashMode
    var whiteBlackMode:AVCaptureDevice.WhiteBalanceMode
    var position:AVCaptureDevice.Position
    var videoGravity:AVLayerVideoGravity
    var videoOrientation:AVCaptureVideoOrientation
    var isEnableVideoStabilization:Bool
    
    init(previewView:UIView,
        preset:AVCaptureSession.Preset,
         frameRate:Int,
         resolutionHeight:Int,
         videoFormat:OSType,
         torchMode:AVCaptureDevice.TorchMode,
         focusMode:AVCaptureDevice.FocusMode,
         exposureMode:AVCaptureDevice.ExposureMode,
         flashMode:AVCaptureDevice.FlashMode,
         whiteBlackMode:AVCaptureDevice.WhiteBalanceMode,
         position:AVCaptureDevice.Position,
         videoGravity:AVLayerVideoGravity,
         videoOrientation:AVCaptureVideoOrientation,
         isEnableVideoStabilization:Bool) {
        self.previewView = previewView
        self.preset = preset
        self.frameRate = frameRate
        self.resolutionHeight = resolutionHeight
        self.videoFormat = videoFormat
        self.torchMode = torchMode
        self.focusMode = focusMode
        self.exposureMode = exposureMode
        self.flashMode = flashMode
        self.whiteBlackMode = whiteBlackMode
        self.position = position
        self.videoGravity = videoGravity
        self.videoOrientation = videoOrientation
        self.isEnableVideoStabilization = isEnableVideoStabilization
    }
}
