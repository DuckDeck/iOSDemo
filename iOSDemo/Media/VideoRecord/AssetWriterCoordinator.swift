//
//  AssetWriterCoordinator.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
protocol AssetWriterCoordinatorDelegate {
    func writerCoordinatorDidFinishPreparing(coordinator:AssetWriterCoordinator)
    func writerCoordinator(coordinator:AssetWriterCoordinator) throws
    func writerCoordinatorDidFinishRecording(coordinator:AssetWriterCoordinator)
}
class AssetWriterCoordinator{
    init(url:URL) {
        
    }
    
    func addVideoTrackWithSourceFormatDescription(formatDescription:CMFormatDescription,videoSettings:[String:String]) {
        
    }
    func addAudioTrackWithSourceFormatDescription(formatDescription:CMFormatDescription,videoSettings:[String:String]) {
    
    }
    
    func setDelegate(delegate:AssetWriterCoordinatorDelegate,delegateCallbackQueue:DispatchQueue)  {
        
    }
    func prepareToRecord() {
        
    }
    func appendVideoSampleBuffer(sampleBuffer:CMSampleBuffer)  {
        
    }
    func appendAudioSampleBuffer(sampleBuffer:CMSampleBuffer)  {
        
    }
    func finishRecording() {
        
    }
    
    
}
