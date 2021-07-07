//
//  config.swift
//  wanjia
//
//  Created by Stan Hu on 14/10/2016.
//  Copyright © 2016 Stan Hu. All rights reserved.
//



import UIKit
import GrandStore

enum ServerState:Int{
    case TestInNet = 0 //内部测试环境
    case DevelopInNet // 内部开发环境
    case TestOutNet  //外部测试环境
    case ProductOutNet  //正式环境
    
    static func convertToServerState(status:Int) -> String {
        switch status {
        case 0:
            return "内部开发环境"
        case 1:
            return "内部测试环境"
        case 2:
            return "外部测试环境"
        case 3:
            return "正式环境"
        default:
            return ""
        }
    }}

enum APPBuildStatus:Int{
    case Debug = 0
    case Release
}
enum DeviceEnum:Int {
    case Phone4S = 0,Phone5,Phone6,Phone6plus,PhoneX,PhoneXR,PhoneXSMax
}

let Device = ScreenHeight == 480 ? DeviceEnum.Phone4S : (ScreenHeight == 568 ? DeviceEnum.Phone5 : (ScreenHeight == 667 ? DeviceEnum.Phone6 : (ScreenHeight == 736 ? DeviceEnum.Phone6plus : DeviceEnum.PhoneX)))

let iPhoneXStatusBarHeight:CGFloat = 25
let NavigationBarHeight:CGFloat = 64.0 + (Device == DeviceEnum.PhoneX ? iPhoneXStatusBarHeight : 0)
let StatusBarHeight:CGFloat = 0.0 + (Device == DeviceEnum.PhoneX ? iPhoneXStatusBarHeight : 0)
let iPhoneBottomBarHeight:CGFloat = 0.0 + (Device == DeviceEnum.PhoneX ? 35 : 0)

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let TabBarHeight:CGFloat = 49.0
let SystemVersion:Double = Double(UIDevice.current.systemVersion)!
let APPVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let Scale = ScreenWidth / 320.0
let lineHeight:CGFloat = ScreenWidth == 414 ? 0.38334 : 0.5

let APPAreaInfo = GrandStore(name: "APPAreaInfo", defaultValue: AddressInfo())


/* \ */

protocol SelfAware:class {
    static func awake()
}

@objc class NothingToSeeHere: NSObject {

    private static let doOnce: Any? = {
        _harmlessFunction()
    }()

    static func harmlessFunction() {
        _ = NothingToSeeHere.doOnce
    }

    private static func _harmlessFunction() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount { (types[index] as? SelfAware.Type)?.awake() }
        free(types)
    }
}


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
            let log = "\(path.lastPathComponent!)[\(line)],\(method) \(message)"
            print(log)
        }
    #endif
}

func GLog<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
    if   let path = NSURL(string: file)
    {
        let log = "\(path.lastPathComponent!)[\(line)],\(method) \(message)"
        let s = LogTool.sharedInstance.addLog(log: log)
        print(s)
        print(log)
    }
}


infix operator =~
func =~(lhs:String,rhs:String) -> Bool{ //正则判断
    return regexTool(rhs).match(input: lhs)
}

let REGEX_FlOAT = "^([0-9]*.)?[0-9]+$"
let REGEX_MAIL = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
let REGEX_CELLPHONE = "^(0|86|17951)?1[0-9]{10}$"
let REGEX_IDENTITY_NUM = "^(\\d{6})(\\d{4})(\\d{2})(\\d{2})(\\d{3})([0-9]|X)$"
let REGEX_EMOJI = "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
let REGEX_URL = "^http://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"
//#define CELLPHONE_REGEX        @"^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|17[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\\d{8}$"
let REGEX_QQ = "^[1-9][0-9]{4,10}"
//#define EMAIL_REGEX            @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
let REGEX_TEL_PHONE = "^(([0\\+]\\d{2,3}-)?(0\\d{2,3})-)?(\\d{7,8})(-(\\d{3,}))?$"
//#define USERNAME_REGEX         @"^[A-Za-z]\\w{5,19}$"
//#define USERPWD_REGEX          @"^([a-zA-Z0-9]|[`~!@#$%^&*()+=|{}':;',\\[\\].<>]){5,21}$"



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
    let didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    if didAddMethod{
        class_replaceMethod(cls, swizzleSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    }
    else{
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
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











