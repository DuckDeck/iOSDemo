//
//  SettingViewController.swift
//  TouchTest
//
//  Created by Tyrant on 6/5/15.
//  Copyright (c) 2015 Tyrant. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    var switchShowTrace:UISwitch?
    var switchKeepTrace:UISwitch?
    var switchShowCoordinate:UISwitch?
    var sliderTraceThickness:UISlider?
    var lblTraceThicknessNum:UILabel?
    var btnBack:UIButton?
    var lblSupportMaxTouches:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        let lblTitle = UILabel(frame: CGRect(x:130,y:20,width: 60,height: 40))
        lblTitle.text = "设置"
        lblTitle.font = UIFont.systemFont(ofSize: 24)
        lblTitle.textColor = UIColor.white
        view.addSubview(lblTitle)
        let lblShowTrace = UILabel(frame: CGRect(x:30, y:80,width: 120,height: 32))
        lblShowTrace.text = "显示触摸痕迹"
        lblShowTrace.textColor = UIColor.white
        view.addSubview(lblShowTrace)
        switchShowTrace = UISwitch(frame: CGRect(x: UIScreen.main.bounds.width-100, y: 80, width: 80, height: 50))
        switchShowTrace?.tag = 0
        switchShowTrace?.addTarget(self, action: #selector(SettingViewController.switchValueChange(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(switchShowTrace!)
        let lblKeepTrace = UILabel(frame: CGRect(x:30, y:130, width:130,height: 32))
        lblKeepTrace.text = "保留触摸痕迹"
        lblKeepTrace.textColor = UIColor.white
        view.addSubview(lblKeepTrace)
        switchKeepTrace = UISwitch(frame: CGRect(x:UIScreen.main.bounds.width-100, y: 130, width: 80, height: 50))
        switchKeepTrace?.tag = 1
        switchKeepTrace?.addTarget(self, action: #selector(SettingViewController.switchValueChange(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(switchKeepTrace!)
        let lblShowCoordinate = UILabel(frame: CGRect(x:30,y: 180,width: 120,height: 32))
        lblShowCoordinate.text = "显示触摸坐标"
        lblShowCoordinate.textColor = UIColor.white
        view.addSubview(lblShowCoordinate)
        switchShowCoordinate = UISwitch(frame: CGRect(x:UIScreen.main.bounds.width-100, y: 180, width: 80, height: 50))
        switchShowCoordinate?.tag = 2
        switchShowCoordinate?.addTarget(self, action: #selector(SettingViewController.switchValueChange(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(switchShowCoordinate!)
        
        let lblTraceThickness = UILabel(frame: CGRect(x:30, y:230,width: 120,height: 35))
        lblTraceThickness.text = "痕迹宽度"
        lblTraceThickness.textColor = UIColor.white
        view.addSubview(lblTraceThickness)
        
        lblTraceThicknessNum = UILabel(frame: CGRect(x:UIScreen.main.bounds.width-70, y:230,width: 50, height:35))
        lblTraceThicknessNum?.textColor = UIColor.green
        lblTraceThicknessNum?.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(lblTraceThicknessNum!)
        
        sliderTraceThickness = UISlider(frame: CGRect(x:10, y:270, width:UIScreen.main.bounds.width-20,height: 20))
        sliderTraceThickness?.maximumValue = 30
        sliderTraceThickness?.minimumValue = 0.5
        sliderTraceThickness?.addTarget(self, action: #selector(SettingViewController.sliderValueChange(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(sliderTraceThickness!)
        
        
        lblSupportMaxTouches = UILabel(frame: CGRect(x:20, y:300, width:UIScreen.main.bounds.width-40, height:30))
        lblSupportMaxTouches?.textAlignment = NSTextAlignment.center
        view.addSubview(lblSupportMaxTouches!)
        
        btnBack = UIButton(frame: CGRect(x:UIScreen.main.bounds.width*0.5-15,y: UIScreen.main.bounds.height-30,width: 30,height: 30))
        btnBack?.setImage(UIImage(named: "public_btn_back_white_solid"), for: .normal)
        btnBack?.layer.borderWidth = 2
        btnBack?.layer.borderColor = UIColor.white.cgColor
        btnBack?.layer.cornerRadius = 15
        btnBack?.addTarget(self, action: #selector(SettingViewController.back(sender:)), for: UIControl.Event.touchUpInside)
        view.addSubview(btnBack!)
        
        let lblAuthor = UILabel(frame: CGRect(x: 20, y: 350, width: UIScreen.main.bounds.width-40, height: 30))
        lblAuthor.text = "Design And Program By Gforce"
        lblAuthor.textAlignment = NSTextAlignment.center
        lblAuthor.textColor = UIColor.white
        view.addSubview(lblAuthor)
        
        let lblLanguage = UILabel(frame: CGRect(x: 20, y: 380, width: UIScreen.main.bounds.width-40, height: 30))
        lblLanguage.text = "Power By Swift Language"
        lblLanguage.textAlignment = NSTextAlignment.center
        lblLanguage.textColor = UIColor.white
        view.addSubview(lblLanguage)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillData()
    }
    
    func fillData(){
        switchShowTrace?.isOn = Settings.needShowTrace.Value!
        switchKeepTrace?.isOn = Settings.needKeepTrace.Value!
        switchShowCoordinate?.isOn = Settings.needShowCoordinate.Value!
        sliderTraceThickness?.value = Settings.traceThickness.Value!
        if !Settings.needShowTrace.Value!
        {
            switchKeepTrace?.isEnabled = false
        }
        else
        {
            switchKeepTrace?.isEnabled = true
        }
        lblTraceThicknessNum?.text = NSString(format: "%4.2f", Settings.traceThickness.Value!) as String
        let maxPoints = NSMutableAttributedString(string:NSString(format: "你的设置最多支持%d点触摸", Settings.maxSupportTouches.Value!) as String )
        maxPoints.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, maxPoints.length))
        maxPoints.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSMakeRange(8, 1))
        maxPoints.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSMakeRange(0, maxPoints.length))
        lblSupportMaxTouches?.attributedText = maxPoints
    }
    
    @objc func switchValueChange(sender:UISwitch){
        switch sender.tag
        {
        case 0:
            Settings.needShowTrace.Value = sender.isOn
            if !sender.isOn{
                switchKeepTrace?.isOn = false
                switchKeepTrace?.isEnabled = false
                Settings.needKeepTrace.Value = false
            }
            else{
                switchKeepTrace?.isEnabled = true
            }
        case 1:
            Settings.needKeepTrace.Value = sender.isOn
        case 2:
            Settings.needShowCoordinate.Value = sender.isOn
        default:
            break
        }
    }
    
    @objc func sliderValueChange(sender:UISlider)
    {
        Settings.traceThickness.Value = sender.value
        lblTraceThicknessNum?.text = NSString(format: "%4.2f", Settings.traceThickness.Value!) as String
    }
    
    @objc func back(sender:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
