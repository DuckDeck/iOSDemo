//
//  Auth.swift
//  Qfq
//
//  Created by Tyrant on 12/17/15.
//  Copyright © 2015 Qfq. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import CoreLocation
@objc enum AuthType:Int {
    case Camera = 0, Photo,Position,PushNotifcation,BackgroundAppRefresh,Video,Audio
}

class Auth:NSObject {
   @objc static  func showEventAccessDeniedAlert(view:UIViewController,authTpye:AuthType){
        var msg = ""
        switch authTpye{
            case .Camera: msg = "摄像头被禁用,请在设置里允许"
            case.Photo:msg = "相册被禁止访问,请在设置里允许"
            case.Position:msg = "定位功能被禁用,请在设置里允许"
            case.PushNotifcation :msg = "消息推送被禁用,请在设置里允许"
            case.BackgroundAppRefresh:msg = "后台刷新功能被禁用,请在设置里允许"
            case.Video:msg = "摄像头被禁用,请在设置里允许"
            case.Audio:msg = "麦克风被禁用,请在设置里允许"
        }
        let alertControllr = UIAlertController(title: "获取权限", message: msg, preferredStyle: .alert)
        let settingAction = UIAlertAction(title: "去设置", style: .default) { (alertAction) -> Void in
            if let appSettings = NSURL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
            }
        }
        alertControllr.addAction(settingAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertControllr.addAction(cancelAction)
        view.present(alertControllr, animated: true, completion: nil)
    
    }
    
    @objc static func isAuthPhoto()->Bool{
        if #available(iOS 9.0, *) {
            let library:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            return  library != PHAuthorizationStatus.denied && library != PHAuthorizationStatus.restricted
        }else{
            let authStatus = ALAssetsLibrary.authorizationStatus()
            return authStatus != .restricted && authStatus != .denied
        }
    }
    
    @objc static func isAuthLocation()->Bool{
        if CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == .notDetermined ||
                CLLocationManager.authorizationStatus() == .authorizedAlways)
        {
            return true
            
        }
        return false
    }
    
    @objc static func isAuthCamera() -> AVAuthorizationStatus{
        return AVCaptureDevice.authorizationStatus(for: .video) 
    }
    
    @objc static func authCamera(grandBLock:@escaping ((_ isGrant:Bool)->Void)){
     
        let res = AVCaptureDevice.authorizationStatus(for: .video)
        switch res {
            case .authorized:
                grandBLock(true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                   
                    grandBLock(granted)
                })
            
            default:
              
                grandBLock(false)
        }
        
    }
    
    @objc static func isAuthMicrophone()->AVAuthorizationStatus{
        return AVCaptureDevice.authorizationStatus(for: .audio)
    }
    
    @objc static func authMicrophone(grandBLock:@escaping ((_ isGrant:Bool)->Void)){
        let res = AVCaptureDevice.authorizationStatus(for: .audio)
        switch res {
        case .authorized:
            grandBLock(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted) in
                grandBLock(granted)
            })
            
        default:
           
            grandBLock(false)
        }
    }
}
