//
//  CaptureSession.swift
//  iOSDemo
//
//  Created by Stan Hu on 20/10/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
enum CaptureSessionPreset:Int {
     /// 低分辨率
    case CaptureSessionPreset368x640 = 0,
    /// 中分辨率
    CaptureSessionPreset540x960,
     /// 高分辨率
    CaptureSessionPreset720x1280
}

enum CaptureCamera:Int{
    case FrontCamera = 0,
    BackCamera
}


protocol CaptureSessionDelegate {
    /** 视频取样数据回调 */
    func videoCaptureOutputWithSampleBuffer(sampleBuffer:CMSampleBuffer)
    /** 音频取样数据回调 */
    func audioCaptureOutputWithSampleBuffer(sampleBuffer:CMSampleBuffer)
}

class CaptureSession: NSObject {
    
    var session:AVCaptureSession!
    var videoDevice:AVCaptureDevice?
    var audioDevice:AVCaptureDevice?
    var videoInput:AVCaptureDeviceInput!
    var audioInput:AVCaptureDeviceInput!
    var videoOutput:AVCaptureVideoDataOutput!
    var audioOutput:AVCaptureAudioDataOutput!
    var preViewLayer:AVCaptureVideoPreviewLayer?
    var avPreset:String{
        get{
            switch self.sessionPreset {
            case .CaptureSessionPreset368x640:
                return AVCaptureSession.Preset.vga640x480.rawValue
            case .CaptureSessionPreset540x960:
                return AVCaptureSession.Preset.iFrame960x540.rawValue
            case .CaptureSessionPreset720x1280:
                return AVCaptureSession.Preset.hd1280x720.rawValue
            }
        }
    }
    var preView:UIView?{
        didSet{
            if preView != nil && preViewLayer == nil {
                preViewLayer = AVCaptureVideoPreviewLayer(session: session)
                preViewLayer?.frame = preView!.layer.bounds
                preViewLayer?.connection?.videoOrientation = videoOutput.connection(with: AVMediaType.video)!.videoOrientation
                preViewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                preViewLayer?.position = CGPoint(x: preView!.frame.size.width / 2, y: preView!.frame.size.height / 2)
                let layer = preView!.layer
                layer.masksToBounds = true
                layer.addSublayer(self.preViewLayer!)
            }
        }
    }
    var _captureCamera = CaptureCamera.BackCamera
    var captureCamera:CaptureCamera
    {
        get{
            return _captureCamera
        }
        set{
            if newValue != _captureCamera{
                _captureCamera = newValue
                if _captureCamera == .FrontCamera{
                    videoDevice = deviceWithMediaType(mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
                }
                else{
                     videoDevice = deviceWithMediaType(mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
                }
                changeDevicePropertySafety(propertyChange: { (captureDevice) in
                    let newVideoInput = try? AVCaptureDeviceInput(device: videoDevice!)
                    if newVideoInput != nil{
                        session.removeInput(videoInput!)
                        if session.canAddInput(newVideoInput!){
                            session.addInput(newVideoInput!)
                            videoInput = newVideoInput
                        }
                        else{
                            session.addInput(videoInput)
                        }
                        
                    }
                })
            }
        }
    }
    var delegate:CaptureSessionDelegate?
    var sessionPreset:CaptureSessionPreset = CaptureSessionPreset.CaptureSessionPreset540x960
    
    init(sessionPreset:CaptureSessionPreset) {
        super.init()
        self.sessionPreset = sessionPreset
        initAVCaptureSession()
    }
    
  
    
    func initAVCaptureSession() {
        // 初始化
        session = AVCaptureSession()
        // 设置录像的分辨率
        session.canSetSessionPreset(supportSessionPreset)
        /** 注意: 配置AVCaptureSession 的时候, 必须先开始配置, beginConfiguration, 配置完成, 必须提交配置 commitConfiguration, 否则配置无效  **/
        session.beginConfiguration()
        // 设置视频 I/O 对象 并添加到session
        videoInputAndOutput()
         // 设置音频 I/O 对象 并添加到session
        audioInputAndOutput()
         // 提交配置
        session.commitConfiguration()
    }
    

    
    func videoInputAndOutput()  {
        // 初始化视频设备对象
        videoDevice = nil
        // 创建摄像头类型数组 (前置, 和后置摄像头之分)
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
         // 便利获取的所有支持的摄像头类型
        for device in devices{
              // 默然先开启后摄像头
            if device.position == AVCaptureDevice.Position.back{
                self.videoDevice = device
            }
        }
        // 视频输入
        // 根据视频设备来初始化输入对象
        let res = try? AVCaptureDeviceInput(device: self.videoDevice!)
        if res != nil {
            self.videoInput = res!
        }
        else{
            Log(message: "== 摄像头错误 ==")
            return
        }
        // 将输入对象添加到管理者 AVCaptureSession 中
        // 需要先判断是否能够添加输入对象
        if session.canAddInput(self.videoInput) {
            session.addInput(videoInput)
        }
        // 视频输出对象
        videoOutput = AVCaptureVideoDataOutput()
        // 是否允许卡顿时丢帧
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        
        if supportsFastTextureUpload() {
            // 是否支持全频色彩编码 YUV 一种色彩编码方式, 即YCbCr, 现在视频一般采用该颜色空间, 可以分离亮度跟色彩, 在不影响清晰度的情况下来压缩视频
            var supportFullYUVRange = false
            // 获取输出对象所支持的像素格式
            let supportedPixelFormats = videoOutput.availableVideoCodecTypes
            for format in supportedPixelFormats{
                if format == .proRes422{
                    supportFullYUVRange = true
                }
            }
            // 根据是否支持全频色彩编码 YUV 来设置输出对象的视频像素压缩格式
            if supportFullYUVRange{
                self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
            }
            else{
                 self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
            }
        }
        else{
            self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]
        }
        
           // 创建设置代理是所需要的线程队列 优先级设为高
        let videoQueue = DispatchQueue.global(qos: .userInteractive)
        // 设置代理
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        // 判断session 是否可添加视频输出对象
        if session.canAddOutput(videoOutput){
            session.addOutput(videoOutput)
            connectionVideoInputVideoOutput()
        }
    }
    
    // 链接 视频 I/O 对象
    func connectionVideoInputVideoOutput()  {
            // AVCaptureConnection是一个类，用来在AVCaptureInput和AVCaptureOutput之间建立连接。AVCaptureSession必须从AVCaptureConnection中获取实际数据。
        let connectiion = videoOutput.connection(with: AVMediaType.video)
        // 设置视频的方向, 如果不设置的话, 视频默认是旋转 90°的
        connectiion?.videoOrientation = AVCaptureVideoOrientation.portrait
         // 设置视频的稳定性, 先判断connection 连接对象是否支持 视频稳定
        if connectiion != nil &&  connectiion!.isVideoStabilizationSupported {
            connectiion?.preferredVideoStabilizationMode = .auto
        }
        // 缩放裁剪系数, 设为最大
        connectiion?.videoScaleAndCropFactor = connectiion!.videoMaxScaleAndCropFactor
    }
    
    // 设置音频I/O 对象
    func audioInputAndOutput()  {
         // 初始音频设备对象
         audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        if audioDevice == nil {
            Log(message: "audioDevice 为 nil")
            return
        }
         // 音频输入对象
        audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        // 判断session 是否可以添加 音频输入对象
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
       // 音频输出对象
        audioOutput = AVCaptureAudioDataOutput()
        // 判断是否可以添加音频输出对象
        if session.canAddOutput(audioOutput) {
            session.addOutput(audioOutput)
        }
        // 创建设置音频输出代理所需要的线程队列
        let audioQueue = DispatchQueue.global(qos: .userInteractive)
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
    }
    
    func supportsFastTextureUpload() -> Bool {
        #if arch(i386) || arch(x86_64)
           return false
        #endif
//        return (CVOpenGLESTextureCacheCreate != NULL);
        return true
    }
    
    var supportSessionPreset : AVCaptureSession.Preset {
        get{
            if !session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: avPreset)) {
                sessionPreset = CaptureSessionPreset.CaptureSessionPreset540x960
            }
            else{
                sessionPreset = CaptureSessionPreset.CaptureSessionPreset368x640
            }
            return AVCaptureSession.Preset(rawValue: avPreset)
        }
    }
    
    func deviceWithMediaType(mediaType:AVMediaType,position:AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices(for:  mediaType)
        var captureDevice = devices.first!
        for dev in devices{
            if dev.position == position{
                captureDevice = dev
                break
            }
        }
        return captureDevice
    }
    
    func changeDevicePropertySafety(propertyChange:(_ captureDevice:AVCaptureDevice)->Void)  {
         //也可以直接用_videoDevice,但是下面这种更好
        let captureDevice = videoInput.device
        try? captureDevice.lockForConfiguration()
        //调整设备前后要调用beginConfiguration/commitConfiguration
        session.beginConfiguration()
        propertyChange(captureDevice)
        captureDevice.unlockForConfiguration()
        session.commitConfiguration()
    }
    
    
    func startRunning(){
        session.startRunning()
    }
    func stopRunning(){
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    deinit {
        videoOutput.setSampleBufferDelegate(nil, queue: DispatchQueue.main)
        audioOutput.setSampleBufferDelegate(nil, queue: DispatchQueue.main)
    }
}

extension CaptureSession:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == audioOutput{
           delegate?.audioCaptureOutputWithSampleBuffer(sampleBuffer: sampleBuffer)
        }
        else if output == videoOutput{
            delegate?.videoCaptureOutputWithSampleBuffer(sampleBuffer: sampleBuffer)
        }
    }
}
