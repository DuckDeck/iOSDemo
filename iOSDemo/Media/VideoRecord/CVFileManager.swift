
//
//  FileManager.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/3.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import Photos
class CVFileManager {
    static func tempFileURL(extensionName:String)->URL
    {
        var path:String! = nil
        let fm = FileManager.default
        var i = 0
        while path == nil || fm.fileExists(atPath: path) {
            path = "\(NSTemporaryDirectory())output\(i).\(extensionName)"
            i += 1
        }
        return URL.init(fileURLWithPath: path)
    }
    
    static func removeFile(url:URL){
        let path = url.path
        let fm = FileManager.default
        if fm.fileExists(atPath: path){
            do{
                try fm.removeItem(atPath: path)
            }
            catch{
                print(error.localizedDescription)
            }
        }
    }
    
    static func copyFileToCameraRoll(fileUrl:URL)  {
       try? PHPhotoLibrary.shared().performChangesAndWait {
           PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
        }

    }
    
    
}
