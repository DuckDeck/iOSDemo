//
//  Fundation.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 2019/7/1.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import Foundation


class ThreadTest {
    static func ThreadName1()  {
        let key = DispatchSpecificKey<Any>()
        DispatchQueue.main.setSpecific(key: key, value: "main")
        //将main queue 设置一个key和value
        func log(){
            print("main thread: \(Thread.isMainThread)")
            let value = DispatchQueue.getSpecific(key: key)
            print(value ?? "nil")
            print("main queue: \(value != nil)")
            //打印nil  main thread 并不是在main queue里面
        }
        
        DispatchQueue.global().sync {
            log()
        }
        RunLoop.current.run()
        print(123123)
    }
    static func ThreadName2()  {
        let key = DispatchSpecificKey<Any>()
        DispatchQueue.main.setSpecific(key: key, value: "main")
        //将main queue 设置一个key和value
        func log(){
            print("main thread: \(Thread.isMainThread)")
            let value = DispatchQueue.getSpecific(key: key)
            print(value ?? "nil")
            print("main queue: \(value != nil)")
//            main thread: true
//            main
//            main queue: true
            //这次全在主线程运行
        }
        
        DispatchQueue.global().sync {
            DispatchQueue.main.async {
                log()
            }
        }
        dispatchMain()
        //加上dispatchMain main thread: false 就变成false了 后面代码也不会执行了
        print(123123)
    }
}

extension DispatchQueue {
    private static var token: DispatchSpecificKey<()> = {
        let key = DispatchSpecificKey<()>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()
    
    static var isMain: Bool {
        return DispatchQueue.getSpecific(key: token) != nil
    }
}
