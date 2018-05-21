//
//  ShadowControlView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/21.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

protocol ShadowControlViewDelegate:class {
    func controlView(view:ShadowControlView,pointSliderLocationWithCurrentValue:Float)
    func controlView(view:ShadowControlView,draggedPositionWithSlider:UISlider)
    func controlView(view:ShadowControlView,withLargeButton:UIButton)
}

class ShadowControlView: UIView {
    let btnLarge = UIButton(type: UIButtonType.custom)
    var value:Float{
        set{
            slider.value = newValue
        }
        get{
            return slider.value
        }
    }
    var minValue:Float{
        set{
            slider.minimumValue = newValue
        }
        get{
            return slider.minimumValue
        }
    }
    var maxValue:Float{
        set{
            slider.maximumValue = newValue
        }
        get{
            return slider.maximumValue
        }
    }
    var currentTime:String{
        set{
            lblTime.text = newValue
        }
        get{
            return lblTime.text!
        }
    }
    var totalTime:String{
        set{
            lblTotalTime.text = newValue
        }
        get{
            return lblTotalTime.text!
        }
    }
    var bufferValue:Float {
        get{
            return sliderBuffer.value
        }
        set{
            sliderBuffer.value = newValue
        }
    }
    var tapGesture:UITapGestureRecognizer?
    weak var delegate:ShadowControlViewDelegate?
    private let lblTime = UILabel()
    private let lblTotalTime = UILabel()
    private let slider = UISlider()        // show the play process
    private let sliderBuffer = UISlider()  //use to buffer the internet video
    
    var padding = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        lblTime.textAlignment = .right
        lblTime.font = UIFont.systemFont(ofSize: 12)
        lblTime.textColor = UIColor.white
        addSubview(lblTime)
       
        
        lblTotalTime.textAlignment = .left
        lblTotalTime.font = UIFont.systemFont(ofSize: 12)
        lblTotalTime.textColor = UIColor.white
        addSubview(lblTotalTime)
        
        
        slider.setThumbImage(#imageLiteral(resourceName: "knob"), for: .normal)
        slider.isContinuous = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(ges:)))
        slider.addTarget(self, action: #selector(handleSliderPosition(sender:)), for: .valueChanged)
        slider.addGestureRecognizer(tapGesture!)
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor.white
        addSubview(slider)
       
        
        
        btnLarge.contentMode = .scaleAspectFill
        btnLarge.setImage(#imageLiteral(resourceName: "full_screen"), for: .normal)
        btnLarge.addTarget(self, action: #selector(hanleFullScreen(sender:)), for: .touchUpInside)
        addSubview(btnLarge)
       
        
        sliderBuffer.setThumbImage(UIImage(), for: .normal)
        sliderBuffer.isContinuous = true
        sliderBuffer.minimumTrackTintColor = UIColor.red
        sliderBuffer.minimumValue = 0
        sliderBuffer.maximumValue = 1
        sliderBuffer.isUserInteractionEnabled = false
        addSubview(sliderBuffer)
        addConstraintsForSubviews()
      
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func addConstraintsForSubviews() {
        lblTime.snp.makeConstraints { (m) in
            m.left.equalTo(0)
            m.bottom.equalTo(-padding)
            m.right.equalTo(-padding).priority(10)
            m.width.equalTo(50)
        }
        slider.snp.makeConstraints { (m) in
            m.left.equalTo(lblTime.snp.right).offset(padding)
            m.right.equalTo(lblTotalTime.snp.left).offset(-padding)
            m.centerY.equalTo(lblTime)
            if ScreenWidth < ScreenWidth{
                m.width.equalTo(ScreenWidth - padding * 3 - 50 - 50 - 30)
            }
        }
        lblTotalTime.snp.makeConstraints { (m) in
            m.right.equalTo(btnLarge.snp.left).offset(-padding)
            m.centerY.equalTo(lblTime)
            m.width.equalTo(50).priority(20)
        }
        btnLarge.snp.makeConstraints { (m) in
            m.centerY.equalTo(lblTime)
            m.width.equalTo(30)
            m.right.equalTo(-padding)
        }
        sliderBuffer.snp.makeConstraints { (m) in
            m.edges.equalTo(slider)
        }
        layoutIfNeeded()
    }
    
    @objc func handleTap(ges:UIGestureRecognizer)  {
        let point = ges.location(in: slider)
        let currentValue = point.x / slider.frame.size.width * CGFloat(slider.maximumValue)
        delegate?.controlView(view: self, pointSliderLocationWithCurrentValue: Float(currentValue))
    }
    
    @objc func handleSliderPosition(sender:UISlider) {
        delegate?.controlView(view: self, draggedPositionWithSlider: slider)
    }
    
    @objc func hanleFullScreen(sender:UIButton)  {
        delegate?.controlView(view: self, withLargeButton: sender)
    }
    
    @objc func deviceOrientationDidChange() {
        addConstraintsForSubviews()
    }
}
