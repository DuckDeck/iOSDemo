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
    var isNeedCount = false
    
    fileprivate override init() {
        super.init()
    }
    
   private convenience init(timespan:TimeSpan,target:AnyObject,sel:Selector,userInfo:AnyObject?,repeats:Bool,dispatchQueue:DispatchQueue){
        self.init()
        self.timeSpan = timespan
        self.target = target
        self.selector = sel
        self.userInfo = userInfo
        self.repeats = repeats
        self.privateSerialQueue = dispatchQueue
        self.timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: self.privateSerialQueue) as? DispatchSource
    }
    
   private convenience init(timespan:TimeSpan,block:@escaping ()->Void, repeats:Bool,dispatchQueue:DispatchQueue) {
         self.init()
        self.timeSpan = timespan
        self.block = block
        self.repeats = repeats
        self.privateSerialQueue = dispatchQueue
        self.timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: self.privateSerialQueue)  as? DispatchSource
    }
    
   public static func scheduleTimerWithTimeSpan(_ timespan:TimeSpan,target:AnyObject,sel:Selector,userInfo:AnyObject?,repeats:Bool,dispatchQueue:DispatchQueue)->GrandTimer{
        let timer = GrandTimer(timespan: timespan, target: target, sel: sel, userInfo: userInfo, repeats: repeats, dispatchQueue: dispatchQueue)
        timer.schedule()
        return timer
    }
    
   public  static func scheduleTimerWithTimeSpan(_ timespan:TimeSpan,block:@escaping ()->Void,repeats:Bool,dispatchQueue:DispatchQueue)->GrandTimer{
        let timer = GrandTimer(timespan: timespan, block: block, repeats: repeats, dispatchQueue: dispatchQueue)
        timer.schedule()
        return timer
    }
    
  public  static func after(_ timeSpan:TimeSpan,block:@escaping ()->Void)->GrandTimer{
        let privateQueueName = "grandTimeAfter\(arc4random())"
        let dispatch = DispatchQueue(label: privateQueueName, attributes: DispatchQueue.Attributes.concurrent)
        let timer = GrandTimer.scheduleTimerWithTimeSpan(timeSpan, block: block, repeats: false, dispatchQueue: dispatch)
        return timer
    }
    
   public static func every(_ timeSpan:TimeSpan,block:@escaping ()->Void)->GrandTimer{
        let privateQueueName = "grandTimeEvery\(arc4random())"
        let dispatch = DispatchQueue(label: privateQueueName, attributes: DispatchQueue.Attributes.concurrent)
        let timer = GrandTimer.scheduleTimerWithTimeSpan(timeSpan, block: block, repeats: true, dispatchQueue: dispatch)
        return timer
    }
    
  open  func schedule() {
        resetTimerProperties()
        weak var weakSelf = self
        self.timer!.setEventHandler { 
            weakSelf?.timerFired()
        }
        timer?.resume()
    }
    
    deinit{
        invalidate()
    }
    
    open func fire() {
        isNeedCount = true
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
    
    open func pause() {
        isNeedCount = false
    }

    
   open func timerFired() {
        if !isNeedCount{
            return
        }
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
            objc_sync_enter(self)
            let t =  _tolerance
            objc_sync_exit(self)
            return t
        }
    }
    
    func resetTimerProperties()  {
        let intervalInNanoseconds = DispatchTimeInterval.milliseconds(self.timeSpan!.ticks)
        self.timer!.schedule(deadline: DispatchTime.now() + intervalInNanoseconds, repeating: intervalInNanoseconds)
    }
    
    override open var description: String{
        return "timeSpan = \(String(describing: timeSpan)) target = \(String(describing: target)) selector = \(String(describing: selector)) userinfo = \(String(describing: userInfo)) repeats = \(repeats) timer= \(String(describing: timer))"
    }
    
    
}



