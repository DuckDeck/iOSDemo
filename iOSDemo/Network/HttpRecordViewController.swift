//
//  HttpRecordViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 14/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
import Alamofire
class HttpRecordViewController: UIViewController {

    let btn = UIButton()
    var requestInfo:RequestInfo?
    override func loadView() {
        self.view = TGLinearLayout(.vert)
        view.backgroundColor = UIColor.white
        
        (view as! TGLinearLayout).tg_padding = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        btn.tg_width.equal(100)
        btn.tg_height.equal(50)
        btn.setTitle("请示", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.addTarget(self, action: #selector(HttpRecordViewController.request(sender:)), for: .touchUpInside)
        view.addSubview(btn)

        //this library now work for Alamofire
        
//        if let record = SWHttpTrafficRecorder.shared(){
//            record.recordingFormat = .mocktail
//            record.progressDelegate = self
//            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
//            try! record.startRecording(atPath: paths[0], for: URLSessionConfiguration.default)
//            //try! record.startRecording(atPath: paths[0], for: Alamofire.URLSessionConfiguration)
//            //Alamofire.URLSessionConfiguration can not abtainf
//        }
        
        requestInfo = RequestInfo()
        requestInfo?.deviceInfo = UIDevice.current.name
        requestInfo?.osVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        //        requestInfo?.apiInfo = APIInfo()
        requestInfo?.requestTimeLine = RequestTimelineInfo()
        
        
    }
    
    @objc func request(sender:UIButton)  {
        HttpManager.get("https://api.bqbbq.com/api/index").completion { (data, err) in
            let _ = String(data: data!, encoding: String.Encoding.utf8)
            //print(str)
        }

 
        
    }

    
}

extension HttpRecordViewController:SWHttpTrafficRecordingProgressDelegate{
    func updateRecordingProgress(_ currentProgress: SWHTTPTrafficRecordingProgressKind, userInfo info: [AnyHashable : Any]! = [:]) {
        guard let request = info[SWHTTPTrafficRecordingProgressRequestKey] as? URLRequest, let _ = request.url?.absoluteString else {
            return
        }
         print("first\(Date())")

        if requestInfo!.apiInfo != nil {
            let apiInfo = APIInfo()
            apiInfo.author = "思聪"
            apiInfo.name = "获取首页"
            apiInfo.apiDescription = "获取首页,你懂的"
            apiInfo.url = request.url
            apiInfo.getParameters = apiInfo.getPara()
            apiInfo.httpMethod = HttpMethod.parse(method: request.httpMethod!)
            requestInfo?.apiInfo = apiInfo
        }
        if requestInfo!.requestDataInfo == nil {
            let postData = RequestDataInfo()
            if let length = request.httpBody?.count{
                postData.postDataSize = length
            }
            if (request as NSURLRequest).httpMethod!.lowercased() == "post" {
                if let type = request.value(forHTTPHeaderField: "Content-Type"){
                    postData.postDataMimeType = type
                }
            }
        }
        if let response = info[SWHTTPTrafficRecordingProgressResponseKey] as? URLResponse {
            print(response)
            print(Date())
        }
        
        if let responseData = info[SWHTTPTrafficRecordingProgressBodyDataKey] as? URLResponse {
            print(responseData)
            print(Date())
        }
        let progress =  ["Received","Skipped","Started","Loaded","Recorded", "FailedToLoad", "FailedToRecord"][currentProgress.rawValue-1]
        print(progress)
    }
}
