//
//  ShadowCameraHandle.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/6/24.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
protocol ShadowCameraHandleDelegate:class {
    func captureOutput(output:AVCaptureOutput,didOutput sampleBuffer:CMSampleBuffer,from connection:AVCaptureConnection)
    func captureOutput(output:AVCaptureOutput,didDrop sampleBuffer:CMSampleBuffer,from connection:AVCaptureConnection)
}
class ShadowCameraHandle: NSObject {
    weak var delegate:ShadowCameraHandleDelegate?
    var cameraModel:ShadowCameraModel!
    var session:AVCaptureSession!
    var input:AVCaptureDeviceInput!
    var videoDataOutput:AVCaptureVideoDataOutput!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    
    var capptureVideoFPS = 60
    var realTimeResolutionWidth = 1080
    var realTimeResolutionHeight = 1920
    
    var count = 0
    var lastTime:Float = 0
    
    
    
    
    func startRunning() {
        session.startRunning()
    }
    
    func stopRunning() {
        session.stopRunning()
    }
    
    func configureCamera(model:ShadowCameraModel)  {
        let session = AVCaptureSession()
        session.sessionPreset = model.preset
        guard let device = ShadowCameraHandle.getCaptureDeviceFromPosition(position: model.position) else{
            return
        }
        _ = ShadowCameraHandle.setCameraFrameRateAndResolution(frameRate: model.frameRate, resolutionHeight: model.resolutionHeight, session: session, position: model.position, videoFormat: model.videoFormat)
        
        if device.hasTorch{
            do{
                try device.lockForConfiguration()
                if device.isTorchModeSupported(cameraModel.torchMode){
                    device.torchMode = cameraModel.torchMode
                    device.addObserver(self, forKeyPath: "torchMode", options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
                }
                else{
                    print("The device not support the current torch mode \(cameraModel.torchMode)")
                }
                device.unlockForConfiguration()
            }
            catch{
                print(error.localizedDescription)
            }
        }
        
        if device.isFocusModeSupported(cameraModel.focusMode){
            let autoFocusPoint = CGPoint(x: 0.5,y: 0.5)
            do{
                try device.lockForConfiguration()
                device.focusPointOfInterest = autoFocusPoint
                device.focusMode = cameraModel.focusMode
                device.unlockForConfiguration()
            }
            catch{
                print(error.localizedDescription)
            }
        }
        else{
            print("The device not support focus mode \(cameraModel.focusMode)")
        }
        
        
        if device.isExposureModeSupported(cameraModel.exposureMode){
            let exposurePoint = CGPoint(x: 0.5,y: 0.5)
            do{
                try device.lockForConfiguration()
                device.exposurePointOfInterest = exposurePoint
                device.exposureMode = cameraModel.exposureMode
                device.unlockForConfiguration()
            }
            catch{
                print(error.localizedDescription)
            }
            
        }
        else{
            print("The device not support exposure mode \(cameraModel.exposureMode)")
        }
        
        if device.hasFlash{
            if #available(iOS 10.0, *){
                let outputs = session.outputs
                for output in outputs{
                    if output is AVCapturePhotoOutput{
                        let photoOutput = output as! AVCapturePhotoOutput
                        let flashSupported = photoOutput.supportedFlashModes.contains(cameraModel.flashMode)
                        if flashSupported{
                            let photoSettings = photoOutput.photoSettingsForSceneMonitoring
                            photoSettings?.flashMode = AVCaptureDevice.FlashMode.auto
                        }
                        else{
                            print("The device not support current flash mode \(cameraModel.flashMode)")
                        }
                    }
                }
            }
            else{
                if device.isFlashModeSupported(cameraModel.flashMode){
                    device.flashMode = cameraModel.flashMode
                }
                else{
                    print("The device not support current flash mode \(cameraModel.flashMode)")
                }
            }
        }
        else{
            print("The device not support flash")
        }
        
        if device.isWhiteBalanceModeSupported(cameraModel.whiteBlackMode){
            do{
                try device.lockForConfiguration()
                device.whiteBalanceMode = cameraModel.whiteBlackMode
                device.unlockForConfiguration()
            }
            catch{
                print(error.localizedDescription)
            }
            
        }
        else{
            print("The device not support current whiteBlackmode \(cameraModel.exposureMode)")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device) else{
            print("Configure device input failed")
            return
        }
        session.addInput(deviceInput)
        let videoDataOutput = AVCaptureVideoDataOutput()
        session.addOutput(videoDataOutput)
        
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey:model.videoFormat] as [String : Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        let videoQueue = DispatchQueue(label: "videoQueue")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if model.isEnableVideoStabilization{
            adjustVideoStabilizationWithOutput(output: videoDataOutput)
        }
        let previewViewLayer = model.previewView.layer
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewViewLayer.backgroundColor = UIColor.black.cgColor
        let frame = previewViewLayer.bounds
        print("previewViewLayer = \(frame)")
        videoPreviewLayer.frame = model.previewView.frame
        videoPreviewLayer.videoGravity = model.videoGravity
        if videoPreviewLayer.connection?.isVideoOrientationSupported ?? false{
            videoPreviewLayer.connection?.videoOrientation = model.videoOrientation
        }
        else{
            print("Not support video Orientation!")
        }
        previewViewLayer.insertSublayer(videoPreviewLayer, at: 0)
        self.input = deviceInput
        self.cameraModel = model
        self.session = session
        self.videoDataOutput = videoDataOutput
        self.videoPreviewLayer = videoPreviewLayer
        
        
    }
    
    func switchCamera()  {
        let newPosition = input.device.position == AVCaptureDevice.Position.back ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        cameraModel.position = newPosition
        
        setCameraPosition(position: newPosition, session: self.session, input: self.input, videoFormat: cameraModel.videoFormat, resolutionHeight: cameraModel.resolutionHeight, frameRate: cameraModel.frameRate)
    }
    
    func setCameraResolutionByActiveFormatWithHeight(height:Int)  {
        let maxResolutionHeight = getMaxSupportResolutionByActiveFormat()
        var tmpHeight = height
        if height > maxResolutionHeight{
            tmpHeight = maxResolutionHeight
        }
        cameraModel.resolutionHeight = tmpHeight
        _ = ShadowCameraHandle.setCameraFrameRateAndResolution(frameRate: cameraModel.frameRate, resolutionHeight: tmpHeight, session: session, position: cameraModel.position, videoFormat: cameraModel.videoFormat)
    }
    
    
    func setCameraForHFRWithFrameRate(frameRate:Int)  {
        let maxFrameRate = getMaxFrameRateByCurrentResolution()
        var tmpFrameRate = frameRate
        if frameRate > maxFrameRate{
            tmpFrameRate = maxFrameRate
        }
        cameraModel.frameRate = tmpFrameRate
        _ = ShadowCameraHandle.setCameraFrameRateAndResolution(frameRate: tmpFrameRate, resolutionHeight: cameraModel.resolutionHeight, session: session, position: cameraModel.position, videoFormat: cameraModel.videoFormat)
    }
    
    func getMaxSupportResolutionByActiveFormat() -> Int {
        return  getDeviceSupportMaxResolutionByFrameRate(frameRate: cameraModel.frameRate, position: cameraModel.position, videoFormat: cameraModel.videoFormat)
    }
    
    var CaptureVideoFPS:Int{
        get{
            return capptureVideoFPS
        }
    }
    
    var MaxExposureValue:Float{
        return input.device.maxExposureTargetBias
    }
    
    var MinExposureValue:Float{
        return input.device.minExposureTargetBias
    }
    
    func setExposure(value:Float)  {
        setExposure(value: value, device: input.device)
    }
    
    //proced
    func setTorchState(isOpen:Bool)  {
        setTorchState(isOpen: isOpen, device: input.device)
    }
    
    func adjustVideoOrientationByScreenOrientation(orientation:UIDeviceOrientation)  {
        adjustVideoOrientationByScreenOrientation(orientation: orientation, previewFrame: cameraModel.previewView.frame, previewLayer: videoPreviewLayer, videoOutput: videoDataOutput)
    }
    
    func setVideoGravity(videoGravity:AVLayerVideoGravity)   {
        setVideoGravity(gravity: videoGravity, previewLayer: videoPreviewLayer, session: session)
    }
    
    func setWhiteBlanceValueByTemperature(temperature:Float) {
        setWhiteBlanceValueByTemperature(temperature: temperature, device: input.device)
    }
    
    func setWhiteBlanceValueByTint(tint:Float) {
        setWhiteBlanceValueByTint(tint: tint, device: input.device)
    }
    
    var RealTimeResolutionWidth:Int{
        return realTimeResolutionWidth
    }
    
    var RealTimeResolutionHeight:Int{
        return realTimeResolutionHeight
    }
    
    func setFocusPoint(point:CGPoint){
        if input.device.isFocusPointOfInterestSupported{
            let convertFocusPoint = convertToPointOfInterestFromViewCoordinates(viewCoordinates: point, captureVideoPreviewLayer: videoPreviewLayer)
            autoFocusAtFocus(point: convertFocusPoint)
        }
        else{
            print("Current device not support focus")
        }
    }
    
    func autoFocusAtFocus(point:CGPoint) {
        let device = input.device
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus){
            do{
                try device.lockForConfiguration()
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
            }
            catch{
                print("lock device fail\(error.localizedDescription)")
            }
        }
    }
    
    func convertToPointOfInterestFromViewCoordinates(viewCoordinates:CGPoint,captureVideoPreviewLayer:AVCaptureVideoPreviewLayer) -> CGPoint {
        var pointOfInterest = CGPoint(x: 0.5, y: 0.5)
        let frameSize = captureVideoPreviewLayer.frame.size
        var coor = viewCoordinates
        if captureVideoPreviewLayer.connection!.isVideoMirrored{
            coor.x = frameSize.width - viewCoordinates.x
        }
        pointOfInterest = captureVideoPreviewLayer.captureDevicePointConverted(fromLayerPoint: coor)
        return pointOfInterest
    }
    
    func setExposure(value:Float,device:AVCaptureDevice)  {
        do{
            try device.lockForConfiguration()
            device.setExposureTargetBias(value, completionHandler: nil)
            device.unlockForConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func setTorchState(isOpen:Bool,device:AVCaptureDevice)  {
        if device.hasTorch{
            do{
                try device.lockForConfiguration()
                device.torchMode = isOpen ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
                device.unlockForConfiguration()
            }
            catch{
                print(error.localizedDescription)
            }
        }
        else{
            print("The device not support torch!")
        }
    }
    
    func adjustVideoOrientationByScreenOrientation(orientation:UIDeviceOrientation,previewFrame:CGRect,previewLayer:AVCaptureVideoPreviewLayer,videoOutput:AVCaptureVideoDataOutput){
        previewLayer.frame = previewFrame
        switch orientation {
        case .portrait:
            adjustAVOutputDataOrientation(orientation: .portrait, videoOutput: videoOutput)
        case .portraitUpsideDown:
            adjustAVOutputDataOrientation(orientation: .portraitUpsideDown, videoOutput: videoOutput)
        case .landscapeLeft:
            previewLayer.connection?.videoOrientation = .landscapeLeft
            adjustAVOutputDataOrientation(orientation: .landscapeLeft, videoOutput: videoOutput)
        case .landscapeRight:
            previewLayer.connection?.videoOrientation = .landscapeRight
            adjustAVOutputDataOrientation(orientation: .landscapeRight, videoOutput: videoOutput)
        default:
            break
        }
    }
    
    func adjustAVOutputDataOrientation(orientation:AVCaptureVideoOrientation,videoOutput:AVCaptureVideoDataOutput)  {
        for connection in videoOutput.connections{
            for port in connection.inputPorts{
                if port.mediaType == AVMediaType.video{
                    if connection.isVideoOrientationSupported{
                        connection.videoOrientation = orientation
                    }
                }
            }
        }
    }
    
    func setVideoGravity(gravity:AVLayerVideoGravity,previewLayer:AVCaptureVideoPreviewLayer,session:AVCaptureSession)  {
        session.beginConfiguration()
        previewLayer.videoGravity = gravity
        session.commitConfiguration()
    }
    
    func setWhiteBlanceValueByTemperature(temperature:Float,device:AVCaptureDevice)  {
        if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.locked){
            do{
                try device.lockForConfiguration()
                let currentGains = device.deviceWhiteBalanceGains
                let currentTint = device.temperatureAndTintValues(for: currentGains).tint
                let tmpAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: temperature, tint: currentTint)
                var deviceGains = device.deviceWhiteBalanceGains(for: tmpAndTintValues)
                let maxWhiteBalanceGain = device.maxWhiteBalanceGain
                deviceGains = clampGains(gains: deviceGains, minValue: 1, maxValue: maxWhiteBalanceGain)
                device.setWhiteBalanceModeLocked(with: deviceGains, completionHandler: nil)
                device.unlockForConfiguration()
                
            }
            catch{
                print(error.localizedDescription)
            }
        }
        else{
            print("device do not support sWhiteBalanceMode")
        }
    }
    
    func setWhiteBlanceValueByTint(tint:Float,device:AVCaptureDevice) {
        if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.locked){
            do{
                try device.lockForConfiguration()
                let maxWhiteBalanceGain = device.maxWhiteBalanceGain
                var currentGains = device.deviceWhiteBalanceGains
                currentGains = clampGains(gains: currentGains, minValue: 1, maxValue: maxWhiteBalanceGain)
                let currentTemperature = device.temperatureAndTintValues(for: currentGains).temperature
                let tmpAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: currentTemperature, tint: tint)
                var deviceGains = device.deviceWhiteBalanceGains(for: tmpAndTintValues)
                deviceGains = clampGains(gains: deviceGains, minValue: 1, maxValue: maxWhiteBalanceGain)
                device.setWhiteBalanceModeLocked(with: deviceGains, completionHandler: nil)
                device.unlockForConfiguration()
                
            }
            catch{
                print(error.localizedDescription)
            }
        }
        else{
            print("device do not support sWhiteBalanceMode")
        }
    }
    
    func clampGains(gains:AVCaptureDevice.WhiteBalanceGains,minValue:Float,maxValue:Float) -> AVCaptureDevice.WhiteBalanceGains {
        var tmpGains = gains
        tmpGains.blueGain = max(min(tmpGains.blueGain, maxValue), minValue)
        tmpGains.redGain = max(min(tmpGains.redGain, maxValue), minValue)
        tmpGains.greenGain = max(min(tmpGains.greenGain, maxValue), minValue)
        return tmpGains
    }
    
    func setCameraPosition(position:AVCaptureDevice.Position,session:AVCaptureSession,input:AVCaptureDeviceInput,videoFormat:OSType,resolutionHeight:Int,frameRate:Int) {
        session.beginConfiguration()
        session.removeInput(input)
        guard let device = CaptureSessionCoordinator.getCaptureDeviceFromPosition(position: position) else {
            return
        }
        var newInput:AVCaptureDeviceInput!
        do{
            newInput = try AVCaptureDeviceInput(device: device)
        }
        catch{
            print(error.localizedDescription)
            return
        }
        session.sessionPreset = AVCaptureSession.Preset.low
        if session.canAddInput(newInput){
            session.addInput(newInput)
        }
        else{
            print("add new input fail")
        }
        let maxResolutionHeight = getMaxSupportResolutionByPreset()
        if resolutionHeight > maxResolutionHeight{
            cameraModel.resolutionHeight = maxResolutionHeight
        }
        
        let maxFrameRate = getMaxFrameRateByCurrentResolution()
        if frameRate > maxFrameRate{
            cameraModel.frameRate = maxFrameRate
        }
        //self.input = newInput
        let isSuccess = CaptureSessionCoordinator.setCameraFrameRateAndResolution(frameRate: frameRate, resolutionHeight: resolutionHeight, session: session, position: position, videoFormat: videoFormat)
        
        if !isSuccess{
            print("Set resolution and frame fail")
        }
        
        session.commitConfiguration()
        
        
        
        
    }
    
    func adjustVideoStabilizationWithOutput(output:AVCaptureVideoDataOutput)  {
        let devices:[AVCaptureDevice]!
        if #available(iOS 10.0, *) {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: cameraModel.position)
            devices = deviceDiscoverySession.devices
        }
        else{
            devices = AVCaptureDevice.devices(for: .video)
        }
        for device in devices{
            if device.hasMediaType(.video){
                if device.activeFormat.isVideoStabilizationModeSupported(.auto){
                    for connection in output.connections{
                        for port in connection.inputPorts{
                            if port.mediaType == .video{
                                if connection.isVideoStabilizationSupported{
                                    connection.preferredVideoStabilizationMode = .standard
                                    print("activeVideoStabilizationMode = \(connection.activeVideoStabilizationMode)")
                                }
                                else{
                                     print("connection don't support video stabilization")
                                }
                            }
                        }
                    }
                }
                else{
                    print("device don't support video stablization")
                }
            }
        }
    }
    
    func getMaxFrameRateByCurrentResolution()->Int {
        return ShadowCameraHandle.getMaxFrameRateByCurrentResolutionWithResolutionHeight(resolutionHeight: cameraModel.resolutionHeight, position: cameraModel.position, videoFormat: cameraModel.videoFormat)
    }
    
    func getMaxSupportResolutionByPreset() -> Int {
        if session.canSetSessionPreset(.hd4K3840x2160){
            return 2160
        }
        else if session.canSetSessionPreset(.hd1920x1080){
            return 1080
        }
        else if session.canSetSessionPreset(.hd1280x720){
            return 720
        }
        else if session.canSetSessionPreset(.vga640x480){
            return 480
        }
        else if session.canSetSessionPreset(.cif352x288){
            return 288
        }
        return -1
        
    }
    
    
    func getDeviceSupportMaxResolutionByFrameRate(frameRate:Int,position:AVCaptureDevice.Position,videoFormat:OSType) -> Int {
        var maxResolutionHeight = 0
        guard let captureDevice = ShadowCameraHandle.getCaptureDeviceFromPosition(position: position) else {
            return maxResolutionHeight
        }
        for vFormat in captureDevice.formats{
            let des = vFormat.formatDescription
            let maxRate = vFormat.videoSupportedFrameRateRanges.first!.maxFrameRate
            let dims = CMVideoFormatDescriptionGetDimensions(des)
            if CMFormatDescriptionGetMediaSubType(des) == videoFormat && frameRate <= Int(maxRate){
                if ShadowCameraHandle.getResolutionWidthByHeight(height: Int(dims.height)) == dims.width{
                    maxResolutionHeight = Int(dims.height)
                }
            }
        }
        return maxResolutionHeight
    }
    
    func calculatorCaptureFPS() {
        let hostClockRef = CMClockGetHostTimeClock()
        let hostTime = CMClockGetTime(hostClockRef)
        let nowTime = CMTimeGetSeconds(hostTime)
        if nowTime - lastTime >= 1{
            capptureVideoFPS = count
            lastTime = Float(nowTime)
            count = 0
        }
        else{
            count += 1
        }
    }
    
    static func getCaptureDeviceFromPosition(position:AVCaptureDevice.Position)->AVCaptureDevice?{
        let devices:[AVCaptureDevice]!
        if #available(iOS 10.0, *) {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: position)
            devices = deviceDiscoverySession.devices
        }
        else{
            devices = AVCaptureDevice.devices(for: .video)
        }
        for dev in devices{
            if position == dev.position{
                return dev
            }
        }
        return nil
    }
    
    static func setCameraFrameRateAndResolution(frameRate:Int,resolutionHeight:Int,session:AVCaptureSession,position:AVCaptureDevice.Position,videoFormat:OSType) -> Bool {
        guard let device = getCaptureDeviceFromPosition(position: position) else {
            return false
        }
        var isSuccess = false
        for vformat in device.formats{
            let description = vformat.formatDescription
            let maxRate = vformat.videoSupportedFrameRateRanges.first!.maxFrameRate
            if maxRate >= Float64(frameRate) && CMFormatDescriptionGetMediaType(description) == videoFormat{
                do{
                    try device.lockForConfiguration()
                    let dims = CMVideoFormatDescriptionGetDimensions(description)
                    if dims.height == resolutionHeight && dims.width == getResolutionWidthByHeight(height: resolutionHeight){
                        session.beginConfiguration()
                        device.activeFormat = vformat
                        device.activeVideoMinFrameDuration = CMTime(seconds: 1, preferredTimescale: CMTimeScale(frameRate))
                        device.activeVideoMaxFrameDuration = CMTime(seconds: 1, preferredTimescale: CMTimeScale(frameRate))
                        device.unlockForConfiguration()
                        session.commitConfiguration()
                        isSuccess = true
                    }
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }
        return isSuccess
    }
    
    static func getResolutionWidthByHeight(height:Int)->Int{
        switch height {
        case 2160:
            return 3840
        case 1080:
            return 1920
        case 720:
            return 1280
        case 480:
            return 640
        case 3840:
            return 2160
        case 1920:
            return 1080
        case 1280:
            return 720
        case 640:
            return 480
        default:
            return -1
        }
    }
    
    static func getMaxFrameRateByCurrentResolutionWithResolutionHeight(resolutionHeight:Int,position:AVCaptureDevice.Position,videoFormat:OSType)->Int{
        var maxFrameRate = 0
        guard let captureDevice = getCaptureDeviceFromPosition(position: position) else{
            return -1
        }
        for format in captureDevice.formats{
            let desc = format.formatDescription
            let dims = CMVideoFormatDescriptionGetDimensions(desc)
            if CMFormatDescriptionGetMediaType(desc) == videoFormat && dims.height == resolutionHeight && dims.width == getResolutionWidthByHeight(height: resolutionHeight){
                let maxRate = Int(format.videoSupportedFrameRateRanges.first!.maxFrameRate)
                if maxRate > maxFrameRate{
                    maxFrameRate = maxRate
                }
            }
        }
        return maxFrameRate
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "torchMode"{
            //没什么要处理的
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "torchMode")
    }
}


extension ShadowCameraHandle:AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !CMSampleBufferDataIsReady(sampleBuffer){
            print("sample buffer is not ready. Skipping sample")
            return
        }
        if output is AVCaptureVideoDataOutput{
            calculatorCaptureFPS()
            let pix = CMSampleBufferGetImageBuffer(sampleBuffer)
            realTimeResolutionWidth = CVPixelBufferGetWidth(pix!)
            realTimeResolutionHeight = CVPixelBufferGetHeight(pix!)
        }
        else if output is AVCaptureAudioDataOutput{
            
        }
        delegate?.captureOutput(output: output, didOutput: sampleBuffer, from: connection)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output is AVCaptureVideoDataOutput{
            print("Error: Drop video frame")
        }
        else{
             print("Error: Drop audio frame")
        }
        delegate?.captureOutput(output: output, didDrop: sampleBuffer, from: connection)
    }
}
