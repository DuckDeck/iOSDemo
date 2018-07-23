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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}
