


//
//  ShadowFileHandle.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/4.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class ShadowFileHandle: NSObject {
    static func createTempFile(fileName:String,extensionName:String)->String?{
        
        let path = "\(NSTemporaryDirectory())\(fileName).\(extensionName)"
        if FileManager.default.fileExists(atPath: path){
            try? FileManager.default.removeItem(atPath: path)
        }
        let result = FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        if result{
            return path
        }
        return nil
    }
    
    static func writeTempFile(data:Data,path:String){
        guard let handle = FileHandle(forWritingAtPath: path) else{
            return
        }
        handle.seekToEndOfFile()
        handle.write(data)
    }
    
    static func readTempFileDataWith(offset:UInt,length:Int,path:String)->Data?{
        guard let handle = FileHandle(forWritingAtPath: path) else{
            return nil
        }
        handle.seek(toFileOffset: UInt64(offset))
        return handle.readData(ofLength: length)
    }
    
    static func cacheTempFileWithFile(fileName:String,tmpPath:String)->Bool{
        let path = "\(NSTemporaryDirectory())cachevideo"
        if !FileManager.default.fileExists(atPath: path){
           try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let cachePath = "\(path)/\(fileName)"
        do{
            try FileManager.default.copyItem(atPath: tmpPath, toPath: cachePath)
            return true
        }
        catch{
            return false
        }
    }
    
    static func cacheFileExistsWith(url:URL)->String?{
        guard let fileName = url.path.components(separatedBy: "/").last else{
            return nil
        }
        let path = "\(NSTemporaryDirectory())cachevideo/\(fileName)"
        if FileManager.default.fileExists(atPath: path){
            return path
        }
        return nil
    }
    
    
    
    static func clearCache()->Bool{
        let path = "\(NSTemporaryDirectory())cachevideo"
        do{
           try FileManager.default.removeItem(atPath: path)
           return true
        }
        catch{
            return false
        }
        
    }
}


