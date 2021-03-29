//
//  iOSProjectApp.swift
//  iOSProject
//
//  Created by shadowedge on 2021/1/4.
//

import SwiftUI
import IQKeyboardManagerSwift
import CommonLibrary
@main
struct iOSProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //这里可以使用appDelegate
    @Environment(\.scenePhase) var scenePhase                       //这里可以使用scene周期
    
    init() {
        print("you application is starting up. App initialiser and can init something here ")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                print("here handle deeplink\(url)")
            })
        }.onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase{
            case .active:
                print("iOSProjectApp is active")
            case .inactive:
                print("iOSProjectApp is inactive")
            case .background:
                print("iOSProjectApp is background")
            
            @unknown default:
                print("Oh - interesting: in app cycle I received an unexpected new value.")
            }
        }
    }
    
}
//添加appdelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQKeyboardManager.shared.enable = true
        
        let r = "13329-22=13307×66".range(of: "13307x66")
        print(r)
        
        if let item =  "434g+0.54.5*1.3.4+9.0.2-9.2+123.77".numOperatePart(){
           let res = calculatorResult(numOperas: item)
            print(res?.0)
            print(res?.1)
        }
        return true
    }
    //如果有些库还是用appDelegate来处理的话还是可以在这里处理生命周期, 下面方法不用调用
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("iOSProjectApp is applicationDidBecomeActive")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("iOSProjectApp is applicationWillResignActive")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("iOSProjectApp is applicationDidEnterBackground")
    }
    
    func calculatorResult(numOperas:([Double],[NumOperate])?) -> (String,String)? {
        if let nums = numOperas{
            var tmp:Decimal = 0.0
            var operaString = ""
            for item in nums.1.enumerated() {
                if item.offset == 0{
                    tmp = Decimal(nums.0[0])
                }
                switch item.element {
                case .Add:
                    tmp = tmp + Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "+"
                case .Minus:
                    tmp = tmp - Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "-"
                case .Multiply:
                    tmp = tmp * Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "x"
                case .Devided:
                    tmp = tmp / Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "/"
                }
                if item.offset == nums.1.count - 1 {
                    operaString += String(nums.0[item.offset + 1])
                }
            }
            return ("\(tmp)",operaString + "=\(tmp)")
        }
        return nil
    }
}
