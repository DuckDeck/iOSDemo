//
//  iOSProjectApp.swift
//  iOSProject
//
//  Created by shadowedge on 2021/1/4.
//

import SwiftUI
import IQKeyboardManagerSwift
import CommonLibrary
@main
struct iOSProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //这里可以使用appDelegate
    @Environment(\.scenePhase) var scenePhase                       //这里可以使用scene周期
    
    init() {
        print("you application is starting up. App initialiser and can init something here ")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                print("here handle deeplink\(url)")
            })
        }.onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase{
            case .active:
                print("iOSProjectApp is active")
            case .inactive:
                print("iOSProjectApp is inactive")
            case .background:
                print("iOSProjectApp is background")
            
            @unknown default:
                print("Oh - interesting: in app cycle I received an unexpected new value.")
            }
        }
    }
    
}
//添加appdelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        IQKeyboardManager.shared.enable = true
        
        if let item =  "434g+0.54.5*1.3.4+9.0.2-9.2+123.77".numOperatePart(){
           let _ = calculatorResult(numOperas: item)
        }
        return true
    }
    //如果有些库还是用appDelegate来处理的话还是可以在这里处理生命周期, 下面方法不用调用
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("iOSProjectApp is applicationDidBecomeActive")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("iOSProjectApp is applicationWillResignActive")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("iOSProjectApp is applicationDidEnterBackground")
    }
    
    func calculatorResult(numOperas:([Double],[NumOperate])?) -> (String,String)? {
        if let nums = numOperas{
            var tmp:Decimal = 0.0
            var operaString = ""
            for item in nums.1.enumerated() {
                if item.offset == 0{
                    tmp = Decimal(nums.0[0])
                }
                switch item.element {
                case .Add:
                    tmp = tmp + Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "+"
                case .Minus:
                    tmp = tmp - Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "-"
                case .Multiply:
                    tmp = tmp * Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "x"
                case .Devided:
                    tmp = tmp / Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "/"
                }
                if item.offset == nums.1.count - 1 {
                    operaString += String(nums.0[item.offset + 1])
                }
            }
            return ("\(tmp)",operaString + "=\(tmp)")
        }
        return nil
    }
}


class StringCalculator {
    private var numbers = Stack<Decimal>()
    private var chs = Stack<Character>()
    /**
     * 比较当前操作符与栈顶元素操作符优先级，如果比栈顶元素优先级高，则返回true，否则返回false
     *
     * @param str 需要进行比较的字符
     * @return 比较结果 true代表比栈顶元素优先级高，false代表比栈顶元素优先级低
     */
    private func compare(c:Character)->Bool{
        if c.isWhitespace {
            return true
        }
        guard let last = chs.last else{
            return false
        }
        switch c {
        case "*","x","/":
            if last == "+" || last == "-" {
                return true
            }
            else{
                return false
            }
        case "+","-":
            return false
        default:
            return false
        }
        
    }
    
    func calculator(st:String) -> Decimal {
        var sb = st
        var num = ""
        var tem:Character? = nil
        var next:Character? = nil
        while sb.count > 0 {
            tem = sb.first
            sb = sb.substring(from: 1)
            if tem?.isNumber ?? false {
                num.append(tem!)
            }
            else{
                if num.count > 0 && !num.isEmpty {
                    let bd = num.toDecimal()!
                    numbers.push(element: bd)
                    num.removeAll()
                }
                if !chs.isEmpty {
                   
                }
            }
            
        }
        return 0
    }
    
    var result:Decimal?
    var source = ""
    
    
    func calculator() {
        let b = numbers.pop()
        var a:Decimal? = nil
        a = numbers.pop()
        let ope = chs.pop()
        switch ope {
        case "+":
            result = a! + b
            numbers.push(element: result!)
            
        case "-":
            result = a! - b
            numbers.push(element: result!)
        case "*","x":
            result = a! * b
            numbers.push(element: result!)
            
        case "/":
            result = a! / b
            numbers.push(element: result!)
        default:
            break
        }
    }
}

class Stack<T> {
    fileprivate var arr:[T]
    init() {
        arr = [T]()
    }
    var count:Int{
        return arr.count
    }
    func push(element:T)  {
        arr.append(element)
    }
    func pop() -> T {
        return arr.removeFirst()
    }
    
    var last:T?{
        return arr.last
    }
    
    var isEmpty:Bool{
        return arr.isEmpty
    }
}
