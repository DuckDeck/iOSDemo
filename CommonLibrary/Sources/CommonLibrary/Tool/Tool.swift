//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/6.
//

import UIKit
import IQKeyboardManagerSwift
import Photos
public class Tool{
    static public func hiddenKeyboard(){
        UIApplication.shared.keyWindow?.rootViewController?.view.endEditing(true)
    }
    
    static public func ChineseToPinyin(chinese:String)->String{
        let py = NSMutableString(string: chinese)
        CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
        return py as String
    }
    
    static public func thumbnailImageForVideo(url:URL,time:Double = 0)->UIImage?{
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
