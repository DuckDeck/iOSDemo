//: Playground - noun: a place where people can play

import UIKit

 //Mirror 都可以对其进行探索。强大的运行时特性，也意味着额外的开销。Mirror 的文档明确告诉我们，
 //这个类型更多是用来在 Playground 和调试器中进行输出和观察用的。如果我们想要以高效的方式来处理字典转换问题，也许应该试试看其他思路
//





let leaveWord = NSMutableAttributedString(string:  "留言: 民地地 asdlfk 地 进kasjdfk  al;sjf；lasd要工划顶起黑苹果机加工工要 工地工)")
let paraStyle = NSMutableParagraphStyle()
paraStyle.lineSpacing = 3
leaveWord.addAttributes([NSAttributedString.Key.paragraphStyle:paraStyle], range: NSMakeRange(0, leaveWord.length))
let size = leaveWord.size()



