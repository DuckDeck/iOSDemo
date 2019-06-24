//
//  CaptureSessionCoordinator.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
import AVFoundation
protocol CaptureSessionCoordinatorDelegate :class{
    func coordinatorDidBeginRecording(coordinator:CaptureSessionCoordinator)->Void
    func coordinator(coordinator:CaptureSessionCoordinator,outputFileUrl:URL,error:Error?)->Void
}

class CaptureSessionCoordinator:NSObject {
    
    var captureSession:AVCaptureSession!
    var deviceInput:AVCaptureDeviceInput!
    var delegateCallbackQueue:DispatchQueue!
    weak var delegate:CaptureSessionCoordinatorDelegate?
    var sessionQueue:DispatchQueue!
    var _previewLayer:AVCaptureVideoPreviewLayer?
    var isFlashingOn = false
    var cameraModel:CameraModel
    override init() {
        cameraModel = CameraModel(preset: AVCaptureSession.Preset.hd1280x720, frameRate: 30, resolutionHeight: 720, videoFormat: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, torchMode: .off, focusMode: .continuousAutoFocus, exposureMode: .continuousAutoExposure, flashMode: .off, whiteBlackMode: .continuousAutoWhiteBalance, position: .back, videoGravity: .resizeAspect, videoOrientation: .portrait, isEnableVideoStabilization: true)
        super.init()
        sessionQueue = DispatchQueue(label: "stanhu.recorvideo")
        captureSession = setupCaptureSession()
        
    }
    
    var isRunning:Bool{
        get{
            return captureSession.isRunning
        }
    }
    
    func setFlash(turn:Bool)  {
        isFlashingOn = !isFlashingOn
        do{
           
            try self.deviceInput.device.lockForConfiguration()
            if isFlashingOn{
                if self.deviceInput.device.isFlashModeSupported(.on){
                    self.deviceInput.device.flashMode = .on
                    self.deviceInput.device.torchMode = .on
                }
            }
            else{
                if self.deviceInput.device.isFlashModeSupported(.off){
                    self.deviceInput.device.flashMode = .off
                    self.deviceInput.device.torchMode = .off
                }
            }
            self.deviceInput.device.unlockForConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
   
    
    func switchCamera(){
        let newPosition = deviceInput.device.position == AVCaptureDevice.Position.back ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        cameraModel.position = newPosition
        
        setCameraPosition(position: newPosition, session: self.captureSession, input: self.deviceInput, videoFormat: cameraModel.videoFormat, resolutionHeight: cameraModel.resolutionHeight, frameRate: cameraModel.frameRate)
    }
    
    func getMaxFrameRateByCurrentResolution()->Int {
        return CaptureSessionCoordinator.getMaxFrameRateByCurrentResolutionWithResolutionHeight(resolutionHeight: cameraModel.resolutionHeight, position: cameraModel.position, videoFormat: cameraModel.videoFormat)
        
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
        deviceInput = newInput
        let isSuccess = CaptureSessionCoordinator.setCameraFrameRateAndResolution(frameRate: frameRate, resolutionHeight: resolutionHeight, session: session, position: position, videoFormat: videoFormat)
        
        if !isSuccess{
            print("Set resolution and frame fail")
        }
    
        session.commitConfiguration()
            
    }
    
    
    func getMaxSupportResolutionByPreset() -> Int {
        if captureSession.canSetSessionPreset(.hd4K3840x2160){
            return 2160
        }
        else if captureSession.canSetSessionPreset(.hd1920x1080){
            return 1080
        }
        else if captureSession.canSetSessionPreset(.hd1280x720){
            return 720
        }
        else if captureSession.canSetSessionPreset(.vga640x480){
            return 480
        }
        else if captureSession.canSetSessionPreset(.cif352x288){
            return 288
        }
        return -1
        
    }
    
    func setDelegate(delegate:CaptureSessionCoordinatorDelegate,callbackQueue:DispatchQueue) -> Void {
        objc_sync_enter(self)
        self.delegate = delegate
        if delegateCallbackQueue == nil{
            delegateCallbackQueue = callbackQueue
        }
        if delegateCallbackQueue != nil && delegateCallbackQueue != callbackQueue{
            delegateCallbackQueue = callbackQueue
        }
        objc_sync_exit(self)
    }
    
    func addInput(input:AVCaptureDeviceInput,captureSession:AVCaptureSession) -> Bool {
        if captureSession.canAddInput(input){
            captureSession.addInput(input)
            return true
        }
        else{
            print(input.description)
            return false
        }
   
    }
    
    func addOutput(output:AVCaptureOutput,captureSession:AVCaptureSession) -> Bool {
        if captureSession.canAddOutput(output){
            captureSession.addOutput(output)
            return true
        }
        else{
            print(output.description)
            return false
        }
    }
    
    func setupCaptureSession()->AVCaptureSession {
        let captureSession = AVCaptureSession()
        configCamera(session:captureSession)
        if !addDefaultCameraInputToCaptureSession(captureSession: captureSession){
            print("failed to add camera input to capture session")
        }
        if !addDefaultMicInputToCaptureSession(captureSession: captureSession){
             print("failed to add mic input to capture session")
        }
        return captureSession
    }
    
    func configCamera(session:AVCaptureSession) {
        if session.canSetSessionPreset(cameraModel.preset){
            session.sessionPreset = cameraModel.preset
        }
        guard let device = CaptureSessionCoordinator.getCaptureDeviceFromPosition(position: cameraModel.position) else {
            return
        }
        _ = CaptureSessionCoordinator.setCameraFrameRateAndResolution(frameRate: cameraModel.frameRate, resolutionHeight: cameraModel.resolutionHeight, session: session, position: cameraModel.position, videoFormat: cameraModel.videoFormat)
        
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
        
        if cameraModel.isEnableVideoStabilization{
            //h目前不写
        }
        
        previewLayer?.videoGravity = cameraModel.videoGravity
        
        
        
    }
    
    
    func focusAtPoint(point:CGPoint) {
        if deviceInput.device.isFocusPointOfInterestSupported{
            let convertedFocusPoint = convertToPointOfInterestFromViewCoordinates(viewCoordinates: point, captureVideoPreviewLayer: previewLayer!)
            autoFocusAtFocus(point: convertedFocusPoint)
        }
        else{
            print("Current device not suppert focus")
        }
    }
    
    func autoFocusAtFocus(point:CGPoint) {
        let device = deviceInput.device
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
    
//    func manualConvertFocusPoint(point:CGPoint,frameSize:CGSize,captureVideoPreviewLayer:AVCaptureVideoPreviewLayer) -> <#return type#> {
//        <#function body#>
//    }
    
    
    func setExposure(exposureValue:Float,device:AVCaptureDevice) {
        do{
           try device.lockForConfiguration()
            device.setExposureTargetBias(exposureValue, completionHandler: nil)
            device.unlockForConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    
    //手电q筒模式，还不知道有啥用
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
            print("The device not support Torch")
        }
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
    
   
    
    func addDefaultCameraInputToCaptureSession(captureSession:AVCaptureSession) -> Bool {
     
        guard let device = CaptureSessionCoordinator.getCaptureDeviceFromPosition(position: cameraModel.position) else  {
            return false
        }
        
        do{
            let cameraDeviceInput = try AVCaptureDeviceInput(device: device)
            self.deviceInput = cameraDeviceInput
            return self.addInput(input: cameraDeviceInput, captureSession: captureSession)
        }
        catch{
            print(error.localizedDescription)
            return false
        }
    
    }

    func addDefaultMicInputToCaptureSession(captureSession:AVCaptureSession) -> Bool {
        if let device = AVCaptureDevice.default(for: AVMediaType.audio){
            do{
                let micDeviceInput = try AVCaptureDeviceInput(device: device)
                return self.addInput(input: micDeviceInput, captureSession: captureSession)
            }
            catch{
                print(error.localizedDescription)
                return false
            }
        }
        else{
            return false
        }
    }
    
    
    func startRunning()  {
        sessionQueue.sync {
            captureSession.startRunning()
        }
    }
    
    func stopRunning()  {
        sessionQueue.sync {
            self.stopRecording()
            captureSession.stopRunning()
        }
    }
    
    func startRecording()  {
        //overwritten by subclass
    }
    
    func stopRecording()  {
        //overwritten by subclass
    }
    
    var previewLayer:AVCaptureVideoPreviewLayer?{
        get{
            if _previewLayer == nil && captureSession != nil{
                _previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            }
            return _previewLayer
        }
    }
    
    func setFrameRateWithDuration(frameDuration:CMTime,device:AVCaptureDevice) -> Void {
            let supportedFrameRateRanges = device.activeFormat.videoSupportedFrameRateRanges
            var frameRateSupported = false
            for range in supportedFrameRateRanges{
                if Float64(frameDuration.value) >= range.minFrameRate && Float64(frameDuration.value) <= range.maxFrameRate{
                    frameRateSupported = true
                }
            }
        
            if frameRateSupported  {
                do{
                    try device.lockForConfiguration()
                    device.activeVideoMaxFrameDuration = frameDuration
                    device.activeVideoMinFrameDuration = frameDuration
                    device.unlockForConfiguration()
                }
                catch{
                    print(error.localizedDescription)
                }
            }
    }
    
    func listCamerasAndMics() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
           try audioSession.setActive(true)
        }
        catch{
            print(error.localizedDescription)
        }
        guard let  availableAudioInputs =  audioSession.availableInputs else {
            return
        }
       
        print(availableAudioInputs.description)
        if availableAudioInputs.count > 0{
            let portDescription = availableAudioInputs.first!
            if portDescription.dataSources!.count > 0{
                do{
                    guard  let dataSource = portDescription.dataSources?.last else{
                        return
                    }
                    try portDescription.setPreferredDataSource(dataSource)
                    try audioSession.setPreferredInput(portDescription)
                }
                catch{
                    print(error.localizedDescription)
                }
                let availableAudioInputs = audioSession.availableInputs
                print(availableAudioInputs?.description ?? "")
            }
        }
        
    }
    
    func configureFrontMic() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
           try audioSession.setActive(true)
        }
        catch{
            print(error.localizedDescription)
        }
        guard let inputs = audioSession.availableInputs else {
            return
        }
        var builtInMic:AVAudioSessionPortDescription! = nil
        for port in inputs{
            if port.portType == AVAudioSession.Port.builtInMic{
                builtInMic = port
                break
            }
        }
        
        for  source in builtInMic.dataSources! {
            if source.location == AVAudioSession.Location.orientationFront{
                do{
                   try builtInMic.setPreferredDataSource(source)
                   try audioSession.setPreferredInput(builtInMic)
                    break
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
    
    deinit {
        guard let device = CaptureSessionCoordinator.getCaptureDeviceFromPosition(position: cameraModel.position) else {
            return
        }
        device.removeObserver(self, forKeyPath: "torchMode")
    }
}
