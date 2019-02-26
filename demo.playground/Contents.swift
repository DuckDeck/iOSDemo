//: Playground - noun: a place where people can play

import UIKit

/*
 extension Array{
 
 mutating func mergeWithUnique(array:[Element],condition:((_ item:Element)->Int))  {
 let a = self.map(condition)
 let b = array.map(condition)
 var c = [Int]()
 for s in b{
 if !a.contains(s){
 c.append(s)
 }
 }
 for s in array{
 if c.contains(condition(s)){
 self.append(s)
 }
 } //这样应该行了
 }
 
 
 }
 
 var s = [1,2,3,4,5]
 var d = [2,3,5,6]
 s.mergeWithUnique(array: d) { (item) -> Int in
 return item
 }
 print(s)
 
 
 let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
 lbl.text = "1"
 lbl.sizeToFit()
 print(lbl.frame)
 */
/*
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
 
 extension String {
 //使用正则表达式替换
 func pregReplace(pattern: String, with: String,
 options: NSRegularExpression.Options = []) -> String {
 let regex = try! NSRegularExpression(pattern: pattern, options: options)
 return regex.stringByReplacingMatches(in: self, options: [],
 range: NSMakeRange(0, self.count),
 withTemplate: with)
 }
 }
 
 infix operator =~
 func =~(lhs:String,rhs:String) -> Bool{ //正则判断
 return regexTool(rhs).match(input: lhs)
 }
 
 
 "😄🇮🇳" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
 
 
 "😄😄😄😄dsfasdf" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
 "=dsfasdf" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
 
 let s = "😤😄😄😄😄😄adfadfasfd".pregReplace(pattern: "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]", with: "")
 print(s)
 let REGEX_CELLPHONE = "^(0|86|17951)?1[0-9]{10}$"
 "11122233212" =~ REGEX_CELLPHONE
 
 
 //Mirror 都可以对其进行探索。强大的运行时特性，也意味着额外的开销。Mirror 的文档明确告诉我们，
 //这个类型更多是用来在 Playground 和调试器中进行输出和观察用的。如果我们想要以高效的方式来处理字典转换问题，也许应该试试看其他思路
 class mySlider:UISlider{
 
 override func trackRect(forBounds bounds: CGRect) -> CGRect {
 print(bounds)
 return CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
 }
 }
 let sliderUpload = mySlider(frame: CGRect(x: 0, y: 0, width: 300, height: 10))
 sliderUpload.setThumbImage(UIImage(), for: .normal)
 sliderUpload.isContinuous = true
 sliderUpload.minimumTrackTintColor = UIColor.red
 sliderUpload.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
 sliderUpload.minimumValue = 0
 sliderUpload.maximumValue = 100
 sliderUpload.isUserInteractionEnabled = false
 sliderUpload.value = 1
 */
//
/*
 roundf(3.3216 * 100) / 100
 
 let key = DispatchSpecificKey<Any>()
 DispatchQueue.main.setSpecific(key: key, value: "main")
 
 func log(){
 print("main thread: \(Thread.isMainThread)")
 let value = DispatchQueue.getSpecific(key: key)
 print("main queue: \(value != nil)")
 }
 
 DispatchQueue.global().sync {
 log()
 }
 RunLoop.current.run()
 print(123123)
 */
let s = "123123"
let cf = s as CFString
print(cf)
let nor = cf as String
print(nor)

let z = "http://www.cocoachina.com/ios/20181023/24979.html".replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "#", with: "_").replacingOccurrences(of: "&", with: "_").replacingOccurrences(of: "?", with: "_")




let txt = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
txt.placeholder = "这是一个测试"
txt.backgroundColor = UIColor.white
txt.setValue(UIColor.green, forKeyPath: "_placeholderLabel.textColor")

txt.setValue(UIFont.boldSystemFont(ofSize: 20), forKeyPath: "_placeholderLabel.font")




struct regex {
    let regex:NSRegularExpression?
    init(_ pattern:String){
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    func match(input:String)->NSTextCheckingResult?{
        if let matches = regex?.matches(in: input, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, input.count)) {
            print(matches.count)
            if matches.count > 0{
                let f = matches.first!
                return f
            }
            
        }
        return nil
    }
}

//let reg = regex("/\\w+.php")
//let r = reg.match("afsdf/adfasdf.php")
//print(r!.rangeAtIndex(0))
//("afsdf/adfasdf.php" as NSString).substringWithRange(r!.rangeAtIndex(0))
//
//let z = 11
//let ss = String(format: "%02d", z)
//
//let date = NSDate(timeIntervalSince1970: 1468811834)
//let fm = NSDateFormatter()
//fm.dateStyle = .ShortStyle
//fm.timeStyle = .ShortStyle
//let st = fm.stringFromDate(date)
//
//func cityNameToPinyin(city:String)->String{
//    let py = NSMutableString(string: city)
//    CFStringTransform(py, nil, kCFStringTransformMandarinLatin, false)
//    CFStringTransform(py, nil, kCFStringTransformStripCombiningMarks, false)
//    return py as String
//}
//
//let  url = NSURL(string: "http://192.168.1.225:8989/qfq/M00/00/01/wKgB4Vets62AQaw2AAAQLrFluws848.jpg")
//let img = UIImage(data: NSData(contentsOfURL: url!)!)

//cityNameToPinyin("深圳")

//let bar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
//let fd = bar.valueForKey("_searchField") as? UITextField
//fd?.text = "123"
//fd?.frame = CGRect(x: fd!.frame.origin.x, y: fd!.frame.origin.y - 3, width: fd!.frame.size.width, height: 34)
//bar.setValue(fd, forKey: "_searchField")

let leaveWord = NSMutableAttributedString(string:  "留言: 民地地 asdlfk 地 进kasjdfk  al;sjf；lasd要工划顶起黑苹果机加工工要 工地工)")
let paraStyle = NSMutableParagraphStyle()
paraStyle.lineSpacing = 3
leaveWord.addAttributes([NSAttributedString.Key.paragraphStyle:paraStyle], range: NSMakeRange(0, leaveWord.length))
let size = leaveWord.size()
