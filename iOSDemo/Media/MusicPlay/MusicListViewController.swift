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

    let url = "http://win.web.nf01.sycdn.kuwo.cn/84ec6569e8dce4a9f6632ae5840d7019/5b175326/resource/n3/31/73/3671352600.mp3"
//    let url = "http://win.web.rc01.sycdn.kuwo.cn/a447b8c6025b318ea24e1f9df8f1ea49/5b17535f/resource/n3/61/58/2032057186.mp3"
//    let url = "http://win.web.rf01.sycdn.kuwo.cn/1c4dcf2ed16d8f0b20a78a6cfbf46884/5b175373/resource/n3/4/5/1032924973.mp3"
    
    private let slider = UISlider()        // show the play process
    private let sliderBuffer = UISlider()  //use to buffer the internet video
    private let lblTime = UILabel()
    private let lblTotalTime = UILabel()
    var player:ShadowAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        lblTime.textAlignment = .right
        lblTime.font = UIFont.systemFont(ofSize: 12)
        lblTime.textColor = UIColor.white
        view.addSubview(lblTime)
        
        
        lblTotalTime.textAlignment = .left
        lblTotalTime.font = UIFont.systemFont(ofSize: 12)
        lblTotalTime.textColor = UIColor.white
        view.addSubview(lblTotalTime)
        
        sliderBuffer.setThumbImage(UIImage(), for: .normal)
        sliderBuffer.isContinuous = true
        sliderBuffer.minimumTrackTintColor = UIColor.red
        sliderBuffer.minimumValue = 0
        sliderBuffer.maximumValue = 1
        sliderBuffer.isUserInteractionEnabled = false
        view.addSubview(sliderBuffer)
        
        slider.setThumbImage(#imageLiteral(resourceName: "knob"), for: .normal)
        slider.isContinuous = true
//        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(ges:)))
//        slider.addTarget(self, action: #selector(handleSliderPosition(sender:)), for: .valueChanged)
//        slider.addTarget(self, action: #selector(handleSliderPositionExit(sender:)), for: UIControlEvents.touchUpInside)
//        slider.addGestureRecognizer(tapGesture!)
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor.white
        view.addSubview(slider)
        
        
        lblTime.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.top.equalTo(100)
            m.width.equalTo(50)
        }
        slider.snp.makeConstraints { (m) in
            m.left.equalTo(lblTime.snp.right).offset(5)
            m.right.equalTo(lblTotalTime.snp.left).offset(-5)
            m.centerY.equalTo(lblTime)
            m.height.equalTo(20)
        }
        lblTotalTime.snp.makeConstraints { (m) in
            m.right.equalTo(-5)
            m.centerY.equalTo(lblTime)
            m.width.equalTo(50)
        }
      
        sliderBuffer.snp.makeConstraints { (m) in
            m.edges.equalTo(slider)
        }
        
        player = ShadowAudioPlayer(url: URL(string: url)!)
        
        player.bufferProcess = {[weak self](buffer:Double,totalTime:Double) in
            self?.sliderBuffer.value = Float(buffer / totalTime)
            
        }
        
        player.stateChange = {[weak self](state:PlayerStatus) in
            if state == PlayerStatus.ReadyToPlay && !self!.player.isPlaying{
                
            }
        }
        
        player.playProcess = {[weak self](playTime:Double,totalTime:Double) in
            self?.slider.value = Float(playTime / totalTime)
        }
        player.play()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
