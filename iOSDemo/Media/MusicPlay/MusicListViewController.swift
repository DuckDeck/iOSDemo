//
//  MusicListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/10/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
class MusicListViewController: UIViewController {

//    let tb = UITableView()
//    let arrMusics = [String]()

  //  let url = "http://up.mcyt.net/?down/47675.mp3"
    let url = "http://download.lingyongqian.cn/music/AdagioSostenuto.mp3"
//    let url = "http://win.web.rc01.sycdn.kuwo.cn/a447b8c6025b318ea24e1f9df8f1ea49/5b17535f/resource/n3/61/58/2032057186.mp3"
//    let url = "http://win.web.rf01.sycdn.kuwo.cn/1c4dcf2ed16d8f0b20a78a6cfbf46884/5b175373/resource/n3/4/5/1032924973.mp3"
    
    var audioPlayer:ShadowAudioPlayerView! = nil
    let img = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
       
       audioPlayer = ShadowAudioPlayerView(frame: CGRect(x: 10, y: 80, w: ScreenWidth-80, h: 50), url: URL(string: url)!)
       view.addSubview(audioPlayer)
       
        
        
        img.image = UIImage.createRect(size: CGSize(width: 50, height: 80), color: UIColor.blue)
        view.addSubview(img)
        img.snp.makeConstraints { (m) in
            m.left.equalTo(30)
            m.top.equalTo(140)
       }
        
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }



}
