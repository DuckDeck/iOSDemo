//
//  ShadowAudioPlayerView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/6/9.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class ShadowAudioPlayerView: UIView {

    let btnPlay = UIButton()
    let lblPlayTime = UILabel()
    let lblTotalTime = UILabel()
    var url:URL!
    let slider = UISlider()
    let sliderBuffer = UISlider()
    var player:ShadowAudioPlayer!
    var audioDuration:Double = 0
    var tapGesture:UITapGestureRecognizer?
    var autoPlay = false
    convenience init(frame: CGRect,url:URL,autoPlay:Bool = false) {
        self.init(frame: frame)
        self.url = url
        self.autoPlay = autoPlay
         initView()
        initPlayer()
    }
    
   fileprivate func initView() {
        btnPlay.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        btnPlay.setImage(#imageLiteral(resourceName: "pause"), for: .selected)
        btnPlay.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        addSubview(btnPlay)
        btnPlay.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.centerY.equalTo(self)
            m.width.height.equalTo(25)
        }
        
        lblPlayTime.font = UIFont.systemFont(ofSize: 14)
        lblPlayTime.textColor = UIColor.red
        addSubview(lblPlayTime)
        lblPlayTime.snp.makeConstraints { (m) in
            m.left.equalTo(btnPlay.snp.right).offset(3)
            m.centerY.equalTo(self)
            m.width.equalTo(62)
        }
        
        lblTotalTime.font = UIFont.systemFont(ofSize: 14)
        lblTotalTime.textColor = UIColor.red
        addSubview(lblTotalTime)
        lblTotalTime.snp.makeConstraints { (m) in
            m.right.equalTo(0)
            m.centerY.equalTo(self)
            m.width.equalTo(62)
        }
        
        slider.setThumbImage(#imageLiteral(resourceName: "knob"), for: .normal)
        slider.isContinuous = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(ges:)))
        slider.addTarget(self, action: #selector(handleSliderPosition(sender:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(handleSliderPositionExit(sender:)), for: UIControlEvents.touchUpInside)
        slider.addGestureRecognizer(tapGesture!)
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor.white
        addSubview(slider)
        
        slider.snp.makeConstraints { (m) in
            m.left.equalTo(lblPlayTime.snp.right)
            m.right.equalTo(lblTotalTime.snp.left)
            m.centerY.equalTo(self)
        }
        
        sliderBuffer.setThumbImage(UIImage(), for: .normal)
        sliderBuffer.isContinuous = true
        sliderBuffer.minimumTrackTintColor = UIColor.red
        sliderBuffer.minimumValue = 0
        sliderBuffer.maximumValue = 1
        sliderBuffer.isUserInteractionEnabled = false
        addSubview(sliderBuffer)
        sliderBuffer.snp.makeConstraints { (m) in
            m.edges.equalTo(slider)
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
        player = ShadowAudioPlayer(urlAsset: url, startAutoPlay: autoPlay, repeatAfterEnd: false)
        player.delegate = self
    }
    
    func showAudioErrorInfo() {
        btnPlay.isSelected = true
        lblTotalTime.text = "00:00:00"
        lblPlayTime.text = "00:00:00"
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
            player.cleanUp()
            player = nil
        }
    }
    
    
    @objc func handleTap(ges:UIGestureRecognizer)  {
        let point = ges.location(in: slider)
        let currentValue = point.x / slider.frame.size.width * CGFloat(slider.maximumValue)
        
    }
    
    @objc func handleSliderPositionExit(sender:UISlider){
        print("exit")
       
    }
    
    @objc func handleSliderPosition(sender:UISlider) {
        print(sender.value)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func convertDurationToTime(duration:Int) -> String {
        let hour = duration / 3600
        let remainder = duration - (hour * 3600)
        let min = remainder / 60
        let sec = remainder - 60 * min
        
        return "\(hour):\(min):\(sec)"
    }
    
}

extension ShadowAudioPlayerView:VideoPlayerDelegate{
    func readyToPlay(assetDuration: Double) {
        lblPlayTime.text = "00:00:00"
        self.audioDuration = assetDuration
        lblTotalTime.text = convertDurationToTime(duration: Int(self.audioDuration))
    }
    
    func downloadedProgress(progress: Double) {
        print(progress)
    }
    
    func didUpdateProgress(progress: Double) {
        
    }
    
    func didFinishPlayItem() {
        
    }
    
    func didFailPlayToEnd() {
        
    }
    
    
}
