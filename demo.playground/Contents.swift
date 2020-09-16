//: Playground - noun: a place where people can play

import UIKit

 //Mirror 都可以对其进行探索。强大的运行时特性，也意味着额外的开销。Mirror 的文档明确告诉我们，
 //这个类型更多是用来在 Playground 和调试器中进行输出和观察用的。如果我们想要以高效的方式来处理字典转换问题，也许应该试试看其他思路
//


String(-20)


let leaveWord = NSMutableAttributedString(string:  "留言: 民地地 asdlfk 地 进kasjdfk  al;sjf；lasd要工划顶起黑苹果机加工工要 工地工)")
let paraStyle = NSMutableParagraphStyle()
paraStyle.lineSpacing = 3
leaveWord.addAttributes([NSAttributedString.Key.paragraphStyle:paraStyle], range: NSMakeRange(0, leaveWord.length))
let size = leaveWord.size()


var zzz = [2,3,4,5,6,8]
for z in zzz {
    if z % 2 == 0{
        zzz.removeAll { (item) -> Bool in
            return item == z
        }
    }
}

print(zzz)



let format = NumberFormatter()
format.numberStyle = .decimal
//format.maximumFractionDigits = 2
format.minimumFractionDigits = 2
var moneyStr = format.string(from: NSNumber(value: 100100.0/100.0))!




var a = 100

func testa(p:UnsafeMutableRawPointer){
    print("a = ", p.load(as: Int.self))
    p.storeBytes(of: 50, as: Int.self)
}

testa(p: &a)

print(a)

var p1 = withUnsafeMutablePointer(to: &a) { $0 }
p1.pointee = 200
print(p1.pointee)

let p2 = withUnsafePointer(to: &a){$0}
print(p1)
print(p2)

var p3 = withUnsafeMutablePointer(to: &a){UnsafeMutableRawPointer($0)}
print(p3.load(as: Int.self))
p3.storeBytes(of: 111, as: Int.self)
print(p3.load(as: Int.self))

var p4 = withUnsafePointer(to: &a){UnsafeRawPointer($0)}
print(p4.load(as: Int.self))

print(p3)
print(p4)

//获取指针的指针
var pp = withUnsafePointer(to: &p4){$0}
print(pp.pointee)


var p5 = malloc(16)
p5?.storeBytes(of: 10, as: Int.self)
p5?.storeBytes(of: 12, toByteOffset: 8, as: Int.self)

print(p5?.load(as: Int.self) ?? 0)
print(p5?.load(fromByteOffset: 8, as: Int.self) ?? 0)
free(p5)

print(Int.max)

var p6 = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 1)
p6.storeBytes(of: 100, as: Int.self)

var p7 = p6.advanced(by: 8)
p7.storeBytes(of: 120, as: Int.self)

print(p6.load(as: Int.self))
print(p6.advanced(by: 8).load(as: Int.self))
p6.deallocate()

var p8 = UnsafeMutablePointer<Int>.allocate(capacity: 3)
p8.initialize(to: 123)
p8.initialize(repeating: 14, count: 2)

var p9 = p8.successor()
print(p9.pointee)
p9.successor().initialize(to: 15)
print(p9.successor().pointee)
p8.deinitialize(count: 3)
p8.deallocate()

var p10 = UnsafeMutableRawPointer(p8)
print(p10.load(as: Int.self))
print(p8)
print(p10)
print(p8.pointee)

var p11 = p10.assumingMemoryBound(to: Int.self)
print(p11.pointee)
print(p11)
p11.pointee = 1221
print(p8.pointee)
