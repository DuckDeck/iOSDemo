//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//
import Foundation
import Photos
public extension FileManager{
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
    static func getAllVideos()->[URL]{
        var arrVidelUrl = [URL]()
        guard let urlStrs = try? FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) else{
            return arrVidelUrl
        }
        if urlStrs.count > 0{
            var videos =  urlStrs.map { (str) -> URL in
                return URL(fileURLWithPath: NSTemporaryDirectory() + str)
            }
            videos.removeFirst()
            return videos
        }
       
       
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            for f in files{
                let ass = AVURLAsset(url: f)
                if ass.tracks(withMediaType: .video).count > 0{
                    arrVidelUrl.append(f)
                }
            }
            
        } catch {
            print("could not get contents of directory at \(documentsDirectory)")
            print(error.localizedDescription)
        }
        
        return arrVidelUrl
    }
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
    
}
