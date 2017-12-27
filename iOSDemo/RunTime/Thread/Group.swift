//
//  Group.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class Group {
    static func testGCDGroup() {
        //并发队列
        let group = DispatchGroup()
        for _ in 0...10 {
            group.enter()
            Engine.instanse.doAsyncWorkWithCompleted({
                group.leave()
            })
        }
        _ = group.wait(timeout: DispatchTime.distantFuture)
        print("testGCDGroup完成")
    }
    
    static func testGCDGroup2(){
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let group = DispatchGroup()
        queue.async(group: group) {
            Thread.sleep(forTimeInterval: 1)
            print("Group1")
        }
        queue.async(group: group) {
            Thread.sleep(forTimeInterval: 2)
            print("Group2")
        }
        
        queue.async(group: group) {
            Thread.sleep(forTimeInterval: 3)
            print("Group3")
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("testGCDGroup2 完成")
        }
    }
}
