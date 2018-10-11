//
//  TimerButton.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
@objc enum TimerButtonStatus:Int {
    case normal,countDown,reGet
}

@objc class TimerButton: UIButton {
    
    private var countDown = 60 //this is the default time to cound down
    
    @objc var timerToCountDown = 60 {
        didSet {
            countDown = timerToCountDown
        }
    }
    
    @objc var timerButtonStatus:TimerButtonStatus = TimerButtonStatus.normal {
        didSet {
            if let block = backgroundBlock {
                let color = block(timerButtonStatus)
                backgroundColor = color
            }
        }
    }
    @objc var titleBlock:((_ second:Int,_ status:TimerButtonStatus)->String)? //use this go get the title
    @objc var backgroundBlock:((_ status:TimerButtonStatus)->UIColor)?
    private var timer:Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc private func timerTick(timer:Timer) {
        weak var weakSelf = self
        if  countDown >= 0 {
            countDown -= 1
        } else {
            isEnabled = true
            timerButtonStatus = .reGet
            weakSelf?.timer!.invalidate()
            weakSelf?.timer = nil
            //custom the color later
            //weakSelf?.setBorder(0.5, color: UIColor(hexString: "c4c4c4"), radius: 3)
            // weakSelf?.setTitleColor(UIColor.black, for: .normal)
        }
        if let block = titleBlock {
            let title = block(countDown + 1, timerButtonStatus)
            setTitle(title, for: UIControl.State.normal)
        }
    }
    
    //    override func willMoveToSuperview(newSuperview: UIView?) {
    //        super.willMoveToSuperview(newSuperview)
    //        timerButtonStatus = TimerButtonStatus.normal
    //    }
    
    @objc func startCount() {
        layer.borderWidth = 0
        //custom the color later
        // setTitleColor(Theme.ColorTextGray, forState: .Normal)
        if timerButtonStatus == .countDown {
            return
        }
        if timerButtonStatus == .reGet {
            resetTimeButton()
        }
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerButton.timerTick(timer:)), userInfo: nil, repeats: true)
        }
        timer?.fire()
        timerButtonStatus = .countDown
        isEnabled = false
    }
    
    @objc func resetTimeButton() {
        timerButtonStatus = .normal
        countDown = timerToCountDown
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
