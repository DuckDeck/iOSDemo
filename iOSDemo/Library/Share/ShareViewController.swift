//
//  ShareViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/7/23.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
import Social
let Share_Weixin = "com.tencent.xin.sharetimeline"
class ShareViewController: BaseViewController {
    let btnOrigin = UIButton()
    let btnSocialSina = UIButton()
    let btnSocialWebchat = UIButton()
    let btnShareCollect = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        btnOrigin.title(title: "原生的ActivityViewController").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.top.equalTo(NavigationBarHeight + 20)
        }
        
        btnOrigin.addTarget(self, action: #selector(originShare), for: .touchUpInside)
        
        btnSocialSina.title(title: "使用Social Framework 分享到 新浪").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.top.equalTo(btnOrigin).offset(50)
        }
        
        btnSocialSina.addTarget(self, action: #selector(shareToSina), for: .touchUpInside)
        
        btnSocialWebchat.title(title: "使用Social Framework 分享到 微信").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.top.equalTo(btnSocialSina).offset(50)
        }
        
        btnSocialWebchat.addTarget(self, action: #selector(shareToWebchat), for: .touchUpInside)
        
        btnShareCollect.title(title: "自定义分享界面").color(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(view)
            m.top.equalTo(btnSocialWebchat).offset(50)
        }
        
        btnShareCollect.addTarget(self, action: #selector(shareCollect), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }

    @objc func originShare()  { //这个基本不能用啊
        let txtToShare = "这里要分享的内容"
        let img = UIImage(named: "6")
        let url = URL(string: "http://baidu.com")
        let items = [txtToShare,img!,url!] as [Any]
        let vcActivity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vcActivity, animated: true, completion: nil)
    }
    
    @objc func shareToSina()  {
        guard let vc = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo) else{
            print("没有安装新浪微博")
            return
        }
        //这里需要手机绑定该平强账号才行，所以基本不可行
        if !SLComposeViewController.isAvailable(forServiceType: SLServiceTypeSinaWeibo){
            print("软件没有配置登录信息")
            return
        }
        vc.setInitialText("这里要分享的内容")
        vc.add(UIImage(named: "6")!)
        vc.add(URL(string: "http://baidu.com")!)
        present(vc, animated: true, completion: nil)
        vc.completionHandler = {(result:SLComposeViewControllerResult) in
            if result == SLComposeViewControllerResult.cancelled{
                Toast.showToast(msg: "你点了取消")
            }
            else{
                Toast.showToast(msg: "你点了发送")
            }
        }
    }
    
    
    @objc func shareToWebchat()  {
        if !SLComposeViewController.isAvailable(forServiceType: Share_Weixin){
            print("软件没有配置登录微信信息")
            return
        }
        
        guard let vc = SLComposeViewController(forServiceType: Share_Weixin) else{
            return
        }
        //没有弹出分享出来就取消了
        vc.setInitialText("这里要分享的内容")
        vc.add(UIImage(named: "6")!)
        vc.add(URL(string: "http://baidu.com")!)
        present(vc, animated: true, completion: nil)
        vc.completionHandler = {(result:SLComposeViewControllerResult) in
            if result == SLComposeViewControllerResult.cancelled{
                Toast.showToast(msg: "你点了取消")
            }
            else{
                Toast.showToast(msg: "你点了发送")
            }
        }
        
    }
    
    @objc func shareCollect() {
        UIApplication.shared.keyWindow?.addSubview(ShareView.shareInstace)
       

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class ShareView: UIView {
    
    static let shareInstace = ShareView(frame: UIScreen.main.bounds)
    let vBg = UIView()
    let vContent = UIView()
    let btnShareToQQ = JXLayoutButton()
    let btnShareToWebchat = JXLayoutButton()
    let btnShareToFriends = JXLayoutButton()
    let btnCopyLing = JXLayoutButton()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        UIView.animate(withDuration: 0.5) {
            self.vContent.snp.updateConstraints { (m) in
                m.bottom.equalTo(0)
            }
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        vContent.bgColor(color: UIColor.white).addTo(view: self).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.height.equalTo(150)
            m.bottom.equalTo(-150)
        }
        
        vBg.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3)
        vBg.addTo(view: self).snp.makeConstraints { (m) in
            m.left.right.top.equalTo(0)
            m.bottom.equalTo(vContent.snp.top)
        }
        vBg.addTapGesture { [weak self](tap) in
            self?.removeFromSuperview()
            self?.vContent.snp.updateConstraints { (m) in
                m.bottom.equalTo(-150)
            }
        }
        
        btnShareToQQ.setImage(#imageLiteral(resourceName: "btn_recording_audio"), for: .normal)
        btnShareToQQ.layoutStyle = .upImageDownTitle
        btnShareToQQ.midSpacing = 10
        btnShareToQQ.imageSize = CGSize(width: 80, height: 80)
        btnShareToQQ.title(title: "分享到QQ").color(color: UIColor.gray).addTo(view: vContent).snp.makeConstraints { (m) in
            m.left.top.equalTo(0)
            m.width.equalTo(ScreenWidth / 4)
            m.height.equalTo(vContent)
        }
        
        btnShareToWebchat.setImage(#imageLiteral(resourceName: "btn_recording_audio"), for: .normal)
        btnShareToWebchat.layoutStyle = .upImageDownTitle
        btnShareToWebchat.midSpacing = 10
        btnShareToWebchat.imageSize = CGSize(width: 80, height: 80)
        btnShareToWebchat.title(title: "分享到QQ").color(color: UIColor.gray).addTo(view: vContent).snp.makeConstraints { (m) in
            m.top.equalTo(0)
            m.width.equalTo(ScreenWidth / 4)
            m.height.equalTo(vContent)
            m.left.equalTo(btnShareToQQ.snp.right)
        }
        
        btnShareToFriends.setImage(#imageLiteral(resourceName: "btn_recording_audio"), for: .normal)
        btnShareToFriends.layoutStyle = .upImageDownTitle
        btnShareToFriends.midSpacing = 10
        btnShareToFriends.imageSize = CGSize(width: 80, height: 80)
        btnShareToFriends.title(title: "分享到QQ").color(color: UIColor.gray).addTo(view: vContent).snp.makeConstraints { (m) in
            m.top.equalTo(0)
            m.width.equalTo(ScreenWidth / 4)
            m.height.equalTo(vContent)
            m.left.equalTo(btnShareToWebchat.snp.right)
        }
        
        btnCopyLing.setImage(#imageLiteral(resourceName: "btn_recording_audio"), for: .normal)
        btnCopyLing.layoutStyle = .upImageDownTitle
        btnCopyLing.midSpacing = 10
        btnCopyLing.imageSize = CGSize(width: 80, height: 80)
        btnCopyLing.title(title: "分享到QQ").color(color: UIColor.gray).addTo(view: vContent).snp.makeConstraints { (m) in
            m.top.equalTo(0)
            m.width.equalTo(ScreenWidth / 4)
            m.height.equalTo(vContent)
            m.left.equalTo(btnShareToFriends.snp.right)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
