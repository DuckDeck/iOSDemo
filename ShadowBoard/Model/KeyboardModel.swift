//
//  File.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import Foundation
enum KeyType {
    case normal         //9宫格普通按键
    case symbol         //符号
    case backspace      //删除
    case space          //空格
    case `return`       //回车
    case nextKeyboard   //切换输入法
    case changeToNumber //切换到数字输入面板
    case changeToSymbol //切换到符号面板
    case number         //数字
    case dismiss        //关闭键盘
    case moreWords      //更多候选词
    case pinyin         //拼音
    case reType         //重输
    case changeToNormal //返回
}

class Key {
    
    let title: String?
    let type: KeyType
    let typeId: String?
    var outputText: String?
    var index: Int? = nil       //用来选拼音
    
    init(withTitle title:String, andType type: KeyType, typeId: String? = nil) {
        
        self.typeId = typeId
        self.title = title
        self.type = type
        createOutputTextWithType(type)
    }
    
    func createOutputTextWithType(_ type: KeyType) {
        
        switch type {
//        case .normal:
//            outputText = title
        case .symbol:
            outputText = title
        case .number:
            outputText = title

        default:
            outputText = nil
        }
    }
}


