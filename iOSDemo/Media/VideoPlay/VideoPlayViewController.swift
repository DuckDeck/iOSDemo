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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.title = "视频信息"
        if url == nil{
            Toast.showToast(msg: "没有url")
            return
        }
        
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path){
            let size = attr[FileAttributeKey.size] as! Int
            dictDes["文件大小"] = "\(size / 1000000)M"
            dictDes["创建日期"] = "\(attr[FileAttributeKey.creationDate]!)"
        }
        
        let assert = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: assert)
        player = AVPlayer(playerItem: item)
       
        
        dictDes["扩展名"] = url.pathExtension
        
        guard let a = assert.tracks.first?.formatDescriptions.first else{
            return
        }
        
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
    
 
        btnClose.title(title: "Close").color(color: UIColor.darkGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth * 0.2)
            m.bottom.equalTo(-10)
        }
        btnClose.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        
        var tmp:UIView! = nil
        
        for info in dictDes{
            let lbl = UILabel().text(text: "\(info.key) : \(info.value)").color(color: UIColor.darkGray).addTo(view: view)
            lbl.snp.makeConstraints { (m) in
                m.left.equalTo(15)
                if tmp == nil{
                    m.top.equalTo(300)
                }
                else{
                    m.top.equalTo(tmp.snp.bottom).offset(5)
                }
                m.height.equalTo(25)
            }
            tmp = lbl
        }
    }

    
    @objc func closePage() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
