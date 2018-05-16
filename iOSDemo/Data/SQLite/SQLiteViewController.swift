//
//  SQLiteViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
class SQLiteViewController: UIViewController {

    let btnGetLog = UIButton()
    let btnUploadLog = UIButton()
    let btnClearLog = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        btnGetLog.title(title: "Log").bgColor(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(30)
            m.top.equalTo(70)
            m.width.equalTo(80)
            m.height.equalTo(40)
        }
        btnGetLog.addTarget(self, action: #selector(getLog), for: .touchUpInside)
        
        btnUploadLog.title(title: "Upload").bgColor(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(130)
            m.top.equalTo(btnGetLog)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        btnUploadLog.addTarget(self, action: #selector(uploadLog), for: .touchUpInside)
        
        btnClearLog.title(title: "Clear").bgColor(color: UIColor.red).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(250)
            m.top.equalTo(btnGetLog)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        btnClearLog.addTarget(self, action: #selector(clear), for: .touchUpInside)
        
    }

    @objc func getLog()  {
       let logs = LogTool.sharedInstance.getNotUploadLog()
       for l in logs{
            print(l.logText)
        }
    }
    
    @objc func uploadLog()  {
        let logs = LogTool.sharedInstance.getNotUploadLog()
        let lat = 113.23123
        let lon = 11.3123123
        let address = "深圳"
        let phone = 13122233
        let imei = "131231fsdf123"
        let IDFA = "123123123"
    
       
        let dict = ["phone":phone,"imei":imei,"idfa":IDFA,"latitude":lat,"longtitude":lon,"version":APPVersion,"log":logs.jsonValue,"address":address] as [String : Any]
        HttpClient.post("http://127.0.0.1:3000/api/easylog").addParams(dict).completion { (data, err) in
            if let s = String(data: data!, encoding: String.Encoding.utf8){
                print(s)
            }
            
        }
    }
    
    @objc func clear() {
       let result = LogTool.sharedInstance.deleteLog(time: DateTime.now.ticks / 1000)
        print(result)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
