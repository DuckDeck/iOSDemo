//
//  PinyinStore.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import Foundation
class PinyinStore {
    
    var id: String = "" {
        didSet {
            if needSearchHistory {
                isInHistory = PinyinStore.findIdInHistory(id)
            }
            if isInHistory {
                let value = historyDictionary?.value(forKey: id) as? Array<[String]>
                pinyinHistory = value![0][0]
                words = value![1]
                historyCount = words.count
            }
            if id == "" {
                words.removeAll()
                pinyins.removeAll()
            } else {
                pinyins = idToStrings(id, startIndex: indexStore.last!).0
                if pinyins.count > 0 {
                    if let str = pinyinToWord[pinyins[currentIndex]] {
                        if isInHistory {
                            let tempArr = stringToArray(str)
                            var arr = [String]()
                            var flag = true
                            for temp in tempArr {
                                for word in words {
                                    if temp == word {
                                        flag = false
                                    }
                                }
                                if flag {
                                    arr.append(temp)
                                }
                                flag = true
                            }

                            words.append(contentsOf: arr)
                        } else {
                            words = stringToArray(str)
                        }
                    }
                } else {
                    words.removeAll()
                }
            }
        }
    }
    
    var currentIndex = 0 {                   //当前选拼音的位置
        didSet {
            if pinyins.count > 0 {
                if let str = pinyinToWord[pinyins[currentIndex]] {
                    isInHistory = false
                    words = stringToArray(str)
                    pinyinSelected = pinyins[currentIndex]
                }
            }
        }
    }
    var historyCount = 0
    var needSearchHistory = true
    var indexStore = [0]                    //记录
    var isInHistory: Bool = false           //历史记录中是否有
    var pinyins = [String]()                //当前字的拼音
    var pinyinHistory: String = ""          //历史记录中的分好词的拼音
    var pinyinSelected = ""                 //已经选中的拼音
    var allPinyins = [String]()             //所有选中的拼音
    var wordSelected = [String]()           //已选中的字
    
    var splitedPinyinString: String {       //分好词的结果
        get {
            if isInHistory {
                return pinyinHistory
            } else {
                return PinyinStore.splitPinyinStrings(idToStrings(id, startIndex: indexStore.last!).1)
            }
        }
    }
    
    var words: [String] = []
    
    func clearData() {
        isInHistory = false
        id = ""
        currentIndex = 0
        indexStore = [0]
        needSearchHistory = true
        pinyins = []
        pinyinHistory = ""
        pinyinSelected = ""
        wordSelected = []
        allPinyins = []
        historyCount = 0
    }
    
    class func findIdInHistory(_ key: String) -> Bool {
        
        if let dict = historyDictionary {
            
            let value = dict.value(forKey: key) as? Array<[String]>
            if value != nil {       //历史记录里有
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }
    
    class func splitPinyinStrings(_ strings: [String]) -> String {
        var str = ""
        for pinyin in strings {
            if pinyin != strings.last {
                str += "\(pinyin)'"
            } else {
                str += pinyin
            }
        }
        return str
    }
    
    func idToStrings(_ typeId: String, startIndex: Int) -> ([String], [String]) {
        
        var firstStrings = [String]()
        var strings = [String]()
        
        var remainingLength = typeId.count
        var tempId = ""
        var index = startIndex
        remainingLength -= indexStore.last!


        for amount in (1...6).reversed() {
            if amount > remainingLength {
                continue
            }
            tempId = typeId[index..<(index+amount)]
            if let tempStrings = idStringDict[tempId] {
                for tempString in tempStrings {
                    firstStrings.append(tempString)
                }
            }
        }
        
        for str in wordSelected {
            strings.append(str)
        }
        if pinyinSelected.count > 0 {
            strings.append(pinyinSelected)
        }
        
        while remainingLength > 0 {
            for amount in (1...6).reversed() {
                if amount > remainingLength {
                    continue
                }
                tempId = typeId[index..<(index+amount)]
                if let tempStrings = idStringDict[tempId] {
                    for tempString in tempStrings {
                        strings.append(tempString)
                        break
                    }
                    index += amount
                    remainingLength -= amount
                    break
                }
            }
        }
        
        return (firstStrings, strings)
    }
}


func stringToArray(_ str: String) -> [String] {
    
    var strings = [String]()
    
    for temp in str {
        strings.append(String(temp))
    }

    return strings
}


