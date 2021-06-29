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
    let postClipVideoUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/post/post_clip_video"
    let posrVideoResultUrl = "https://channels.weixin.qq.com/cgi-bin/mmfinderassistant-bin/post/post_clip_video_result"
    var token = ""
    let btnImg = UIButton()
    let btnUploadVideo = UIButton()
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
    var player : ShadowVideoPlayerView?
    var playUrl:AVURLAsset?
    var uploadVideoUrl : ImgUploadInfo!
    var uploadVideoInfo:UploadVideoInfo?
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        //第一步 获取token，再生成登录二维码
        self.userVideoInfo = userVideoStore.Value
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.createRect(size: CGSize(width: ScreenWidth, height: NavigationBarHeight), color: UIColor.red), for: .default)
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
        
        imagePickerController.didFinishPickingVideoHandle = {[weak self](coverImg,asset) in
            let option = PHVideoRequestOptions()
            option.isNetworkAccessAllowed = true
            option.progressHandler = {(pro,err,stop,info) in
                
                
            }
            PHImageManager.default().requestPlayerItem(forVideo: asset!, options: option) { item, dict in
                
                if let ass = item?.asset as? AVURLAsset{
                    self?.initPalyer(asset: ass)
                    self?.playUrl = ass
                }
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
        btnSaveVideo.addTarget(self, action: #selector(save), for: .touchUpInside)
        btnSaveVideo.setTitleColor(UIColor.darkGray, for: .normal)
        view.addSubview(btnSaveVideo)
        btnSaveVideo.snp.makeConstraints { m in
            m.centerX.equalTo(view)
            m.width.equalTo(120)
            m.height.equalTo(22)
            m.top.equalTo(lblImgurl.snp.bottom).offset(50)
        }
        
        btnUploadVideo.setTitle("保存视频", for: .normal)
        btnUploadVideo.addTarget(self, action: #selector(uploadVideo), for: .touchUpInside)
        btnUploadVideo.setTitleColor(UIColor.darkGray, for: .normal)
        view.addSubview(btnUploadVideo)
        btnUploadVideo.snp.makeConstraints { m in
            m.centerX.equalTo(view)
            m.width.equalTo(120)
            m.height.equalTo(22)
            m.top.equalTo(lblImgurl.snp.bottom).offset(350)
        }

    }
    
    func initPalyer(asset:AVURLAsset) {
        player = ShadowVideoPlayerView(frame: CGRect.zero, url: asset.url)
        view.addSubview(player!)
        player?.snp.makeConstraints({ m in
            m.left.right.equalTo(0)
            m.top.equalTo(lblImgurl.snp.bottom).offset(100)
            m.height.equalTo(200)
        })
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
    
    
    @objc func uploadVideo(){
        if self.userVideoInfo == nil || self.userVideoInfo.rawKeyBuffer.isEmpty {
            Toast.showToast(msg: "你没有登录")
            return
        }
        guard let url = playUrl?.url else {
            return
        }
        guard let data = try? Data(contentsOf: url) else{
            return
        }
        
        var datas = [Data]()
        var ranges = [(Int,Int)]()
        if data.count <= 524287 {
            datas.append(data)
        } else{
            var first = 0
            while (first + 524288) < data.count {
                let d = data.subdata(in: first..<first + 524288)
                ranges.append((first,first + 524287))
                first = first + 524288
                datas.append(d)
            }
            
            if first + 524288 - data.count > 0 {
                let d = data.subdata(in: first..<data.count)
                datas.append(d)
                ranges.append((first,data.count - 1))
            }
        }
        
        let finaName = "\(UUID.init().uuidString).mp4"
        let uuid = UUID.init().uuidString
        
  
        
        
        
        for item in datas.enumerated() {
            let dict1 = ["ver":1,
                        "seq":"1622529463503.6147",
                        "weixinnum":self.userVideoInfo.uin,
                        "apptype":self.userVideoInfo.appType,
                        "filetype":self.userVideoInfo.videoFileType,
                        "authkey":self.userVideoInfo.authKey,
                        "hasthumb":0,
                        "filekey":finaName,
                        "totalsize":data.count,
                        "fileuuid":uuid,
                        "rangestart":ranges[item.offset].0,
                        "rangeend":ranges[item.offset].1,
                        "blockmd5":item.element.md5,
                        "filedata":item.element,
                        "forcetranscode":0,
            ] as [String : Any]
            print(dict1)
            
            
            
            HttpClient.post(uploadImgUrl).addMultiParams(params: dict1).completion { [self] res, err in
                if err != nil || res == nil{
                    print(err?.localizedDescription ?? "request token error")
                    return
                }
                //最后一个
                if item.offset == datas.count - 1{
                    let js = JSON(res!)
                   // self.uploadVideoUrl =  js["fileurl"].stringValue
                    self.uploadVideoUrl = ImgUploadInfo()
                    self.uploadVideoUrl.url = js["fileurl"].stringValue
                    self.uploadVideoUrl.size = self.player?.videoRes ?? CGSize.zero
                    self.postClipVideo()
                }
            }
        }
        
        //获取视频封面
        guard let img = Tool.thumbnailImageForVideo(url: url) else{
            return
        }
        
        guard let data = img.compressWithMaxLength(maxLength: 210000) else{
            return
        }
        guard let data2 = img.compressWithMaxLength(maxLength: 50000) else{
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
            Toast.showToast(msg: "视频图片1上传成功")
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
            Toast.showToast(msg: "视频图片2上传成功")
        }
       
    }
    
    func postClipVideo() {
        let dict = [
            "x":0,
            "y":0,
            "width":self.uploadVideoUrl.size.width,
            "height":self.uploadVideoUrl.size.height,
            "targetWidth":self.uploadVideoUrl.size.width,
            "targetHeight":self.uploadVideoUrl.size.height,
            "url":self.uploadVideoUrl.newUrl,
            "timestamp":DateTime.now.timestamp.toString,
            "_log_finder_id":self.userVideoInfo.finderId,
            "rawKeyBuff":self.userVideoInfo.rawKeyBuffer,
            "scene":1
        ] as [String : Any]
        HttpClient.post(postClipVideoUrl).addParams(dict).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            guard let js = try? JSON(data: res!) else{
                print("request token error")
                return
            }
            let data = js["data"].dictionaryValue
            self.userVideoInfo.clipKey = data["clipKey"]?.stringValue ?? ""
            self.userVideoInfo.draftId = data["draftId"]?.stringValue ?? ""
            self.postVideoResult()
            
        }
    }
    
    func postVideoResult() {
        let dict = [
            "clipKey":self.userVideoInfo.clipKey,
            "draftId":self.userVideoInfo.draftId,
            "timestamp":DateTime.now.timestamp.toString,
            "_log_finder_id":self.userVideoInfo.finderId,
            "rawKeyBuff":self.userVideoInfo.rawKeyBuffer,
            "scene":1
        ] as [String : Any]
        HttpClient.post(posrVideoResultUrl).addParams(dict).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            guard let js = try? JSON(data: res!) else{
                print("request token error")
                return
            }
            let data = js["data"].dictionaryValue
            if data["flag"]?.intValue == 1{
                self.uploadVideoInfo = UploadVideoInfo()
                self.uploadVideoInfo?.duration = data["duration"]?.intValue ?? 0
                self.uploadVideoInfo?.vbitrate = data["vbitrate"]?.intValue ?? 0
                self.uploadVideoInfo?.vfps = data["vfps"]?.intValue ?? 0
                self.uploadVideoInfo?.height = data["height"]?.doubleValue ?? 0.0  
                self.uploadVideoInfo?.weight = data["width"]?.doubleValue ?? 0.0
                self.uploadVideoInfo?.md5 = data["md5"]?.stringValue ?? ""
                self.uploadVideoInfo?.fileSize = data["fileSize"]?.intValue ?? 0
                self.uploadVideoInfo?.url = data["url"]?.stringValue ?? ""
                self.uploadVideoInfo?.flag = data["flag"]?.intValue ?? 0
                Toast.showToast(msg: "视频上传成功")
            }
            else{
                 _ = delay(time: 2) {
                    self.postVideoResult()
                }
            }
        }
    }
    
     func saveImage() {
        let title = "好风景"
        var media = [[String:Any]]()
        let u1 = UUID().uuidString.lowercased()
        let mediaDict = ["url":currentUploadImg.newUrl,
                         "fileSize":currentUploadImg.dataSize,
                         "thumbUrl":currentUploadImg2.newUrl,
                         "mediaType":2,"videoPlayLen":0,
                         "width":currentUploadImg.size.width,
                         "height":currentUploadImg.size.height,
                         "md5sum":u1,
                         "fullThumbUrl":currentUploadImg.newUrl,
                         "fullUrl":currentUploadImg.newUrl,
                         "fullWidth":currentUploadImg.size.width,
                         "fullHeight":currentUploadImg.size.height,
                         "fullMd5sum":u1,
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
                    "topics":[],
                    "isFullPost":1,
                    "objectDesc":["description":title,"extReading":["link":"","title":""],"mediaType":2,"location":["latitude":22.5333194732666,"longitude":113.93041229248047,"city":"深圳市","poiClassifyId":""],"topic":"<finder><version>1</version><valuecount>1</valuecount><style><at></at></style><value0><![CDATA[\(title)]]></value0></finder>","mentionedUser":[],"media":media],
                    "clientid":UUID.init().uuidString.lowercased(),
                    "timestamp":DateTime.now.timestamp,
                    "_log_finder_id":self.userVideoInfo.finderId,
                    "rawKeyBuff":self.userVideoInfo.rawKeyBuffer,
                    "scene":1,] as [String : Any]
    
        HttpClient.post(postVideoUrl).addParams(dict).addHeaders(["Content-Type":"application/json;charset=UTF-8"]).completion { res, err in
            if err != nil || res == nil{
                print(err?.localizedDescription ?? "request token error")
                return
            }
            Toast.showToast(msg: "发布成功")
        }
    
    }
    
    
    @objc func save() {
        if uploadVideoInfo == nil {
            saveImage()
        }
        else{
            saveVideo()
        }
    }
    
    func saveVideo() {
        let title = "好风景"
        let uuid = UUID().uuidString
        var media = [[String:Any]]()
        let mediaDict = ["url":uploadVideoUrl.newUrl,
                         "fileSize":uploadVideoInfo!.fileSize,
                         "thumbUrl":currentUploadImg2.newUrl,
                         "mediaType":4,"videoPlayLen":uploadVideoInfo!.duration,
                         "width":uploadVideoInfo!.weight,
                         "height":uploadVideoInfo!.height,
                         "md5sum":uuid,
                         "coverUrl":currentUploadImg.newUrl,
                         "fullThumbUrl":currentUploadImg2.newUrl,
                         "fullUrl":uploadVideoUrl.newUrl,
                         "fullWidth":uploadVideoInfo!.weight,
                         "fullHeight":uploadVideoInfo!.height,
                         "fullMd5sum":uuid,
                         "fullFileSize":uploadVideoInfo!.fileSize,
                         "fullBitrate":0
        ] as [String : Any]
        media.append(mediaDict)
//        let mediaTict2 = ["url":"https://finder.video.qq.com/251/20304/stodownload?adaptivelytrans=0&bizid=1023&dotrans=0&encfilekey=RBfjicXSHKCOONJnTbRmmlD8cOQPXE48ibHow1QwQic0DgeTFGog4lLrwht93qUDryGAzyQJXATNDN82Z40jEntic3CUZUibIXiacckjXl6rOX1ckrGMHRmlvQLrU7ibAL8BTJAkMlylK7wibkdIt9KGYlgK459JhDxchx0mqoVspfqr6jo&hy=SH&idx=1&m=5b456657ca480bafcb5bddd25bce8d20&token=cztXnd9GyrGIiczRicibxiaCvZUFMLFsUTMLyEvx00y5WYMPQraCwCO9Oemk0JdfFRSz0GD0k44OPgiaGicvibv0fTEbQ",
//                          "fileSize":5240164,
//                          "thumbUrl":"https://finder.video.qq.com/251/20350/stodownload?adaptivelytrans=0&bizid=1023&dotrans=0&encfilekey=jEXicia3muM3GjTlk1Z3kYCefzc4VU4EAS0oDVwNGCD7up1RZGwoTI3se540dguxgqicffdlnaQA6NWJbo7HHfdfUIhXDKJibXAdote5Q0hoU4hsictFKEfCiaP9cChgso6pD7Wib7th95wgKKKADuECkTDvWVVIvytxTfT8TGyecQIz3o&hy=SH&idx=1&m=fc123086470d0daab178a252ce1a798b&token=cztXnd9GyrGIiczRicibxiaCvZUFMLFsUTMLJLg5qib3MtpWCW9ttibd1RFNvMQHy3JspGag0ukTZic47EtibypuibBvcXQ",
//                          "mediaType":2,"videoPlayLen":0,
//                          "width":1080,
//                          "height":719.928,
//                          "md5sum":"133c402d-ab8e-4ec5-8b46-a68fdd534e80",
//                        
//                          "fullThumbUrl":"https://finder.video.qq.com/251/20350/stodownload?adaptivelytrans=0&bizid=1023&dotrans=0&encfilekey=jEXicia3muM3GjTlk1Z3kYCefzc4VU4EAS0oDVwNGCD7up1RZGwoTI3se540dguxgqicffdlnaQA6NWJbo7HHfdfUIhXDKJibXAdote5Q0hoU4hJIejMAKbtXa3htVaibYUT4p7cnMfxSeqGglQUYpcxZaAElEEJTf0P46icQMJ8b2yNg&hy=SH&idx=1&m=fc123086470d0daab178a252ce1a798b&token=6xykWLEnztIJSCRG2ic7Xu9QfLhn2guCvjb8KwnRicoNJgs4dq9nDAwZMz22yZSiciaHqTCY6zd8SB099vAKwRfYAA",
//                          "fullUrl":"https://finder.video.qq.com/251/20304/stodownload?adaptivelytrans=0&bizid=1023&dotrans=0&encfilekey=RBfjicXSHKCOONJnTbRmmlD8cOQPXE48ibHow1QwQic0DgeTFGog4lLrwht93qUDryGAzyQJXATNDN82Z40jEntic3CUZUibIXiacckjXl6rOX1cmTfibRiaFMG4cGMzY7GFCz8GbzCo2LNPBslQVD2l2nD2Xr0g8ELA1OSon42hGN5M0Ls&hy=SH&idx=1&m=5b456657ca480bafcb5bddd25bce8d20&token=cztXnd9GyrGIiczRicibxiaCvZUFMLFsUTMLLjv9nQh6r7A0XmKVjpicbRZ9LDffGUC93asQVeppTaRhgWUsGSKLpbQ",
//                          "fullWidth":1080,
//                          "fullHeight":719.928,
//                          "fullMd5sum":"133c402d-ab8e-4ec5-8b46-a68fdd534e80",
//                          "fullFileSize":5240164,
//                          "fullBitrate":0
//         ] as [String : Any]
//        media.append(mediaTict2)
        let dict = ["objectType":0,
                    "longitude":0,
                    "latitude":0,
                    "feedLongitude":0,
                    "feedLatitude":0,
                    "originalFlag":0,
                    "topics":[],
                    "isFullPost":1,
                    "objectDesc":["description":title,"extReading":["link":"","title":""],"mediaType":4,"location":["latitude":22.5333194732666,"longitude":113.93041229248047,"city":"深圳市","poiClassifyId":""],"topic":"<finder><version>1</version><valuecount>1</valuecount><style><at></at></style><value0><![CDATA[\(title)]]></value0></finder>","mentionedUser":[],"media":media],
                    "report":[
                        "clipKey":userVideoInfo.clipKey,
                        "draftId":userVideoInfo.draftId,
                        "width":uploadVideoInfo!.weight,
                        "height":uploadVideoInfo!.height,
                        "duration":uploadVideoInfo!.duration,
                        "fileSize":uploadVideoInfo!.fileSize,
                        "uploadCost":2500
                    ],
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

struct UserVideoInfo: Codable {
     var token = ""
     var finderId = ""
     var rawKeyBuffer = ""
     var authKey = ""
     var clipKey = ""
     var draftId = ""
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

class UploadVideoInfo {
    var duration = 0
    var vbitrate = 0
    var vfps = 0
    var height = 0.0
    var weight = 0.0
    var md5 = ""
    var fileSize = 0
    var url = ""
    var flag = 1
}
