//
//  config.swift
//  wanjia
//
//  Created by Stan Hu on 14/10/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//



import UIKit

let NavigationBarHeight:CGFloat = 64.0
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let TabBarHeight:CGFloat = 49.0
let SystemVersion:Double = Double(UIDevice.current.systemVersion)!
let APPVersion: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
let Scale = ScreenWidth / 320.0
let lineHeight:CGFloat = ScreenWidth == 414 ? 0.38334 : 0.5


var fontsize = 20


/* \ */



enum DeviceEnum:Int {
    case Phone4S = 0,Phone5,Phone6,Phone6plus
}


let Device = ScreenHeight == 480 ? DeviceEnum.Phone4S : (ScreenHeight == 568 ? DeviceEnum.Phone5 : (ScreenHeight == 667 ? DeviceEnum.Phone6 : DeviceEnum.Phone6plus))



func createInstanseFromString(className:String)->NSObject!{
    let classType: AnyClass! = NSClassFromString(className)
    let objType = classType as? NSObject.Type
    assert(objType != nil, "class not found,please check className")
    return objType!.init()
}


typealias Task = (_ cancel:Bool)->()
func delay(time:TimeInterval,task:@escaping ()->())->Task?{
    func dispatch_later( block: @escaping ()->Void){
        let delayTime = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: block)
    }
    var closure:(()->Void)? = task
    var result:Task?
    let delayClosure:Task = {
        cancel in
        if let internalClosure = closure{
            if cancel == false{
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    result = delayClosure
    dispatch_later {
        if let delayClosure = result{
            delayClosure(false)
        }
    }
    return result
}

func cancel(task:Task?){
    task?(true)
}




func Log<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
    #if DEBUG
        if   let path = NSURL(string: file)
        {
            print("\(path.lastPathComponent!)[\(line)],\(method) \(message)")
        }
    #endif
}




infix operator =~
func =~(lhs:String,rhs:String) -> Bool{ //正则判断
    return regexTool(rhs).match(input: lhs)
}

let REGEX_FlOAT = "^([0-9]*.)?[0-9]+$"
let REGEX_MAIL = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
let REGEX_CELLPHONE = "^(13|14|15|17|18)\\d{9}$"
let REGEX_IDENTITY_NUM = "^(\\d{6})(\\d{4})(\\d{2})(\\d{2})(\\d{3})([0-9]|X)$"


func +(lhs: Int,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:Int)->Double{
    return lhs + Double(rhs)
}

func +(lhs: Int,rhs:Float)->Float{
    return Float(lhs) + rhs
}

func +(lhs: Float,rhs:Int)->Float{
    return lhs + Float(rhs)
}

func +(lhs: Float,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:Float)->Double{
    return lhs + Double(rhs)
}


func +(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) + rhs
}

func +(lhs: Double,rhs:UInt)->Double{
    return lhs + Double(rhs)
}

func +(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) + rhs
}

func +(lhs: Float,rhs:UInt)->Float{
    return lhs + Float(rhs)
}




func -(lhs: Int,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:Int)->Double{
    return lhs - Double(rhs)
}

func -(lhs: Int,rhs:Float)->Float{
    return Float(lhs) - rhs
}

func -(lhs: Float,rhs:Int)->Float{
    return lhs - Float(rhs)
}

func -(lhs: Float,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:Float)->Double{
    return lhs - Double(rhs)
}


func -(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) - rhs
}

func -(lhs: Double,rhs:UInt)->Double{
    return lhs - Double(rhs)
}

func -(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) - rhs
}

func -(lhs: Float,rhs:UInt)->Float{
    return lhs - Float(rhs)
}



func *(lhs: Int,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:Int)->Double{
    return lhs * Double(rhs)
}

func *(lhs: Int,rhs:Float)->Float{
    return Float(lhs) * rhs
}

func *(lhs: Float,rhs:Int)->Float{
    return lhs * Float(rhs)
}

func *(lhs: Int,rhs:CGFloat)->CGFloat{
    return CGFloat(lhs) * rhs
}

func *(lhs: CGFloat,rhs:Int)->CGFloat{
    return lhs * CGFloat(rhs)
}

func *(lhs: Float,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:Float)->Double{
    return lhs * Double(rhs)
}


func *(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) * rhs
}

func *(lhs: Double,rhs:UInt)->Double{
    return lhs * Double(rhs)
}

func *(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) * rhs
}

func *(lhs: Float,rhs:UInt)->Float{
    return lhs * Float(rhs)
}


func /(lhs: Int,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:Int)->Double{
    return lhs / Double(rhs)
}

func /(lhs: Int,rhs:Float)->Float{
    return Float(lhs) / rhs
}

func /(lhs: Float,rhs:Int)->Float{
    return lhs / Float(rhs)
}

func /(lhs: Float,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:Float)->Double{
    return lhs / Double(rhs)
}


func /(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) / rhs
}

func /(lhs: Double,rhs:UInt)->Double{
    return lhs / Double(rhs)
}

func /(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) / rhs
}

func /(lhs: Float,rhs:UInt)->Float{
    return lhs / Float(rhs)
}




//Swizzle

func hookMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
    let originalMethod = class_getInstanceMethod(cls, originalSelector)
    let swizzledMethod = class_getInstanceMethod(cls, swizzleSelector)
    let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    if didAddMethod{
        class_replaceMethod(cls, swizzleSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    }
    else{
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}



 func invoke(viewController:String,selector:String) {
    if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
        for v in nav.viewControllers {
            if let cla = NSClassFromString(viewController) {
                if v.isKind(of: cla) {
                    v.perform(NSSelectorFromString(selector))
                }
            }
        }
    }
}

 func invoke(viewController:String,selector:String,paras:AnyObject) {
    if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
        for v in nav.viewControllers {
            if let cla = NSClassFromString(viewController) {
                if v.isKind(of:cla) {
                    
                    v.performSelector(inBackground: NSSelectorFromString(selector), with: paras)
                }
            }
        }
    }
}

struct regexTool {
    let regex:NSRegularExpression?
    init(_ pattern:String){
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    func match(input:String)->Bool{
        if let matches = regex?.matches(in: input, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }
        else{
            return false
        }
    }
}













