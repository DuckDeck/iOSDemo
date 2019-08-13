//
//  Regex.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 2019/8/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import Foundation

struct Regex {
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
    return Regex(rhs).match(input: lhs)
}

 let REGEX_CELLPHONE = "^(0|86|17951)?1[0-9]{10}$"

class RegexTest {
    static func testRegex1() {
        let res =  "😄🇮🇳" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
        print("😄🇮🇳 =~ [\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff] 结果是\(res)")
    }
    static func testRegex2() {
        let res =   "😄😄😄😄dsfasdf" =~  "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
        print("😄😄😄😄dsfasdf =~ [\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff] 结果是\(res)")
    }
    static func testRegex3() {
        let res =   "=dsfasdf" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
        print("=dsfasdff =~ [\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff] 结果是\(res)")
    }
    static func testRegex4() {
        let res =   "😤😄😄😄😄😄adfadfasfd".pregReplace(pattern: "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]", with: "")
        print("😤😄😄😄😄😄adfadfasfd 用 [\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff] 来替换 结果是\(res)")
    }
    static func testRegex5() {
        let res =   "11122233212" =~ REGEX_CELLPHONE
        print("11122233212 =~ REGEX_CELLPHONE 结果是\(res)")
    }
}
