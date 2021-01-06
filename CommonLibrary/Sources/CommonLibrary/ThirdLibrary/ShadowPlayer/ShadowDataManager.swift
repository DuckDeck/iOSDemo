


//
//  ShadowDataManager.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
@objc protocol ShadowDataManagerDelegate{
    @objc optional func fileDownloadAndSaveSuccess();
}
class ShadowDataManager {
    
    weak var delegate:ShadowDataManagerDelegate?
    var contentLength = 0
    fileprivate var tmpPath = ""
    fileprivate var cachePath = ""
    fileprivate var writeFileHandle:FileHandle?
    fileprivate var readFileHandle:FileHandle?
    fileprivate var isCloseFile = false
    fileprivate var cachedDataLength = 0

    init?(urlStr:String,cachePath:String) {
        let success = createTmpPathWith(urlStr: urlStr, cachePath: cachePath)
        if !success{
            return nil
        }
    }
    deinit {
        writeFileHandle?.closeFile()
        readFileHandle?.closeFile()
    }
    
    
    fileprivate func createTmpPathWith(urlStr:String,cachePath:String?)->Bool{
        let playerTmpDire = "\(NSTemporaryDirectory())ShadowCache"
        if !checkDirectoryPath(path: playerTmpDire){
            return false
        }
        let url = URL(string: urlStr)!
        let fileType = url.pathExtension
        tmpPath = "\(playerTmpDire)/\(urlStr.toUrlFileName()).\(fileType)"
        do{
            if FileManager.default.fileExists(atPath: tmpPath){
               try FileManager.default.removeItem(atPath: tmpPath)
            }
            
        }
        catch{
            print(error.localizedDescription)
        }
        if !FileManager.default.createFile(atPath: tmpPath, contents: nil, attributes: nil){
           return false
        }
        if cachePath != nil{
            let userCustomCacheDire = (cachePath! as NSString).deletingLastPathComponent
            if !checkDirectoryPath(path: userCustomCacheDire){
                return false
            }
            self.cachePath = cachePath!
        }
        else{
            let playerCacheDire = "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!)/ShadowCache"
            if !checkDirectoryPath(path: playerCacheDire){
                return false
            }
            self.cachePath = "\(playerCacheDire)/\(urlStr.toUrlFileName()).\(fileType)"
        }
        writeFileHandle = FileHandle(forWritingAtPath: tmpPath)
        readFileHandle = FileHandle(forReadingAtPath: tmpPath)
        return true
    }
    
    static func checkCached(urlStr:String)->(String,Bool){
        if urlStr.hasPrefix("/var"){
            return (urlStr,true)
        }
        let url = URL(string: urlStr)!
        let fileType = url.pathExtension //这个并不准，因为很多并没有以文件格式后缀结尾巴，URL里有.没有影响
        let cachePath = "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!)/ShadowCache/\(urlStr.toUrlFileName()).\(fileType)"
        if FileManager.default.fileExists(atPath: cachePath){
            return (cachePath,true)
        }
      
        return (cachePath,false)
        
    }
    
    static func convertUrlToFileName(url:String)->String{
        return url.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "#", with: "_").replacingOccurrences(of: "&", with: "_").replacingOccurrences(of: "?", with: "_")

    }
    
    public static func clearCache(){
        let path = "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!)/ShadowCache/"
        if let items = try? FileManager.default.contentsOfDirectory(atPath: path){
            for item in items{
               try? FileManager.default.removeItem(atPath: path + item)
            }
        }
        
    }
    
    static func checkCached(filePath:String)->String?{
        if FileManager.default.fileExists(atPath: filePath){
            return filePath
        }
        else{
            return nil
        }
    }
    
    func  addCache(data:Data,range:NSRange)  {
        objc_sync_enter(self.writeFileHandle!)
        if !isCloseFile{
            writeFileHandle?.seek(toFileOffset: UInt64(range.location))
            writeFileHandle?.write(data)
            writeFileHandle?.synchronizeFile()
            cachedDataLength += data.count
            if cachedDataLength > contentLength{
                copyFileToCachePath()
            }
        }
        objc_sync_exit(self.writeFileHandle!)
    }
    
    func readCacheDataIn(range:NSRange) -> Data {
        objc_sync_enter(self.readFileHandle!)
        readFileHandle?.seek(toFileOffset: UInt64(range.location))
        let data = readFileHandle!.readData(ofLength: range.length)
        objc_sync_exit(self.readFileHandle!)
        return data
    }
    
    fileprivate func copyFileToCachePath() {
        writeFileHandle?.closeFile()
        isCloseFile = true
        do{
           try FileManager.default.moveItem(atPath: tmpPath, toPath: cachePath)
            readFileHandle = FileHandle(forReadingAtPath: cachePath)
            delegate?.fileDownloadAndSaveSuccess?()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    fileprivate func checkDirectoryPath(path:String) -> Bool {
        var isDire:ObjCBool = false
        if !(FileManager.default.fileExists(atPath: path, isDirectory: &isDire) && isDire.boolValue){
            do {
                 try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                
                return true
            }
            catch{
                print(error.localizedDescription)
                return false
            }
        }
        return true
    }
    

}


