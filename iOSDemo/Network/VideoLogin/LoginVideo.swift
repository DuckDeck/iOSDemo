//
//  LoginVideo.swift
//  iOSDemo
//
//  Created by chen liang on 2021/6/1.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import UIKit
import GrandTime
import SwiftyJSON
class WechatVideoViewController: BaseViewController, TZImagePickerControllerDelegate {
    
    let loginCodeUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_login_code"
    let loginStatusUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_login_status"
    let finderListUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_finder_list"
    let rawKeyUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_set_finder"
    let uploadParaUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/helper/helper_upload_params"
    var token = ""
    let img = UIImageView()
    var loginSatus = 0
    var timer:GrandTimer!
    var finderId = ""
    var rawKeyBuffer = ""
    var uploadPara = [String:JSON]()
    var userInfo = [String:JSON]()
    var imagePickerController:TZImagePickerController!

    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        //第一步 获取token，再生成登录二维码
        getToken()
        //第二步，生成二维码
        //第三步，开始轮询
        view.addSubview(img)
        img.snp.makeConstraints { m in
            m.centerX.equalTo(view)
            m.width.height.equalTo(200)
            m.top.equalTo(100)
        }
        timer = GrandTimer.every(TimeSpan.fromSeconds(3), block: {
            self.requestLoginStatus()
        })
        
        img.isUserInteractionEnabled = true
        img.addTapGesture { [weak self] ges in
            self?.present(self!.imagePickerController, animated: true, completion: nil)
        }
        
        imagePickerController = TZImagePickerController(maxImagesCount: 3, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            if let one = images?.first{
                self?.img.image = one
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "上传", style: .plain, target: self, action: #selector(uploadImage))
    }
    
    func getToken() {
        HttpClient.post(loginCodeUrl).addParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":""]).completion { data, err in
            if err != nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if let js = try? JSON(data: data!){
                self.token = js["data"]["token"].stringValue
                self.img.image =  self.createBarcode()
                self.timer.fire()
            }
            else{
                print("request token error")
            }
        }
    }
    
    func createBarcode() -> UIImage? {
        if token.isEmpty {
            Toast.showToast(msg: "没有token")
            return nil
        }
        let url = "https://channels.weixin.qq.com/mobile/confirm.html?token=\(token)"
        return UIImage.creatQRCodeImage(text: url);
    }
    
    func requestLoginStatus() {
        HttpClient.post(loginStatusUrl).addUrlParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":NSNull.self,"token":token]).completion { data, err in
            if err != nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if data == nil{
                self.timer.invalidate()
                return
            }
            if let js = try? JSON(data: data!){
                let data = js["data"].dictionaryValue
                let accStatus = data["acctStatus"]?.intValue ?? 0
                self.loginSatus = data["status"]?.intValue ?? 4
                if self.loginSatus == 4 {
                    self.timer.invalidate()
                    self.refreshToken()
                }
                if accStatus == 5 && self.loginSatus == 1 {
                    Toast.showToast(msg: "已经扫码，请在手机上登录")
                }
                if accStatus == 1 && self.loginSatus == 1 {
                    Toast.showToast(msg: "登录成功")
                    self.timer.invalidate()
                    
                    self.getFinder()
                }
            }
            else{
                print("request token error")
            }
        }
    }
    
    func refreshToken() {
        let alert = UIAlertController.init(title: "二维码已经过期", message: "是否刷新", preferredStyle: .alert).action(title: "刷新") { action in
            self.getToken()
        }
        alert.show()
    }
    
    func getFinder() {
        HttpClient.post(finderListUrl).addUrlParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":NSNull.self,"rawKeyBuff":NSNull.self]).completion { data, err in
            if err != nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if let js = try? JSON(data: data!){
                let data = js["data"].dictionaryValue
                self.userInfo = (data["finderList"]?.arrayValue.first!.dictionaryValue)!
                self.finderId = self.userInfo["finderUsername"]!.stringValue
                self.getRawKey()
            }
            else{
                print("request token error")
            }
        }
    }
    
    func getRawKey() {
        HttpClient.post(finderListUrl).addUrlParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":NSNull.self,"rawKeyBuff":NSNull.self,"finderUsername":self.finderId]).completion { data, err in
            if err != nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if let js = try? JSON(data: data!){
                let data = js["data"].dictionaryValue
                self.rawKeyBuffer = data["rawKeyBuff"]!.stringValue
                self.getUploadPara()
            }
            else{
                print("request token error")
            }
        }
    }
    
    func authData() {
        
    }
    
    func getUploadPara() {
        HttpClient.post(uploadParaUrl).addUrlParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":self.finderId,"rawKeyBuff":NSNull.self]).completion { data, err in
            if err != nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if let js = try? JSON(data: data!){
                self.uploadPara = js["data"].dictionaryValue
            }
            else{
                print("request token error")
            }
        }
    }
    
   
    
    @objc func uploadImage() {
        
    }
}

