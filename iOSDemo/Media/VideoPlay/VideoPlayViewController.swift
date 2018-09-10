//
//  VideoPlayViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/9.
//  Copyright © 2018 Stan Hu. All rights reserved.
//
//这个用于自已写的播放器
import UIKit
import AVKit
class VideoPlayViewController: BaseViewController {

    var url:URL!
    var player:AVPlayer!
    let btnClose = UIButton()
    var dictDes = [String:String]()
    var shadowPlayer:ShadowVideoPlayerView!
    let btnDelete = UIButton()
    let btnCompress = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "视频信息"
        btnClose.title(title: "关闭").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.2)
            m.bottom.equalTo(-10)
        }
        btnClose.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        if url == nil{
            Toast.showToast(msg: "没有url")
            return
        }
        
        let u = url.directory
        print(u)
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path){
            let size = attr[FileAttributeKey.size] as! Int
            dictDes["文件大小"] = "\(size / 1000000)M"
            dictDes["创建日期"] = "\(attr[FileAttributeKey.creationDate]!)"
        }
        
        let assert = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: assert)
        player = AVPlayer(playerItem: item)
       
        
        dictDes["扩展名"] = url.pathExtension
        
        if let a = assert.tracks.first?.formatDescriptions.first {
            let format = a as! CMFormatDescription
            
            let type = CMFormatDescriptionGetMediaType(format)
            if type == kCMMediaType_Video{
                dictDes["类型"] = "视频"
                guard let track = assert.tracks(withMediaType: .video).first else{
                    return
                }
                
                let res = track.naturalSize
                dictDes["分辨率"] = "\(res.width) * \(res.height)"
                dictDes["时长"] = "\(track.timeRange.duration.seconds)秒"
                dictDes["帧率"] = "\(track.nominalFrameRate)帧每秒"
                dictDes["码率"] = "\(track.estimatedDataRate / 8000000) M每秒"
                
            }
            else if type == kCMMediaType_Audio{
                dictDes["类型"] = "音频"
                guard let track = assert.tracks(withMediaType: .audio).first else{
                    return
                }
                dictDes["时长"] = "\(track.timeRange.duration.seconds)秒"
                dictDes["帧率"] = "\(track.nominalFrameRate)帧每秒"
                dictDes["码率"] = "\(track.estimatedDataRate / 8000000) M每秒"
            }
        }
        
       
    
 
       
        
        var tmp:UIView! = nil
        
        for info in dictDes{
            let lbl = UILabel().text(text: "\(info.key) : \(info.value)").color(color: UIColor.darkGray).addTo(view: view)
            lbl.snp.makeConstraints { (m) in
                m.left.equalTo(15)
                if tmp == nil{
                    m.top.equalTo(350)
                }
                else{
                    m.top.equalTo(tmp.snp.bottom).offset(5)
                }
                m.height.equalTo(25)
            }
            tmp = lbl
        }
        
        shadowPlayer = ShadowVideoPlayerView(frame: CGRect(), url: url)
        
        shadowPlayer.title = url.lastPathComponent
        shadowPlayer.backgroundColor = UIColor.black
        view.addSubview(shadowPlayer)
        shadowPlayer.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(20)
            m.height.equalTo(ScreenWidth * 0.7)
        }
        shadowPlayer.play()
        
        btnDelete.title(title: "删除").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.4)
            m.bottom.equalTo(-10)
        }
        btnDelete.addTarget(self, action: #selector(deleteFile), for: .touchUpInside)
      
        btnCompress.title(title: "压缩").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.6)
            m.bottom.equalTo(-10)
        }
        btnCompress.addTarget(self, action: #selector(compress), for: .touchUpInside)
        
    }

    
    @objc func closePage() {
        shadowPlayer?.stop()
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func compress() {
        shadowPlayer?.stop()
        let newFileName = url.absoluteString.split(".").first! + "compress.mp4"
        Toast.showLoading()
        compressVideo(inputUrl: url, outputUrl: URL(string: newFileName)!) { (export) in
            DispatchQueue.main.async {
                Toast.showToast(msg: "压缩完成")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func deleteFile() {
        
        UIAlertController.title(title: "删除该视频", message: nil).action(title: "取消", handle: nil).action(title: "确定", handle:{ (action:UIAlertAction) in
            self.shadowPlayer.stop()
            CVFileManager.removeFile(url: self.url)
            self.dismiss(animated: true, completion: nil)
        }).showAlert(viewController: self)
    }


    func compressVideo(inputUrl:URL,outputUrl:URL,completed:@escaping ((_ export:AVAssetExportSession) ->Void))  {
        let avAsset = AVURLAsset(url: inputUrl, options: nil)
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) else{
            return
        }
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            switch exportSession.status{
            case .cancelled:
                print("AVAssetExportSessionStatusCancelled")
            case .unknown:
                print("AVAssetExportSessionStatusUnknown")
            case .waiting:
                print("AVAssetExportSessionStatusWaiting")
            case .exporting:
                print("AVAssetExportSessionStatusExporting")
            case .completed:
                 print("AVAssetExportSessionStatusCompleted")
                completed(exportSession)
            case .failed:
                print("AVAssetExportSessionStatusFailed")
            }
        }
        
    }
}
