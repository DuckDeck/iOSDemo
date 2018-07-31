//
//  Semaphore.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class Semaphore {
    //比如现在我每次想执行10个任务。休息两秒。继续执行10个任务。可以这么写.
    static func testSemaphore()  {
        let group = DispatchGroup()
        let semapthore = DispatchSemaphore(value: 10)//信号总量是10
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        var i = 0
        while i < 100 {
            _ = semapthore.wait(timeout: DispatchTime.distantFuture) //信号量-1
            queue.async(group: group, execute: {
                print(i)
                sleep(2)
                semapthore.signal()
            })
            i = i + 1
        }
        _ = group.wait(timeout: DispatchTime.distantFuture)
    }
    

    //:异步队列中做事，等待回调后执行某件事
    static func testAsyncFinished()  {
        var ok = false
        let sema = DispatchSemaphore(value: 0)
        let eng = Engine()
        eng.queryCompletion({ (isOpen) in
            ok = isOpen
            sema.signal()
            print("Success")
        }) { (isOpen, errorCode) in
            ok = isOpen
            sema.signal()
            print("Fail")
        }
        print("Finish")
        print("Result:\(ok)")
        _ = sema.wait(timeout: DispatchTime.distantFuture)
    }
    
    //生产者，消费者
    static  func testProductionAndConsumer()  {
        let sem = DispatchSemaphore(value: 0)
        let producerQuene = DispatchQueue(label: "producer", attributes: DispatchQueue.Attributes.concurrent) //生产者线程跑的队列
        let consumerQueue = DispatchQueue(label: "consumer", attributes: DispatchQueue.Attributes.concurrent)//消费者线程跑的队列
        var cakeNumber = 0
        producerQuene.async {
            while true{
                let res = sem.signal()
                if res > 0{
                    cakeNumber += 1
                    print("Product: 后产出了第\(cakeNumber)个蛋糕")
                    sleep(1)
                    continue
                }
            }
        }
        consumerQueue.async {
            while true{
                let res = sem.wait(timeout: DispatchTime.now() + Double(0 * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC))
                if res  == .success{
                    if cakeNumber > 0{
                        cakeNumber -= 1
                        print("Consumer:拿到了第个\(cakeNumber)蛋糕")
                    }
                    continue
                }
            }
        }
    }
    
}



class Engine {
    func queryCompletion(_ success:(_ isOpen:Bool)->Void,fail:(_ isOpen:Bool,_ errorCode:Int)->Void)  {
        let flag = arc4random() % 10 < 5
        sleep(5)
        if flag {
            success(true)
        }
        else{
            fail(false, 12)
        }
        //这个地方不知道怎么搞
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        //            sleep(5)
        //            dispatch_sync(dispatch_get_main_queue(), {
        //                if flag {
        //                    success(isOpen: true)
        //                }
        //                else{
        //                    fail(isOpen: false, errorCode: 12)
        //                }
        //            })
        //        }
    }
    
    func doAsyncWorkWithCompleted(_ completed:()->Void) {
        sleep(2)
        print("完成一个")
        completed()
    }
    
    static var instanse = Engine()
    
    
}

