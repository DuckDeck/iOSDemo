//
//  Apply.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
//是同步函数,会阻塞当前线程直到所有循环迭代执行完成。当提交到并发queue时,循环迭代的执行顺序是不确定的
class Apply {

    static var i = 0
    static func TestGCDApply(){
        
        DispatchQueue.concurrentPerform(iterations: 10) { (index) in
            printTest()
        }
    }
    
    static  func printTest(){
        
    }
}
