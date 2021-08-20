//
//  Calculator.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/8.
//

import Foundation
class StringCalculator {
    private var numbers = Stack<Decimal>()
    private var chs = Stack<Character>()
    public var numString = ""
    /**
     * 比较当前操作符与栈顶元素操作符优先级，如果比栈顶元素优先级高，则返回true，否则返回false
     *
     * @param str 需要进行比较的字符
     * @return 比较结果 true代表比栈顶元素优先级高，false代表比栈顶元素优先级低
     */
    private func compare(c:Character)->Bool{
        guard let last = chs.last else{
            return true
        }
        switch c {
        case "*","x","/":
            if last == "+" || last == "-" {
                return false
            }
            else{
                return true
            }
        case "+","-":
            return false
        default:
            return false
        }
    }
    
    
    func calculator(st:String) -> Decimal? {
        var sb = st
        var num = ""
        var tem:Character? = nil
        var next:Character? = nil
        while sb.count > 0 {
            tem = sb.first
            sb = sb.substring(from: 1)
            if (tem?.isNumber ?? false) || tem == "." {
                num.append(tem!)
            }
            else{
                if num.count > 0 && !num.isEmpty {
                    let bd = num.toDecimal()
                    if bd == nil {
                        clear()
                        return nil
                    }
                    numbers.push(element: bd!)
                    num.removeAll()
                }
                if !chs.isEmpty && chs.count + 1 == numbers.count {
                    while !compare(c: tem!) {
                        calculator()
                    }
                }
                if numbers.isEmpty {
                    num.append(tem!)
                }
                else{
                    chs.push(element: tem!)
                }
                next = sb.first
                if next != nil && next! == "-" {
                    num.append(next!)
                    sb.removeFirst()
                }
            }
        }
        //通常这里要计算最后一个数，但是如果本身不需要计算
        if chs.count <= 0 {
            clear()
            return nil
        }
        if let bd = num.toDecimal()
        {
            numbers.push(element: bd)
            if chs.count + 1 != numbers.count{
                clear()
                return nil
            }
            while !chs.isEmpty  {
                calculator()
            }
            return numbers.pop()
        }
        clear()
        return nil
    }
    
    func clear() {
        numbers.clear()
        chs.clear()

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
    
    func parse(st:String) -> Decimal? {
        var index = 0
        var str = st.replacingOccurrences(of: " ", with: "")
        for item in st.enumerated().reversed() {
            if !isCharValid(char: item.element) {
                index = item.offset + 1
                break
            }
        }
        str = str.substring(from: index)
        source = str
        str = changePercent(str: str)
        let start = 0
        var sts = str
        var end = sts.index(str: ")")
        while end > 0 {
            let s = sts.substring(from: start, to: end)
            let first = s.index(str: "(")
            if first == -1 {
                clear()
                return nil
            }
            let value = calculator(st: sts.substring(from: first + 1, to: end - 1))
            if value == nil {
                clear()
                return nil
            }
            sts =  sts.replaceRange(start: start, end: end, str: "\(String(describing: value!))")
            end = sts.index(str: ")")
        }
        numString = str
        return calculator(st: sts)
    }
    
    func isCharValid(char:Character) -> Bool {
        if char.isNumber {
            return true
        }
        switch char {
        case "+","-","*","x","/","(",")",".","%","÷":
            return true
        default:
            return false
        }
    }
    
    func changePercent(str:String) -> String {
        var ret = str
        let results =  str.matches(for: "(-?[0-9]+(\\.[0-9]+)?)%")
        for item in results {
            let num = item.replacingOccurrences(of: "%", with: "").toDouble()! / 100.0
            ret = ret.replacingOccurrences(of: item, with: "\(num)")
        }
        
        return ret
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
        return arr.removeLast()
    }
    
    var last:T?{
        return arr.last
    }
    
    var isEmpty:Bool{
        return arr.isEmpty
    }
    
    func clear() {
        arr.removeAll()
    }
}
