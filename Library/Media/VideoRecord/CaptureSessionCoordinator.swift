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
    var cameraDevice:AVCaptureDevice!
    var delegateCallbackQueue:DispatchQueue!
    weak var delegate:CaptureSessionCoordinatorDelegate?
    var sessionQueue:DispatchQueue!
    var _previewLayer:AVCaptureVideoPreviewLayer?
    var isFlashingOn = false
    var cameraModel:CameraModel
    override init() {
        cameraModel = CameraModel(preset: AVCaptureSession.Preset.hd1280x720, frameRate: 30, resolutionHeight: 720, videoFormat: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, torchMode: .off, focusMode: .autoFocus, exposureMode: .autoExpose, flashMode: .off, whiteBlackMode: .autoWhiteBalance, position: .back, videoGravity: .resizeAspect, videoOrientation: .portrait, isEnableVideoStabilization: true)
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
            if cameraDevice == nil{
                guard let c = AVCaptureDevice.default(for: .video)   else {
                    return
                }
                cameraDevice = c
            }
            try cameraDevice.lockForConfiguration()
            if isFlashingOn{
                if cameraDevice.isFlashModeSupported(.on){
                    cameraDevice.flashMode = .on
                    cameraDevice.torchMode = .on
                }
            }
            else{
                if cameraDevice.isFlashModeSupported(.off){
                    cameraDevice.flashMode = .off
                    cameraDevice.torchMode = .off
                }
            }
            cameraDevice.unlockForConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
   
    
    func switchCamera(){
        let newPosition = cameraDevice.position == AVCaptureDevice.Position.back ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        
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
        configCamera()
        if !addDefaultCameraInputToCaptureSession(captureSession: captureSession){
            print("failed to add camera input to capture session")
        }
        if !addDefaultMicInputToCaptureSession(captureSession: captureSession){
             print("failed to add mic input to capture session")
        }
        
        return captureSession
    }
    
    func configCamera() {
        if captureSession.canSetSessionPreset(cameraModel.preset){
            captureSession.sessionPreset = cameraModel.preset
        }
        
        
    }
    
    
    
    
//    func setCameraFrameRateAndResolution(frameRate:Int,resolutionHeight:CGFloat,withSession:AVCaptureSession,) -> <#return type#> {
//        <#function body#>
//    }
    
    
    static func getCaptureDeviceFromPosition(position:AVCaptureDevice.Position)->AVCaptureDevice{
        let devices:[AVCaptureDevice]?
        if #available(iOS 10.0, *) {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: position)
            devices = deviceDiscoverySession.devices
        }
        else{
            devices = AVCaptureDevice.devices(for: .video)
        }
    }
    
    func addDefaultCameraInputToCaptureSession(captureSession:AVCaptureSession) -> Bool {
        if let device = AVCaptureDevice.default(for: AVMediaType.video){
            do{
                let cameraDeviceInput = try AVCaptureDeviceInput(device: device)
                return self.addInput(input: cameraDeviceInput, captureSession: captureSession)
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
}
