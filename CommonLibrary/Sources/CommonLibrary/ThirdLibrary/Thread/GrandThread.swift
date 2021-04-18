//
//  File.swift
//  
//
//  Created by Stan Hu on 2021/4/18.
//

import Foundation
public class GrandThread : NSObject {
    private var thread:Thread!
    public var isStoped = false
    private var task:(()->Void)?
    override init() {
        super.init()
        thread = Thread(block: { [weak self] in
            RunLoop.current.add(Port(), forMode: .default)
            while self != nil && !self!.isStoped {
                RunLoop.current.run(mode: .default, before: Date.distantFuture)
            }
            self?.thread.start()
        })
    }
    
    public func stop(){
        if thread == nil {
            return
        }
        perform(#selector(stopThread), on: self.thread, with: nil, waitUntilDone: true)
    }
    
    public func executeTask(taskAction:@escaping (()->Void)){
        if thread == nil{
            return
        }
        self.task = taskAction
        perform(#selector(taskAction(taskAction:)), on: self.thread, with: nil, waitUntilDone: true)
    }
    
    @objc func taskAction(taskAction:()->Void)  {
        self.task?()
    }
        
    @objc func stopThread() {
        CFRunLoopStop(CFRunLoopGetCurrent())
        isStoped = true
        thread = nil
    }
    
    deinit {
        print("thread deinit \(#function)")
    }
}
