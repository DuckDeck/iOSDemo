//
//  WordsStore.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import Foundation
class WordsStore {
    
    var words: [String] = []
    var pinyin: String = "" {
        didSet {
            words = stringToArray(pinyin)
        }
    }
    
    
}
