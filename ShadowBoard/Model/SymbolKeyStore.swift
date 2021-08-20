//
//  SymbolKeyStore.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import Foundation
class SymbolKeyStore {
    
    var allSymbols: [Key] = []
    
    init() {
        let defaultKeys = ["，", "。", "~", "？", "！", "、"]

        for symbol in defaultKeys {
            let key = Key(withTitle: symbol, andType: .symbol)
            allSymbols.append(key)
        }
    }
    
//    @discardableResult
//    func createKey() -> Key {
//        let defaultKeys = (" ，", " 。", " ~ ", " ？", " ！", " 、")
//        let newKey =
//
//
//        allSymbols.append(newKey)
//
//        return newKey
//    }

}
