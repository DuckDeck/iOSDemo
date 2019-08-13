//
//  Regex.swift
//  ConsoleSwift
//
//  Created by Stan Hu on 2019/8/12.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

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
    return regexTool(rhs).match(input: lhs)
}


class RegexTest {
    func testRegex1() {
        let res =  "😄🇮🇳" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
        print("😄🇮🇳 =~ [\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff] 结果是\(res)")
    }
    func testRegex2() {
        let res =  "😄🇮🇳" =~ "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff]"
        print("😄🇮🇳 =~ [\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff] 结果是\(res)")
    }
}
