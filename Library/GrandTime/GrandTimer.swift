//
//  GrandTimer.swift
//  GrandTimeDemo
//
//  Created by HuStan on 6/26/16.
//  Copyright © 2016 StanHu. All rights reserved.
//

import Foundation

open class GrandTimer: NSObject {

    struct timerFlags {
       static  var  timerIsInvalid:UInt32 = 0
    }
    
    var timeSpan:TimeSpan?
    weak var target:AnyObject?
    var selector:Selector?
    internal var userInfo:AnyObject?
    var repeats:Bool = false
    var privateSerialQueue:DispatchQueue?
    var timer:DispatchSource?
    var block:(()->Void)?
   fileprivate override init() {
        super.init()
    }
    
   public convenience init(timespan:TimeSpan,target:AnyObject,sel:Selector,userInfo:AnyObject?,repeats:Bool,dispatchQueue:DispatchQueue){
        self.init()
        self.timeSpan = timespan
        self.target = target
        self.selector = sel
        self.userInfo = userInfo
        self.repeats = repeats
//        let privateQueueName = "grandTime\(self)"
//        self.privateSerialQueue = DispatchQueue(label: privateQueueName, attributes: [])
//        self.privateSerialQueue?.setTarget(queue: dispatchQueue)
        self.privateSerialQueue = dispatchQueue
        self.timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: self.privateSerialQueue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as? DispatchSource
    }
    
    public convenience init(timespan:TimeSpan,block:@escaping ()->Void, repeats:Bool,dispatchQueue:DispatchQueue) {
         self.init()
        self.timeSpan = timespan
        self.block = block
        self.repeats = repeats
     //   let privateQueueName = "grandTime\(self)"
     //   self.privateSerialQueue = DispatchQueue(label: privateQueueName, attributes: DispatchQueue.Attributes.concurrent)
       // self.privateSerialQueue?.setTarget(queue: dispatchQueue)
        self.privateSerialQueue = dispatchQueue
        self.timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: self.privateSerialQueue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as? DispatchSource
    }
    
  open  static func scheduleTimerWithTimeSpan(_ timespan:TimeSpan,target:AnyObject,sel:Selector,userInfo:AnyObject?,repeats:Bool,dispatchQueue:DispatchQueue)->GrandTimer{
        let timer = GrandTimer(timespan: timespan, target: target, sel: sel, userInfo: userInfo, repeats: repeats, dispatchQueue: dispatchQueue)
        timer.schedule()
        return timer
    }
    
    open  static func scheduleTimerWithTimeSpan(_ timespan:TimeSpan,block:@escaping ()->Void,repeats:Bool,dispatchQueue:DispatchQueue)->GrandTimer{
        let timer = GrandTimer(timespan: timespan, block: block, repeats: repeats, dispatchQueue: dispatchQueue)
        timer.schedule()
        return timer
    }
    
  open  static func after(_ timeSpan:TimeSpan,block:@escaping ()->Void)->GrandTimer{
        let privateQueueName = "grandTimeAfter\(arc4random())"
        let dispatch = DispatchQueue(label: privateQueueName, attributes: DispatchQueue.Attributes.concurrent)
        let timer = GrandTimer.scheduleTimerWithTimeSpan(timeSpan, block: block, repeats: false, dispatchQueue: dispatch)

        
        return timer
    }
    
   open static func every(_ timeSpan:TimeSpan,block:@escaping ()->Void)->GrandTimer{
        let privateQueueName = "grandTimeEvery\(arc4random())"
        let dispatch = DispatchQueue(label: privateQueueName, attributes: DispatchQueue.Attributes.concurrent)
        let timer = GrandTimer.scheduleTimerWithTimeSpan(timeSpan, block: block, repeats: true, dispatchQueue: dispatch)
        return timer
    }
    
    // issue0 ,as for selector in a static func, the selector must be a static selector, so this is the problem, need to fix it
    // It looks like the anly way to fix it is to save the block in a dict..
    // select a key to store is a big issue, I can not find a desend key for this ,because the static func can not
    // bad this func can not call periodical. So think this is not gonna to work, I must find a another way to handle this.
    // So I must add a original func to init the timer
   // static func tick()  {
//        if let bok = block{
//            bok()
//        }
        
     //   print("11")
 //   }
    
  open  func schedule() {
        resetTimerProperties()
        weak var weakSelf = self
        self.timer!.setEventHandler { 
            weakSelf?.timerFired()
        }
        self.timer!.resume()
    }
    
    deinit{
        invalidate()
    }
    
  open  func fire() {
        timerFired()
    }
    
  open  func invalidate() {
        if !OSAtomicTestAndSetBarrier(7, &timerFlags.timerIsInvalid) {
            if  let timer = self.timer{
                self.privateSerialQueue!.async(execute: {
                    timer.cancel()
                })
            }
        }
    }
    
  open  func timerFired() {
        if OSAtomicAnd32OrigBarrier(1, &timerFlags.timerIsInvalid) < 0{
            return
        }
        if let blk = block{
            DispatchQueue.main.async(execute: { 
                  blk()
            })
          
        }
    
     let _ =    self.target?.perform(self.selector!, with: self)
        if !self.repeats {
            self.invalidate()
        }
    }
    
    var _tolerance:TimeSpan = TimeSpan()
   open var tolerance:TimeSpan?{
        set{
            objc_sync_enter(self)
            if newValue != nil && _tolerance != newValue{
                _tolerance = newValue!
            }
            resetTimerProperties()
            objc_sync_exit(self)

        }
        get{
//            objc_sync_enter(self)
            return _tolerance
//            objc_sync_exit(self)
        }
    }
    
    func resetTimerProperties()  {
       // let intervalInNanoseconds:Int64 = Int64(self.timeSpan!.ticks) * 1000000
        let intervalInNanoseconds = DispatchTimeInterval.milliseconds(self.timeSpan!.ticks)
        
     //   let toleranceInNanoseconds:DispatchTimeInterval = UInt64(self.tolerance!.ticks) * 1000000
      //  self.timer!.setTimer(start: DispatchTime.now() + Double(intervalInNanoseconds) / Double(NSEC_PER_SEC), interval: UInt64(intervalInNanoseconds), leeway: toleranceInNanoseconds)
       // self.timer!.scheduleRepeating(deadline: DispatchTime.now() + Double(intervalInNanoseconds) / Double(NSEC_PER_SEC), interval: intervalInNanoseconds)
        self.timer!.scheduleRepeating(deadline: DispatchTime.now() + intervalInNanoseconds, interval: intervalInNanoseconds)
    }
    
    override open var description: String{
        return "timeSpan = \(String(describing: timeSpan)) target = \(String(describing: target)) selector = \(String(describing: selector)) userinfo = \(String(describing: userInfo)) repeats = \(repeats) timer= \(String(describing: timer))"
    }
    
    
}



