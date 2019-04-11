//
//  MitoPlayViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/10.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class MitoPlayViewController: UIViewController {

    var item:ImageSet?
    var player:ShadowVideoPlayerView! = nil //issue关了不会自动释放内存,需要调用stop
    var btnClose = UIButton()
    var btnDownload = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        let config = [ShadowUIConfig.HideFullScreenButton:true]
        player = ShadowVideoPlayerView(frame: CGRect(x: 0, y: 80, width: ScreenWidth, height: ScreenHeight - 140 - iPhoneBottomBarHeight), url: URL(string: item!.videoLink)!,config: config)
        player.title = item!.title
        view.addSubview(player)
       
        btnClose.title(title: "关闭").color(color: UIColor.white).addTo(view: view).snp.makeConstraints { (m) in
            m.right.equalTo(-20)
            m.bottom.equalTo(-40)
        }
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        btnDownload.title(title: "下载").color(color: UIColor.white).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(20)
            m.bottom.equalTo(-40)
        }
        btnDownload.addTarget(self, action: #selector(download), for: .touchUpInside)
    }

    @objc func close(){
        player.stop()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func download(){
        //下载要研究下
        let vProgress = DownloadProgressView(frame: CGRect(x: ScreenWidth - 100, y: ScreenHeight - 150, width: 60, height: 60))
        UIApplication.shared.keyWindow?.addSubview(vProgress)
        vProgress.startDownloadWithUrl(url: item!.videoLink)
    }
    
}
