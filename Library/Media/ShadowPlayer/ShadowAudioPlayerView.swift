//
//  ShadowAudioPlayerView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/6/9.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import CoreMedia
enum AudioPlayStatus {
    case Buffing,ReadyToPlay,LoadFail,Playing,PlayCompleted
}

class ShadowAudioPlayerView: UIView {
    let btnPlay = UIButton()
    let lblPlayTime = UILabel()
    let lblTotalTime = UILabel()
    var url:URL!
    let slider = UISlider()
    let sliderBuffer = UISlider()
    var player:ShadowPlayer!
    var audioDuration:Double = 0
    var tapGesture:UITapGestureRecognizer?
    let vLoading = UIActivityIndicatorView()
    var autoPlay = false
    convenience init(frame: CGRect,url:URL,autoPlay:Bool = false) {
        self.init(frame: frame)
        self.url = url
        self.autoPlay = autoPlay
        initView()
        initPlayer()
    }
    
   fileprivate func initView() {
        btnPlay.setImage(#imageLiteral(resourceName: "btn_play_small"), for: .normal)
        btnPlay.setImage(#imageLiteral(resourceName: "btn_pause_small"), for: .selected)
        btnPlay.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        addSubview(btnPlay)
        btnPlay.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.centerY.equalTo(self)
            m.width.height.equalTo(25)
        }
        btnPlay.isHidden = true
        addSubview(vLoading)
        vLoading.hidesWhenStopped = true
        vLoading.startAnimating()
        vLoading.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.centerY.equalTo(self)
            m.width.height.equalTo(25)
        }
        
        lblPlayTime.font = UIFont.systemFont(ofSize: 14)
        lblPlayTime.textColor = UIColor.red
        lblPlayTime.text = "00:00"
        addSubview(lblPlayTime)
        lblPlayTime.snp.makeConstraints { (m) in
            m.left.equalTo(btnPlay.snp.right).offset(5)
            m.centerY.equalTo(self)
            m.width.equalTo(42)
        }
        
        lblTotalTime.font = UIFont.systemFont(ofSize: 14)
        lblTotalTime.textColor = UIColor.red
        lblTotalTime.text = "00:00"
        addSubview(lblTotalTime)
        lblTotalTime.snp.makeConstraints { (m) in
            m.right.equalTo(0)
            m.centerY.equalTo(self)
            m.width.equalTo(42)
        }
    
        sliderBuffer.setThumbImage(UIImage(), for: .normal)
        sliderBuffer.isContinuous = true
        sliderBuffer.minimumTrackTintColor = UIColor.red
        sliderBuffer.minimumValue = 0
        sliderBuffer.maximumValue = 1
        sliderBuffer.isUserInteractionEnabled = false
        addSubview(sliderBuffer)
        sliderBuffer.snp.makeConstraints { (m) in
            m.left.equalTo(lblPlayTime.snp.right).offset(5)
            m.right.equalTo(lblTotalTime.snp.left).offset(-5)
            m.centerY.equalTo(self)
        }
    
        slider.setThumbImage(#imageLiteral(resourceName: "knob"), for: .normal)
        slider.isContinuous = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(ges:)))
        slider.addTarget(self, action: #selector(handleSliderPosition(sender:)), for: .valueChanged)
    slider.addTarget(self, action: #selector(handleSliderPositionExit(sender:)), for: UIControl.Event.touchUpInside)
        slider.addGestureRecognizer(tapGesture!)
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor.blue
        slider.maximumValue = 1
        slider.minimumValue = 0
        addSubview(slider)
        
        slider.snp.makeConstraints { (m) in
            m.edges.equalTo(sliderBuffer)
        }
        
    
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }

    fileprivate func initPlayer(){
        if url == nil{
            showAudioErrorInfo()
            return
        }
        player = ShadowPlayer(url: url)
        player.delegate = self
    }
    
    func showAudioErrorInfo() {
        btnPlay.isSelected = true
        lblTotalTime.text = "00:00"
        lblPlayTime.text = "00:00"
    }
    
    @objc func playAudio() {
        if url == nil{
            showAudioErrorInfo()
            return
        }
        if !btnPlay.isSelected{
            player.play()
        }
        else{
            player.pause()
        }
        btnPlay.isSelected = !btnPlay.isSelected
    }
    
    deinit {
        if player != nil{
            player.stop()
            player = nil
        }
    }
    
    
    @objc func handleTap(ges:UIGestureRecognizer)  {
        let point = ges.location(in: slider)
        let currentValue = point.x / slider.frame.size.width * CGFloat(slider.maximumValue)
        player.currentTime = Double(currentValue)
        slider.value = Float(currentValue)
        lblPlayTime.text = convertTime(second: Double(currentValue))
    }
    
    @objc func handleSliderPositionExit(sender:UISlider){

         print("silder handleSliderPositionExit .value\(sender.value)")
        player.currentTime = Double(sender.value)
        lblPlayTime.text = convertTime(second: Double(sender.value))
    }
    
    

    @objc func handleSliderPosition(sender:UISlider) {
        print(sender.value)
        player.currentTime = Double(sender.value)
        lblPlayTime.text = convertTime(second: Double(sender.value))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func convertTime(second:Double)->String{
        let d = Date(timeIntervalSince1970: TimeInterval(second))
        let format = DateFormatter()
        if second / 3600 >= 1{
            format.dateFormat = "HH:mm:ss"
        }
        else{
            format.dateFormat = "mm:ss"
        }
        return format.string(from: d)
    }
    
}

extension ShadowAudioPlayerView:ShadowPlayDelegate{
    func bufferProcess(current: Float,duration:Float) {
        print("缓冲进度\(current)")
        sliderBuffer.value = current
    }
    
    func playStateChange(status: PlayerStatus, info: MediaInfo?) {
        switch status {
            
        case .GetInfo:
            if info !=  nil{
                lblTotalTime.text = convertTime(second: info!.duration)
                slider.maximumValue = Float(info!.duration)
            }
        case .ReadyToPlay:
            btnPlay.isHidden = false
            vLoading.stopAnimating()
            if autoPlay{
                playAudio()
            }
        case .Finished:
            btnPlay.isSelected = false
            slider.value = 0
            lblPlayTime.text = "00:00"
            print("播放完成")
        case .Failed:
             vLoading.stopAnimating()
            btnPlay.isHidden = false
            btnPlay.isEnabled = false
        default:
            break
        }
    }
    
    func playProcess(current: Float,duration:Float) {
        print("播放进度\(current)")
        slider.value = current
        lblPlayTime.text = convertTime(second: Double(current))
    }
    
    
    
}
