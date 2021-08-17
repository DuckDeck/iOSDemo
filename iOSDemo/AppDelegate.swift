//
//  AppDelegate.swift
//  iOSDemo
//
//  Created by Stan Hu on 13/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import os
import ViewChaos
import WebKit
//import netfox
//import KTVHTTPCache
@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        
        
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = ViewController()
        let rootNavigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = rootNavigationController
        window?.makeKeyAndVisible()
//        NFX.sharedInstance().start()
        IQKeyboardManager.shared.enable = true
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        let fps = FPSLable(frame: CGRect(x: ScreenWidth / 2 - 50, y: 50, width: 100, height: 20))
        UIApplication.shared.keyWindow?.addSubview(fps)
        let monitor = CatonMonitor.init()
        monitor.start()
        
        ViewChaosStart.awake()
        hookMethod()
        
        
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: "com.shadow.edge", category: "loggggg")
            logger.log("testesetet")
        } else {
            
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func hookMethod() {
        hookClassMethod(cls: WKWebView.self, originalSelector: #selector(WKWebView.handlesURLScheme(_:)), swizzleSelector: #selector(WKWebView.gghandlesURLScheme(_:)))
        hookInstanceMethod(cls: WKWebView.self, originalSelector: #selector(WKWebView.load(_:)), swizzleSelector: #selector(WKWebView.ggLoad(_:)))
    }

}
