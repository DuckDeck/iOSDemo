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
        
        HttpClient.download(url: URL(string: "https://img1.gamersky.com/upimg/users/2021/04/10/origin_202104101719515372.jpg")!, toFile: URL(fileURLWithPath: NSTemporaryDirectory() + "1.jpg")) { (err) in
            print(err)
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
}


