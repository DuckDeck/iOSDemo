//
//  ShadowEncoder.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/6/27.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation
import VideoToolbox
enum ShadowEncoderType:Int {
    case H264,H265
}
//这里用swift写太麻烦了
/*
class ShadowEncoder: NSObject {
    
    static let g_capture_base_time:UInt32 = 0
    static let last_dts = 0
    fileprivate var isSupportEncoder:Bool
    fileprivate var isSupportRealTimeEncode:Bool
    fileprivate var isNeedForceInsertKeyFrame:Bool
    fileprivate var width:Int
    fileprivate var height:Int
    fileprivate var fps:Int
    fileprivate var bitrate:Int
    fileprivate var errorCount:Int
    fileprivate var isNeedResetKeyParamSetBuffer:Bool
    fileprivate var encoderType:ShadowEncoderType
    fileprivate var lock:NSLock
    fileprivate var isNeedRecord:Bool
    
    
    fileprivate var session:VTCompressionSession
    fileprivate var videoFile:FILE
    
    fileprivate static var encoder:ShadowEncoder? = nil
    
    
    static func EncodeCallBack(outputCallbackRefCon:UnsafeMutableRawPointer,souceFrameRefCon:UnsafeMutableRawPointer,status:OSStatus,infoFlags:VTEncodeInfoFlags,sampleBuffer:CMSampleBuffer){
        let encoder = unsafeBitCast(outputCallbackRefCon, to: ShadowEncoder.self)
        if status != noErr{
            let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            print("H264: vtCallBack failed with \(error)")
            return
        }
        if !encoder.isSupportEncoder{
            return
        }
        let block = CMSampleBufferGetDataBuffer(sampleBuffer)
        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let dts = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        
        let ptsAfter = (Int(CMTimeGetSeconds(pts)) - Int(g_capture_base_time)) * 1000
        var dtsAfter = (Int(CMTimeGetSeconds(dts)) - Int(g_capture_base_time)) * 1000
        dtsAfter = ptsAfter
        if dtsAfter == 0{
            dtsAfter = last_dts + 33
        }
        else if dtsAfter == last_dts{
            dtsAfter += 1
        }
        var isKeyFrame = false
        let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false)
        if attachments != nil{
            let attachment = CFArrayGetValueAtIndex(attachments!, 0)
            let dependsOnOthers = unsafeBitCast(CFDictionaryGetValue(unsafeBitCast(attachment!, to: CFDictionary.self), unsafeBitCast(kCMSampleAttachmentKey_DependsOnOthers, to: UnsafeRawPointer.self)), to: CFBoolean.self)
            isKeyFrame = dependsOnOthers == kCFBooleanFalse
        }
        if isKeyFrame{
            var keyParameterSetBuffer:UnsafeMutablePointer<UInt8>? = nil
            var keyParameterSetBufferSize:size_t = 0
            if keyParameterSetBufferSize == 0 || encoder.isNeedResetKeyParamSetBuffer{
                let vps:UnsafePointer<UInt8>!
                var sps:UnsafePointer<UInt8>! = nil
                let pps:UnsafePointer<UInt8>!
                var vpsSize:size_t = 0
                var spsSize:size_t = 0
                var ppsSize:size_t = 0
                var NALUnitHeaderLengthOut:Int32 = 0
                var parmCount:size_t = 0
                if keyParameterSetBuffer != nil{
                    free(keyParameterSetBuffer!)
                }
                
                let format = CMSampleBufferGetFormatDescription(sampleBuffer)
                if encoder.encoderType == .H264{
                    CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format!, parameterSetIndex: 0, parameterSetPointerOut: &sps, parameterSetSizeOut: &spsSize, parameterSetCountOut: &parmCount, nalUnitHeaderLengthOut: &NALUnitHeaderLengthOut)
                    CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format!, parameterSetIndex: 1, parameterSetPointerOut: &sps, parameterSetSizeOut: &ppsSize, parameterSetCountOut: &parmCount, nalUnitHeaderLengthOut: &NALUnitHeaderLengthOut)
                    keyParameterSetBufferSize = spsSize + 4 + ppsSize + 4
                    keyParameterSetBuffer = unsafeBitCast(malloc(keyParameterSetBufferSize), to: UnsafeMutablePointer<UInt8>.self)
//                    memcpy(keyParameterSetBuffer, "\x00\x00\x00\x01", 4)
                    
                }
            }
        }
        
        
    }
    
    init(width:Int,height:Int,fps:Int,bitrate:Int,isUpportRealTimeEncode:Bool,encodeType:ShadowEncoderType) {
        
    }
    
    func configureEncoder(width:Int,height:Int) {
        
    }
    
    func startEncodeDataWithBuffer(buffer:CMSampleBuffer,isNeedFreeBuffer:Bool)  {
        
    }
    
    func freeVideoEncoder() {
        
    }
    
    func forceInsertKeyFrame()  {
        
    }
    
    func startVideoRecord()  {
        
    }
    
    func stopVideoRecord() {
        
    }
    
    
    
}
*/
