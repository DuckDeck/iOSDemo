//
//  HintView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import WebKit
class HintView: UIView {
    
    var touchAction:((_ view:UIView)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(gray: 0.5, alpha: 0.3)
        self.addTapGesture { [weak self](ges) in
            self?.touchAction?(ges.view!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HintInfoView: UIView {
    let vContent = UIView()
    let lblTitle = UILabel()
    let btnClose = UIButton()
    //    let info = [(1,"失联修复是一项为了更好找到失联债务人而研发的工具;"),
    //                (2,"可以根据你的需要对债务人进行修复方案的选择，不同的修复服务收取不同的积分，积分目前由平台赠送，往后需要充值;"),
    //                (3,"出库时间小于5天不可修复，修复周期一般2〜3天，修复成功后会有短信通知，并在客户本人信息中展示请及时进行催收。"),
    //                (4,"失联修复成功的信息成功率不能保证100%有交，请斟酌后使用。")]
    var infos:[(Int,String)]?{
        didSet{
            if let info = infos{
                var lblPrevious:UILabel!
                for i in 0..<info.count{
                    let lbl1 = UILabel().text(text: "\(info[i].0.toString)、").color(color: UIColor(hexString: "333333")!).setFont(font: 15).addTo(view: vContent)
                    lbl1.snp.makeConstraints { (m) in
                        m.left.equalTo(20)
                        if lblPrevious == nil{
                            m.top.equalTo(55)
                        }
                        else{
                            m.top.equalTo(lblPrevious.snp.bottom).offset(15)
                        }
                        m.width.equalTo(25)
                    }
                    let lbl2 = UILabel().text(text: info[i].1).color(color: UIColor(hexString: "333333")!).setFont(font: 15).addTo(view: vContent)
                    lbl2.numberOfLines = 0
                    lblPrevious = lbl2
                    lbl2.snp.makeConstraints { (m) in
                        m.left.equalTo(lbl1.snp.right).offset(2)
                        m.top.equalTo(lbl1)
                        m.right.equalTo(-20)
                        if i == info.count - 1{
                            m.bottom.equalTo(-30)
                        }
                    }
                    
                    
                }
            }
        }
    }
    var title:String?{
        didSet{
            if let t = title{
                lblTitle.text = t
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        vContent.clipsToBounds = true
        vContent.layer.cornerRadius = 10
        vContent.addTo(view: self).bgColor(color: UIColor.white).snp.makeConstraints { (m) in
            m.top.left.right.equalTo(0)
        }
        
        lblTitle.text(text: "失联修复服务说明").setFont(font: 15).color(color: UIColor(hexString: "999999")!).addTo(view: vContent).snp.makeConstraints { (m) in
            m.centerX.equalTo(vContent)
            m.top.equalTo(20)
        }
        
        btnClose.setImage(#imageLiteral(resourceName: "btn_home_close"), for: .normal)
        btnClose.addTo(view: self).snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(vContent.snp.bottom)
            m.bottom.equalTo(0)
            m.height.equalTo(60)
        }
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        
    }
    
    @objc func close() {
        if let v = self.superview as? HintView{
            v.touchAction?(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class HintNoticeView: UIView,WKNavigationDelegate {
    
    let imgCheck = UIImageView()
    let lblCheck = UILabel()
    let vContent = UIScrollView()
    let lblTitle = UILabel()
    let btnClose = UIButton()
    var isCheck = false
    var webContent:WKWebView!
    var title:String?{
        didSet{
            if let t = title{
                lblTitle.text = t
            }
        }
    }
    
    var content:String?{
        didSet{
            guard let c = content else {
                return
            }
            let head = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
            let html = "<html style='font-size:14.5px,color:#333333'>\(head)\(c)</html>"
            
            webContent.loadHTMLString(html, baseURL: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        self.layer.cornerRadius = 10
        lblTitle.text(text: "失联修复服务说明").setFont(font: 15).color(color: UIColor(hexString: "999999")!).addTo(view: self).snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(20)
        }
        
        
        vContent.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        vContent.addTo(view: self).bgColor(color: UIColor.white).snp.makeConstraints { (m) in
            m.top.equalTo(lblTitle.snp.bottom).offset(0)
            m.left.right.equalTo(0)
            m.height.equalTo(290)
        }
        
        
        webContent = WKWebView()
        webContent.navigationDelegate = self
        webContent.scrollView.isScrollEnabled = false
        webContent.addTo(view: vContent).snp.makeConstraints { (m) in
            m.left.equalTo(12)
            m.width.equalTo(ScreenWidth - 124)
            m.top.equalTo(0)
            m.height.equalTo(240)
        }
        
        imgCheck.image = #imageLiteral(resourceName: "icon_unchecked_gray")
        imgCheck.addTapGesture { [weak self](ges) in
            self?.check()
        }
        imgCheck.addTo(view: vContent).snp.makeConstraints { (m) in
            m.left.equalTo(12)
            m.bottom.equalTo(-5)
            m.width.height.equalTo(18)
            m.top.equalTo(webContent.snp.bottom).offset(15)
        }
        
        lblCheck.text(text: "我已阅读完毕").color(color: UIColor.blue).setFont(font: 15).addTo(view: vContent).snp.makeConstraints { (m) in
            m.left.equalTo(imgCheck.snp.right).offset(10)
            m.centerY.equalTo(imgCheck)
        }
        lblCheck.addTapGesture {[weak self] (ges) in
            self?.check()
        }
        
        btnClose.title(title: "确定").bgColor(color: UIColor.darkGray).color(color: UIColor.white).cornerRadius(radius: 17.5).addTo(view: self).snp.makeConstraints { (m) in
            m.bottom.equalTo(-20)
            m.top.equalTo(vContent.snp.bottom).offset(20)
            m.centerX.equalTo(self)
            m.height.equalTo(35)
            m.width.equalTo(200)
        }
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        let vTopMask = UIView().addTo(view: self)
        vTopMask.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(lblTitle.snp.bottom).offset(0)
            m.height.equalTo(40)
        }
        
        let ly = CAGradientLayer()
        ly.startPoint = CGPoint(x: 0.5, y: 0)
        ly.endPoint = CGPoint(x: 0.5, y: 1)
        ly.colors = [UIColor.white.cgColor,UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor]
        ly.frame = CGRect(x: 0, y: 0, w: ScreenWidth - 100, h: 40)
        vTopMask.layer.insertSublayer(ly, at: 0)
        
        
        let vBottomMask = UIView().addTo(view: self)
        vBottomMask.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.bottom.equalTo(btnClose.snp.top).offset(-10)
            m.height.equalTo(30)
        }
        
        let ly2 = CAGradientLayer()
        ly2.startPoint = CGPoint(x: 0.5, y: 0)
        ly2.endPoint = CGPoint(x: 0.5, y: 1)
        ly2.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor,UIColor.white.cgColor]
        ly2.frame = CGRect(x: 0, y: 0, w: ScreenWidth - 100, h: 30)
        vBottomMask.layer.insertSublayer(ly2, at: 0)
        
    }
    
    func check()  {
        isCheck = !isCheck
        btnClose.backgroundColor = isCheck ? UIColor.blue : UIColor.darkGray
        imgCheck.image = isCheck ? #imageLiteral(resourceName: "icon_checked_blue") : #imageLiteral(resourceName: "icon_unchecked_gray")
    }
    
    @objc func close() {
        if !isCheck{
            Toast.showToast(msg: "未勾选我已阅读完毕")
            return
        }
        if let v = self.superview as? HintView{
            v.touchAction?(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.sizeToFit()
        webView.evaluateJavaScript("document.body.offsetHeight") { (data, err) in
            guard let d = data as? Float else{
                return
            }
            self.webContent.snp.updateConstraints { (m) in
                m.height.equalTo(d)
            }
        }
    }
}



