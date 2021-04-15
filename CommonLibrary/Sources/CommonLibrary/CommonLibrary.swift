import UIKit

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height
public let TabBarHeight:CGFloat = 49.0
public let SystemVersion:Double = Double(UIDevice.current.systemVersion)!
public let APPVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
public let Scale = ScreenWidth / 320.0
public let lineHeight:CGFloat = ScreenWidth == 414 ? 0.38334 : 0.5
public let NotchHeight:CGFloat = 25
public let NavigationBarHeight:CGFloat = 64.0 + (Device.isNotchScreen ? NotchHeight : 0)

public func createInstanseFromString(className:String)->NSObject!{
    let classType: AnyClass! = NSClassFromString(className)
    let objType = classType as? NSObject.Type
    assert(objType != nil, "class not found,please check className")
    return objType!.init()
}


public typealias Task = (_ cancel:Bool)->()
public func delay(time:TimeInterval,task:@escaping ()->())->Task?{
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
public func cancel(task:Task?){
    task?(true)
}


public func Log<T>(message:T,file:String = #file, method:String = #function,line:Int = #line){
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
//        let s = LogTool.sharedInstance.addLog(log: log)
        print(log)
    }
}

public struct regexTool {
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



infix operator =~
public func =~(lhs:String,rhs:String) -> Bool{ //正则判断
    return regexTool(rhs).match(input: lhs)
}

public let REGEX_FlOAT = "^([0-9]*.)?[0-9]+$"
public let REGEX_MAIL = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
public let REGEX_CELLPHONE = "^(0|86|17951)?1[0-9]{10}$"
public let REGEX_IDENTITY_NUM = "^(\\d{6})(\\d{4})(\\d{2})(\\d{2})(\\d{3})([0-9]|X)$"
public let REGEX_EMOJI = "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
public let REGEX_URL = "^http://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"
//#define CELLPHONE_REGEX        @"^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|17[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\\d{8}$"
public let REGEX_QQ = "^[1-9][0-9]{4,10}"
//#define EMAIL_REGEX            @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"
public let REGEX_TEL_PHONE = "^(([0\\+]\\d{2,3}-)?(0\\d{2,3})-)?(\\d{7,8})(-(\\d{3,}))?$"
//#define USERNAME_REGEX         @"^[A-Za-z]\\w{5,19}$"
//#define USERPWD_REGEX          @"^([a-zA-Z0-9]|[`~!@#$%^&*()+=|{}':;',\\[\\].<>]){5,21}$"

public func +(lhs: Int,rhs:Double)->Double{
    return Double(lhs) + rhs
}

public func +(lhs: Double,rhs:Int)->Double{
    return lhs + Double(rhs)
}

public func +(lhs: Int,rhs:Float)->Float{
    return Float(lhs) + rhs
}

public func +(lhs: Float,rhs:Int)->Float{
    return lhs + Float(rhs)
}

public func +(lhs: Float,rhs:Double)->Double{
    return Double(lhs) + rhs
}

public func +(lhs: Double,rhs:Float)->Double{
    return lhs + Double(rhs)
}


public func +(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) + rhs
}

public func +(lhs: Double,rhs:UInt)->Double{
    return lhs + Double(rhs)
}

public func +(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) + rhs
}

public func +(lhs: Float,rhs:UInt)->Float{
    return lhs + Float(rhs)
}




public func -(lhs: Int,rhs:Double)->Double{
    return Double(lhs) - rhs
}

public func -(lhs: Double,rhs:Int)->Double{
    return lhs - Double(rhs)
}

public func -(lhs: Int,rhs:Float)->Float{
    return Float(lhs) - rhs
}

public func -(lhs: Float,rhs:Int)->Float{
    return lhs - Float(rhs)
}

public func -(lhs: Float,rhs:Double)->Double{
    return Double(lhs) - rhs
}

public func -(lhs: Double,rhs:Float)->Double{
    return lhs - Double(rhs)
}


public func -(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) - rhs
}

public func -(lhs: Double,rhs:UInt)->Double{
    return lhs - Double(rhs)
}

public func -(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) - rhs
}

public func -(lhs: Float,rhs:UInt)->Float{
    return lhs - Float(rhs)
}



public func *(lhs: Int,rhs:Double)->Double{
    return Double(lhs) * rhs
}

public func *(lhs: Double,rhs:Int)->Double{
    return lhs * Double(rhs)
}

public func *(lhs: Int,rhs:Float)->Float{
    return Float(lhs) * rhs
}

public func *(lhs: Float,rhs:Int)->Float{
    return lhs * Float(rhs)
}

public func *(lhs: Int,rhs:CGFloat)->CGFloat{
    return CGFloat(lhs) * rhs
}

public func *(lhs: CGFloat,rhs:Int)->CGFloat{
    return lhs * CGFloat(rhs)
}

public func *(lhs: Float,rhs:Double)->Double{
    return Double(lhs) * rhs
}

public func *(lhs: Double,rhs:Float)->Double{
    return lhs * Double(rhs)
}


public func *(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) * rhs
}

public func *(lhs: Double,rhs:UInt)->Double{
    return lhs * Double(rhs)
}

public func *(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) * rhs
}

public func *(lhs: Float,rhs:UInt)->Float{
    return lhs * Float(rhs)
}


public func /(lhs: Int,rhs:Double)->Double{
    return Double(lhs) / rhs
}

public func /(lhs: Double,rhs:Int)->Double{
    return lhs / Double(rhs)
}

public func /(lhs: Int,rhs:Float)->Float{
    return Float(lhs) / rhs
}

public func /(lhs: Float,rhs:Int)->Float{
    return lhs / Float(rhs)
}

public func /(lhs: Float,rhs:Double)->Double{
    return Double(lhs) / rhs
}

public func /(lhs: Double,rhs:Float)->Double{
    return lhs / Double(rhs)
}


public func /(lhs: UInt,rhs:Double)->Double{
    return Double(lhs) / rhs
}

public func /(lhs: Double,rhs:UInt)->Double{
    return lhs / Double(rhs)
}

public func /(lhs: UInt,rhs:Float)->Float{
    return Float(lhs) / rhs
}

public func /(lhs: Float,rhs:UInt)->Float{
    return lhs / Float(rhs)
}
public func hookInstanceMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
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

public func hookClassMethod(cls:AnyClass,originalSelector:Selector,swizzleSelector:Selector){  //交换方法
    let originalMethod = class_getClassMethod(cls, originalSelector)
    let swizzledMethod = class_getClassMethod(cls, swizzleSelector)
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
    //交换 static 或者 class 方法不能使用class_addMethod，直接使用method_exchangeImplementations就行
}

public func invoke(viewController:String,selector:String) {
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

public func invoke(viewController:String,selector:String,paras:AnyObject) {
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
