//
//  Tool.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Photos
class Tool{
    static func hiddenKeyboard(){
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
    }
    
    static func ChineseToPinyin(chinese:String)->String{
        let py = NSMutableString(string: chinese)
        CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
        return py as String
    }
    
    static func thumbnailImageForVideo(url:URL,time:Double = 0)->UIImage?{
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.apertureMode =  AVAssetImageGenerator.ApertureMode.encodedPixels
        let t = CMTime(seconds: time, preferredTimescale: 60)
        do{
            let thumbnailImageRef = try assetImageGenerator.copyCGImage(at: t, actualTime: nil)
            return UIImage(cgImage: thumbnailImageRef)
        }
        catch{
            print(error.localizedDescription)
            return nil
        }
        
    }
    
}
