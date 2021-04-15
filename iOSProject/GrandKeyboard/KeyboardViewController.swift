//
//  KeyboardViewController.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/3/25.
//

import UIKit
import CommonLibrary
import Kingfisher
import SnapKit
let bannerHeight = 55 as CGFloat
let lineColor = UIColor.lightGray
let lineThickness = 0.5
let historyPath: String = { () -> String in
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
    let documentsDirectory = paths.object(at: 0) as! NSString
    let path = documentsDirectory.appendingPathComponent("TypingHistory.plist")
    return path
}()

let historyDictionary: NSMutableDictionary? = { () -> NSMutableDictionary? in
    let dict = NSMutableDictionary(contentsOfFile: historyPath)
    return dict
}()

class KeyboardViewController: UIInputViewController {

    var symbolStore = SymbolKeyStore()
    var keysDictionary = [String: KeyView]()
    var bannerView: UIView? = nil
    var bottomView: UIView? = nil
    var keyboardView: UIView? = nil
    var pinyinLabel: UILabel? = nil
    
    
    var wordsQuickCollection: UICollectionView? = nil
    var symbolCollection: UICollectionView? = nil
    var wordsCollection: UICollectionView? = nil
//    var allSymbolCollection: UICollectionView? = nil
    var numberView = UIView()
    
    var selectedIndex = 0               //选拼音index
    var saveIndex = true                //true为没有选中拼音，false为已经选中拼音
    var isTyping = false                //打字模式
    var isClickSpaceOrWord = false      //是否点击了空格或者选择了字
    
    var idString: String = ""
    
    
    var pinyinStore = PinyinStore()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Perform custom UI setup here
    }
    
    
    
  
    deinit {
        print("Keyboard Deinit")
    }
   
}
