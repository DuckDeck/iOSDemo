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
import GrandModel
import GrandStore
let userVideoStore = GrandStore(name: "userVideoStore", defaultValue: UserVideoInfo())

class WechatVideoViewController: BaseViewController, TZImagePickerControllerDelegate {
    
    let loginCodeUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_login_code"
    let loginStatusUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_login_status"
    let finderListUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_finder_list"
    let rawKeyUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/auth/auth_set_finder"
    let uploadParaUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/helper/helper_upload_params"
    let uploadImgUrl = "https://finderpre.video.qq.com/snsuploadbig"
    let postVideoUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/post/post_create"
    let notifUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/notification/notification_list"
    var token = ""
    let btnImg = UIButton()
    var loginSatus = 0
    var timer:GrandTimer!
    var finderId = ""
    var rawKeyBuffer = ""
    var uploadPara = [String:JSON]()
    var userInfo = [String:JSON]()
    var imagePickerController:TZImagePickerController!
    let lblImgurl = UILabel()
    var userVideoInfo : UserVideoInfo!
    var currentUploadImg : ImgUploadInfo!
    var currentUploadImg2 : ImgUploadInfo!
    let btnSaveVideo = UIButton()
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        //第一步 获取token，再生成登录二维码
        self.userVideoInfo = userVideoStore.Value
       
        //第二步，生成二维码
        //第三步，开始轮询
        view.addSubview(btnImg)
        btnImg.snp.makeConstraints { m in
            m.centerX.equalTo(view)
            m.width.height.equalTo(200)
            m.top.equalTo(100)
        }
        timer = GrandTimer.every(TimeSpan.fromSeconds(3), block: {
            self.requestLoginStatus()
        })
        

        btnImg.setTitleColor(UIColor.darkGray, for: .normal)
        btnImg.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        
        imagePickerController = TZImagePickerController(maxImagesCount: 3, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            if let one = images?.first{
                self?.btnImg.setImage(one, for: .normal)
            }
        }
        
        let btn1 = UIBarButtonItem(title: "上传", style: .plain, target: self, action: #selector(uploadImage))
        let btn2 = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItems = [btn2,btn1]
        
        lblImgurl.textColor = UIColor.darkGray
        view.addSubview(lblImgurl)
        lblImgurl.snp.makeConstraints { m in
            m.centerX.equalTo(view)
            m.top.equalTo(btnImg.snp.bottom).offset(50)
        }
        
        if !userVideoInfo.rawKeyBuffer.isEmpty {
            getNotif()
            btnImg.setTitle("选择图片", for: .normal)
        }
        else{
            getToken()
        }
        
        btnSaveVideo.setTitle("保存视频号", for: .normal)
        btnSaveVideo.addTarget(self, action: #selector(saveVideo), for: .touchUpInside)
        btnSaveVideo.setTitleColor(UIColor.darkGray, for: .normal)
        view.addSubview(btnSaveVideo)
        btnSaveVideo.snp.makeConstraints { m in
            m.centerX.equalTo(view)
            m.width.equalTo(120)
            m.height.equalTo(22)
            m.top.equalTo(lblImgurl.snp.bottom).offset(50)
        }
        
    }
    
    func getToken() {
        HttpClient.post(loginCodeUrl).addParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":""]).completion { data, err in
            if err != nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if let js = try? JSON(data: data!){
                self.token = js["data"]["token"].stringValue
                self.btnImg.setImage(self.createBarcode(), for: .normal)
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
    
    func getNotif() {
        let dict = ["currentPage":1,"pageSize":20,"rawKeyBuff":self.userVideoInfo.rawKeyBuffer,"reqType":0,"scene":1,"timestamp":DateTime.now.timestamp.toString,"_log_finder_id":self.userVideoInfo.finderId] as [String:Any]
        HttpClient.post(notifUrl).addParams(dict).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            if let js = try? JSON(data:res!){
                if js["errCode"].intValue != 0{
                    if js["errCode"].intValue == 300333 {
                        Toast.showToast(msg: "账号已经过期")
                        let alert = UIAlertController.init(title: "账号已经过期", message: "是否退出", preferredStyle: .alert).action(title: "是") { action in
                            self.logout()
                        }
                        alert.show()
                    }
                }
                else{
                    Toast.showToast(msg: js["errMsg"].stringValue)
                }
            }
        }
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
                else if accStatus == 5 && self.loginSatus == 1 {
                    Toast.showToast(msg: "已经扫码，请在手机上登录")
                }
                else if accStatus == 5 && self.loginSatus == 2 {
                    Toast.showToast(msg: "你没有开通视频号，开通后再试")
                }
                else if accStatus == 1 && self.loginSatus == 1 {
                    Toast.showToast(msg: "登录成功")
                    self.timer.invalidate()
                    self.btnImg.setImage(nil, for: .normal)
                    self.btnImg.setTitle("选择图片", for: .normal)
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
        HttpClient.post(rawKeyUrl).addUrlParams(["scene":1,"timestamp":DateTime.now.timestamp,"_log_finder_id":NSNull.self,"rawKeyBuff":NSNull.self,"finderUsername":self.finderId]).completion { data, err in
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
                self.userVideoInfo.authKey = self.uploadPara["authKey"]?.stringValue ?? ""
                self.userVideoInfo.uin = self.uploadPara["uin"]?.intValue ?? 0
                self.userVideoInfo.token = self.token
                self.userVideoInfo.rawKeyBuffer = self.rawKeyBuffer
                self.userVideoInfo.finderId = self.finderId
                
                userVideoStore.Value = self.userVideoInfo
                
            }
            else{
                print("request token error")
            }
        }
    }
    
    @objc func chooseImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
   
    
    @objc func logout(){
        let alert = UIAlertController(title: "登出", message: "你要登出吗？", preferredStyle: UIAlertController.Style.alert).action(title: "取消") {action in
            
        }.action(title: "确定") { action in
            userVideoStore.clear()
            self.navigationController?.popViewController(animated: true)
        }
        alert.show()
    }
    @objc func uploadImage() {
        if self.userVideoInfo == nil || self.userVideoInfo.rawKeyBuffer.isEmpty {
            Toast.showToast(msg: "你没有登录")
            return
        }
        guard let data = btnImg.image(for: .normal)?.compressWithMaxLength(maxLength: 210000) else{
            return
        }
        guard let data2 = btnImg.image(for: .normal)?.compressWithMaxLength(maxLength: 50000) else{
            return
        }
        let dict1 = ["ver":1,
                    "seq":"1622529463503.6147",
                    "weixinnum":self.userVideoInfo.uin,
                    "apptype":self.userVideoInfo.appType,
                    "filetype":self.userVideoInfo.pictureFileType,
                    "authkey":self.userVideoInfo.authKey,
                    "hasthumb":0,
                    "filekey":"finder_video_img.jpeg",
                    "totalsize":data.count,
                    "fileuuid":UUID.init().uuidString,
                    "rangestart":0,
                    "rangeend":data.count - 1,
                    "blockmd5":data.md5,
                    "filedata":data,
                    "forcetranscode":0,
        ] as [String : Any]
        print(dict1)
        HttpClient.post(uploadImgUrl).addMultiParams(params: dict1).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            let js = JSON(res!)
            self.currentUploadImg = ImgUploadInfo()
            self.currentUploadImg.dataSize = data.count
            self.currentUploadImg.url = js["fileurl"].stringValue
            self.currentUploadImg.md5 = data.md5
            self.currentUploadImg.size = UIImage(data: data)!.size
            Toast.showToast(msg: "图片1上传成功")
        }
        
        let dict2 = ["ver":1,
                    "seq":"1622529463513.23",
                    "weixinnum":self.userVideoInfo.uin,
                    "apptype":self.userVideoInfo.appType,
                    "filetype":self.userVideoInfo.pictureFileType,
                    "authkey":self.userVideoInfo.authKey,
                    "hasthumb":0,
                    "filekey":"finder_video_img.jpeg",
                    "totalsize":data2.count,
                    "fileuuid":UUID.init().uuidString,
                    "rangestart":0,
                    "rangeend":data2.count - 1,
                    "blockmd5":data2.md5,
                    "filedata":data2,
                    "forcetranscode":0,
        ] as [String : Any]
        
        HttpClient.post(uploadImgUrl).addMultiParams(params: dict2).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            let js = JSON(res!)
            self.currentUploadImg2 = ImgUploadInfo()
            self.currentUploadImg2.dataSize = data2.count
            self.currentUploadImg2.url = js["fileurl"].stringValue
            self.currentUploadImg2.md5 = data2.md5
            self.currentUploadImg2.size = UIImage(data: data2)!.size
            Toast.showToast(msg: "图片2上传成功")
        }
    }
    
    
    @objc func saveVideo() {
        let title = "好风景"
        var media = [[String:Any]]()
        let mediaDict = ["url":currentUploadImg.newUrl,
                         "fileSize":currentUploadImg.dataSize,
                         "thumbUrl":currentUploadImg2.newUrl,
                         "mediaType":2,"videoPlayLen":0,
                         "width":currentUploadImg.size.width,
                         "height":currentUploadImg.size.height,
                         "md5sum":currentUploadImg.md5,
                         "fullThumbUrl":currentUploadImg.newUrl,
                         "fullUrl":currentUploadImg.newUrl,
                         "fullWidth":currentUploadImg.size.width,
                         "fullHeight":currentUploadImg.size.height,
                         "fullMd5sum":currentUploadImg.md5,
                         "fullFileSize":currentUploadImg.dataSize,
                         "fullBitrate":0
        ] as [String : Any]
        media.append(mediaDict)
        let dict = ["objectType":0,
                    "longitude":0,
                    "latitude":0,
                    "feedLongitude":0,
                    "feedLatitude":0,
                    "originalFlag":0,
                    "topics":[String](),
                    "isFullPost":1,
                    "objectDesc":["description":title,"extReading":["link":"","title":""],"mediaType":2,"location":["latitude":22.5333194732666,"longitude":113.93041229248047,"city":"深圳市","poiClassifyId":""],"topic":"<finder><version>1</version><valuecount>1</valuecount><style><at></at></style><value0><![CDATA[\(title)]]></value0></finder>","mentionedUser":[],"media":media],
                    "clientid":UUID.init().uuidString.lowercased(),
                    "timestamp":DateTime.now.timestamp,
                    "_log_finder_id":self.userVideoInfo.finderId,
                    "rawKeyBuff":self.userVideoInfo.rawKeyBuffer,
                    "scene":1,] as [String : Any]
    
        HttpClient.post(postVideoUrl).addParams(dict).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            Toast.showToast(msg: "发布成功")
        }
    
    }
    
    
    
    
}

@objcMembers class UserVideoInfo: GrandModel {
     var token = ""
     var finderId = ""
     var rawKeyBuffer = ""
     var authKey = ""
     var uin = 0
     var appType = 251
     var videoFileType = 20302
     var pictureFileType = 20304
     var thumbFileType = 20350
}

class ImgUploadInfo {
    var url = ""
    var dataSize = 0
    var size = CGSize()
    var md5 = ""
    var newUrl:String{
        return url.replacingOccurrences(of: "http://wxapp.tc.qq.com", with: "https://finder.video.qq.com")
    }
}
