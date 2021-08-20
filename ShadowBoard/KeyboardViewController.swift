//
//  KeyboardViewController.swift
//  ShadowBoard
//
//  Created by Stan Hu on 2021/8/20.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import UIKit

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

class KeyboardViewController: UIInputViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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

        (keyboardView, bannerView, bottomView) = defaultKeyboard()
        addViewsToBanner()
        
        // Perform custom UI setup here

        self.inputView?.addSubview(keyboardView!)
        keyboardView!.snp.makeConstraints({ (make) -> Void in
            make.left.right.bottom.top.equalToSuperview()
            make.height.greaterThanOrEqualTo(216+bannerHeight)
        })
    }
    
    func addTargetToKeys(_ dict: [String: KeyView]) {
        
        for (key, value) in dict {
            switch key {
            case "2","3","4","5","6","7","8","9":
                value.addTarget(self, action: #selector(KeyboardViewController.tapNormalKey(_:)), for: .touchDown)
                
            default:
                value.addTarget(self, action: #selector(KeyboardViewController.tapOtherKey(_:)), for: .touchDown)
            }
        }
    }
    
    func updateTypingViews() {
        if isClickSpaceOrWord {
            pinyinStore.currentIndex = 0
            pinyinStore.pinyinSelected = ""
        }
        isClickSpaceOrWord = false

        if !pinyinStore.isInHistory || pinyinStore.needSearchHistory {      //如果不在历史中或者需要继续查询历史
            pinyinStore.id = idString                                       //在历史中且不要查询历史就不会进if
        }
        if idString == "" {
            isTyping = false
            saveIndex = true
            pinyinStore.clearData()
        }
        if isTyping {
            if pinyinStore.pinyins.count == 0 {
                let proxy = textDocumentProxy as UITextDocumentProxy
                var text = ""
                for str in pinyinStore.wordSelected {
                    text += str
                }
                proxy.insertText(text)
                let pinyin = PinyinStore.splitPinyinStrings(pinyinStore.allPinyins)
                saveToHistory(withId: pinyinStore.id, pinyin: pinyin, word: text)
                isTyping = false
                saveIndex = true
                pinyinStore.clearData()
                idString = ""
            }
        }
        
        
        if isTyping {
            self.pinyinLabel?.text = pinyinStore.splitedPinyinString
        } else {
            self.pinyinLabel?.text = ""
            saveIndex = true
        }
        

        
        UIView.performWithoutAnimation {
            self.symbolCollection?.reloadData()
            self.wordsQuickCollection?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            //            self.wordsQuickCollection?.layoutIfNeeded()
            //            self.wordsQuickCollection?.reloadData()
        }
        
    }
    
    @objc func tapNormalKey(_ sender: KeyView) {
        isTyping = true
        idString += sender.key.typeId!
        
        isClickSpaceOrWord = false

        if saveIndex == false {
            pinyinStore.currentIndex = 0
            pinyinStore.pinyinSelected = ""
            pinyinStore.indexStore.removeLast()
            pinyinStore.allPinyins.removeLast()

            saveIndex = true
        }
        
        self.wordsQuickCollection?.setContentOffset(CGPoint.zero, animated: false)
        updateTypingViews()
    }
    
    @objc  func tapOtherKey(_ sender: KeyView) {
        let proxy = textDocumentProxy as UITextDocumentProxy

        isClickSpaceOrWord = false

        let type = sender.key.type
        switch type {
        case .pinyin:
            pinyinStore.currentIndex = sender.key.index!
            pinyinStore.isInHistory = false
            pinyinStore.needSearchHistory = false
            selectedIndex = sender.key.index!
            let length = pinyinStore.pinyinSelected.count
            
            if !saveIndex {
                pinyinStore.indexStore.removeLast()
                pinyinStore.allPinyins.removeLast()
            }
            pinyinStore.allPinyins.append(pinyinStore.pinyinSelected)
            var index = pinyinStore.indexStore.last!
            index += length
            pinyinStore.indexStore.append(index)
            saveIndex = false
            
            UIView.performWithoutAnimation {
                self.wordsQuickCollection?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }
            self.pinyinLabel?.text = pinyinStore.splitedPinyinString

        case .symbol, .number:
            proxy.insertText(sender.key.outputText!)
            
        case .space:
            isClickSpaceOrWord = true
            if isTyping {
                let word = pinyinStore.words[0]
                pinyinStore.wordSelected.append(word)
                
                if pinyinStore.isInHistory {
                    pinyinStore.allPinyins.append(pinyinStore.splitedPinyinString)
                    pinyinStore.pinyins.removeAll()         //就是清除数据
                    pinyinStore.needSearchHistory = false
                } else {
                    pinyinStore.currentIndex = selectedIndex
                    let length = pinyinStore.pinyinSelected.count
                    var index = pinyinStore.indexStore.last!
                    if saveIndex {
                        index += length
                        pinyinStore.indexStore.append(index)
                        pinyinStore.allPinyins.append(pinyinStore.pinyinSelected)
                    }
                }
                
                pinyinStore.pinyinSelected = ""
                saveIndex = true
                updateTypingViews()
                selectedIndex = 0

            } else {
                proxy.insertText(" ")
            }

        case .backspace:
            
            
            let img = UIImage.fromColor(color: UIColor.red, size: CGSize(width: 200, height: 200))
            let data = img.pngData()
            let pb = UIPasteboard.general
            pb.setData(data!, forPasteboardType: "public.png")
            
            if isTyping {
                if pinyinStore.indexStore.count > 1 {       //有选中的拼音或者字
                    pinyinStore.indexStore.removeLast()
                    pinyinStore.allPinyins.removeLast()
                    pinyinStore.currentIndex = 0
                    pinyinStore.pinyinSelected = ""

                    if saveIndex && pinyinStore.wordSelected.count > 0 {    //若没有选中拼音且有选中字
                        pinyinStore.wordSelected.removeLast()
                    }

                    saveIndex = true
                    updateTypingViews()

                } else {
                    idString.removeLast()
//                    idString.remove(at: idString.index(before: idString.endIndex))
                    pinyinStore.isInHistory = false
                    updateTypingViews()

                }
            } else {
                proxy.deleteBackward()
            }

        case .return:
            if isTyping {
                proxy.insertText((self.pinyinLabel?.text)!)
                idString = ""
                updateTypingViews()
            } else {
                proxy.insertText("\n")
            }
            
        case .reType:
            if isTyping {
                idString = ""
                saveIndex = true
                pinyinStore.clearData()
                updateTypingViews()
            }
        case .changeToNumber:
            numberView.isHidden = false
        case .changeToNormal:
            numberView.isHidden = true
//            allSymbolCollection?.isHidden = true
//        case .changeToSymbol:
//            allSymbolCollection?.isHidden = false
        default:
            break
        }
    }

    func addConstraintsToMid(_ centerView: UIView, _ arr: [KeyView]) {
        var top = centerView.snp.top
        var left = centerView.snp.left
        for (index, view) in arr.enumerated() {
            if index == 10 {
                view.snp.makeConstraints({ (make) -> Void in
                    make.height.equalToSuperview().dividedBy(4)
                    make.right.equalToSuperview()
                    make.left.equalTo(left)
                    make.top.equalTo(top)
                })
                break
            }
            if index % 3 == 2 {
                view.snp.makeConstraints({ (make) -> Void in
                    make.height.equalToSuperview().dividedBy(4)
                    make.width.equalToSuperview().dividedBy(3)
                    make.left.equalTo(left)
                    make.top.equalTo(top)
                })
                top = view.snp.bottom
                left = centerView.snp.left

            } else {
                view.snp.makeConstraints({ (make) -> Void in
                    make.height.equalToSuperview().dividedBy(4)
                    make.width.equalToSuperview().dividedBy(3)
                    make.left.equalTo(left)
                    make.top.equalTo(top)
                })
                left = view.snp.right
            }
        }
    }
    
    func addViewsToBanner() {
        
        pinyinLabel = UILabel()
        
        bannerView?.addSubview(pinyinLabel!)
        pinyinLabel!.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(10)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        })

        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = CGSize(width: 46.875, height: bannerHeight*2/5)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WordsCell.self, forCellWithReuseIdentifier: "WordsCell")
        
        bannerView?.addSubview(collectionView)
        collectionView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(pinyinLabel!.snp.bottom)
            make.left.right.equalTo(pinyinLabel!)
            make.bottom.equalToSuperview()
        })
        wordsQuickCollection = collectionView

    }
    
    func createNumberKeyboard() {
        
    }
    
    // MARK: 默认键盘
    func defaultKeyboard() -> (UIView?, UIView?, UIView?) {
        
        let keyboard = UIView(frame: CGRect.zero)
        
        //上
        let bannerView = UIView()
        keyboard.addSubview(bannerView)
        bannerView.backgroundColor = UIColor.white
        bannerView.snp.makeConstraints({ (make) -> Void in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bannerHeight)
        })
        
        //下
        let bottomView = UIView()
        keyboard.addSubview(bottomView)
        bottomView.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(bannerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        })
        
        // MARK: 左 Collection View
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 75, height: 40.5)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        collectionView.backgroundColor = grayColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SymbolCell.self, forCellWithReuseIdentifier: "SymbolCell")
        
        bottomView.addSubview(collectionView)
        collectionView.snp.makeConstraints({ (make) -> Void in
            make.top.left.equalToSuperview()
            make.width.equalToSuperview().dividedBy(5)
            make.height.equalToSuperview().multipliedBy(0.75)
        })
        self.symbolCollection = collectionView
        
        // MARK: 左下
        let leftBottonView = UIView()
        //        leftBottonView.backgroundColor = UIColor.yellow
        bottomView.addSubview(leftBottonView)
        leftBottonView.snp.makeConstraints({ (make) -> Void in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
            make.width.equalTo(collectionView)
        })
        let viewLB = KeyView(withKey: Key(withTitle: "变", andType: .nextKeyboard))
        viewLB.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        leftBottonView.addSubview(viewLB)
        viewLB.snp.makeConstraints({ (make) -> Void in
            make.edges.equalToSuperview()
        })
        
        // MARK: 右
        let rightView = UIView()
        bottomView.addSubview(rightView)
        rightView.snp.makeConstraints({ (make) -> Void in
            make.width.equalTo(collectionView)
            make.top.right.bottom.equalToSuperview()
        })
        
        let viewR1 = KeyView(withKey: Key(withTitle: "⬅︎", andType: .backspace))
        let viewR2 = KeyView(withKey: Key(withTitle: "重输", andType: .reType))
        let viewR3 = KeyView(withKey: Key(withTitle: "发送", andType: .return))
        rightView.addSubview(viewR1)
        rightView.addSubview(viewR2)
        rightView.addSubview(viewR3)
        viewR1.snp.makeConstraints({ (make) -> Void in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
        })
        viewR2.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(viewR1.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(4)
        })
        viewR3.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(viewR2.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        })
        
        
        // MARK: 中
        let centerView = UIView()
        bottomView.addSubview(centerView)
        centerView.snp.makeConstraints({ (make) -> Void in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(collectionView.snp.right)
            make.right.equalTo(rightView.snp.left)
        })
        
        let view11 = KeyView(withKey: Key(withTitle: "符号", andType: .changeToSymbol, typeId: "1"))  //1
        let view12 = KeyView(withKey: Key(withTitle: "ABC", andType: .normal, typeId: "2"))          //2
        let view13 = KeyView(withKey: Key(withTitle: "DEF", andType: .normal, typeId: "3"))          //3
        let view21 = KeyView(withKey: Key(withTitle: "GHI", andType: .normal, typeId: "4"))          //4
        let view22 = KeyView(withKey: Key(withTitle: "JKL", andType: .normal, typeId: "5"))          //5
        let view23 = KeyView(withKey: Key(withTitle: "MNO", andType: .normal, typeId: "6"))          //6
        let view31 = KeyView(withKey: Key(withTitle: "PQRS", andType: .normal, typeId: "7"))         //7
        let view32 = KeyView(withKey: Key(withTitle: "TUV", andType: .normal, typeId: "8"))          //8
        let view33 = KeyView(withKey: Key(withTitle: "WXYZ", andType: .normal, typeId: "9"))         //9
        let view41 = KeyView(withKey: Key(withTitle: "123", andType: .changeToNumber))
        let view42 = KeyView(withKey: Key(withTitle: "空格", andType: .space, typeId: "0"))           //0
        let arrMid = [view11, view12, view13, view21, view22, view23, view31, view32, view33, view41, view42]
        for view in arrMid {
            centerView.addSubview(view)
        }
        
        // MARK:
        keysDictionary["删除"] = viewR1
        keysDictionary["换行"] = viewR2
        keysDictionary["发送"] = viewR3
        keysDictionary["1"] = view11
        keysDictionary["2"] = view12
        keysDictionary["3"] = view13
        keysDictionary["4"] = view21
        keysDictionary["5"] = view22
        keysDictionary["6"] = view23
        keysDictionary["7"] = view31
        keysDictionary["8"] = view32
        keysDictionary["9"] = view33
        keysDictionary["0"] = view42
        keysDictionary["123"] = view41
        
        
        addConstraintsToMid(centerView, arrMid)
        
        
        centerView.addSubview(numberView)
        numberView.snp.makeConstraints({ (make) -> Void in
            make.edges.equalToSuperview()
        })
        let number1 = KeyView(withKey: Key(withTitle: "1", andType: .number, typeId: "1"))      //1
        let number2 = KeyView(withKey: Key(withTitle: "2", andType: .number, typeId: "2"))      //2
        let number3 = KeyView(withKey: Key(withTitle: "3", andType: .number, typeId: "3"))      //3
        let number4 = KeyView(withKey: Key(withTitle: "4", andType: .number, typeId: "4"))      //4
        let number5 = KeyView(withKey: Key(withTitle: "5", andType: .number, typeId: "5"))      //5
        let number6 = KeyView(withKey: Key(withTitle: "6", andType: .number, typeId: "6"))      //6
        let number7 = KeyView(withKey: Key(withTitle: "7", andType: .number, typeId: "7"))      //7
        let number8 = KeyView(withKey: Key(withTitle: "8", andType: .number, typeId: "8"))      //8
        let number9 = KeyView(withKey: Key(withTitle: "9", andType: .number, typeId: "9"))      //9
        let number0 = KeyView(withKey: Key(withTitle: "0", andType: .number, typeId: "0"))      //0
        let number00 = KeyView(withKey: Key(withTitle: "返回", andType: .changeToNormal))
        
        let arrNumber = [number1, number2, number3, number4, number5, number6, number7, number8, number9, number00, number0]
        for view in arrNumber {
            numberView.addSubview(view)
        }
        addConstraintsToMid(numberView, arrNumber)
        numberView.isHidden = true
        keysDictionary["11"] = number1
        keysDictionary["22"] = number2
        keysDictionary["33"] = number3
        keysDictionary["44"] = number4
        keysDictionary["55"] = number5
        keysDictionary["66"] = number6
        keysDictionary["77"] = number7
        keysDictionary["88"] = number8
        keysDictionary["99"] = number9
        keysDictionary["00"] = number0
        keysDictionary["back"] = number00

        
        //加线
        let lineBanner0 = UIView(); lineBanner0.backgroundColor = lineColor
        let lineBanner1 = UIView(); lineBanner1.backgroundColor = lineColor
        bannerView.addSubview(lineBanner0)
        bannerView.addSubview(lineBanner1)
        lineBanner0.snp.makeConstraints({ (make) -> Void in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(lineThickness)
        })
        lineBanner1.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(bannerHeight*2/5)
            make.left.right.equalToSuperview()
            make.height.equalTo(lineThickness)
        })
        
        
        let lineMid0 = UIView(); lineMid0.backgroundColor = lineColor
        let lineMid1 = UIView(); lineMid1.backgroundColor = lineColor
        let lineMid2 = UIView(); lineMid2.backgroundColor = lineColor
        let lineMid3 = UIView(); lineMid3.backgroundColor = lineColor
        let lineMid4 = UIView(); lineMid4.backgroundColor = lineColor
        let lineMid5 = UIView(); lineMid5.backgroundColor = lineColor
        let lineMid6 = UIView(); lineMid6.backgroundColor = lineColor
        let lineMid7 = UIView(); lineMid7.backgroundColor = lineColor
        bottomView.addSubview(lineMid0)
        bottomView.addSubview(lineMid1)
        bottomView.addSubview(lineMid2)
        bottomView.addSubview(lineMid3)
        bottomView.addSubview(lineMid4)
        bottomView.addSubview(lineMid5)
        bottomView.addSubview(lineMid6)
        bottomView.addSubview(lineMid7)
        lineMid0.snp.makeConstraints({ (make) -> Void in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(lineThickness)
        })
        lineMid1.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(view11.snp.bottom)
            make.left.equalTo(centerView)
            make.right.equalToSuperview()
            make.height.equalTo(lineThickness)
        })
        lineMid2.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(view21.snp.bottom)
            make.left.equalTo(centerView)
            make.height.equalTo(lineThickness)
            make.right.equalToSuperview()
        })
        lineMid3.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(view31.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalTo(centerView)
            make.height.equalTo(lineThickness)
        })
        lineMid4.snp.makeConstraints({ (make) -> Void in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(centerView)
            make.width.equalTo(lineThickness)
        })
        lineMid5.snp.makeConstraints({ (make) -> Void in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(view12)
            make.width.equalTo(lineThickness)
        })
        lineMid6.snp.makeConstraints({ (make) -> Void in
            make.top.equalToSuperview()
            make.bottom.equalTo(view33)
            make.left.equalTo(view13)
            make.width.equalTo(lineThickness)
        })
        lineMid7.snp.makeConstraints({ (make) -> Void in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(rightView)
            make.width.equalTo(lineThickness)
            
        })
        
        /*
        let layout1 = UICollectionViewFlowLayout.init()
        layout1.scrollDirection = .vertical
        layout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout1.minimumLineSpacing = 0
        layout1.minimumInteritemSpacing = 0
        layout1.itemSize = CGSize(width: 74.5, height: 40.5)
        let collectionView1 = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout1)
        collectionView1.delaysContentTouches = false
        collectionView1.canCancelContentTouches = true
        collectionView1.backgroundColor = grayColor
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.register(SymbolCell.self, forCellWithReuseIdentifier: "SymbolCell")
        allSymbolCollection = collectionView1
        bottomView.addSubview(allSymbolCollection!)
        allSymbolCollection?.backgroundColor = UIColor.white
        allSymbolCollection?.isHidden = true
        allSymbolCollection?.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalToSuperview()
            make.right.equalTo(1)
            make.top.equalTo(1)
            make.left.equalTo(collectionView.snp.right).offset(1)
        })
         */
        
        addTargetToKeys(keysDictionary)
        
        return (keyboard, bannerView, bottomView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView === self.wordsQuickCollection {
            if isTyping {
                return pinyinStore.words.count
            } else {
                return 0
            }
        }
        else {
            if isTyping {
                return pinyinStore.pinyins.count
            } else {
                return symbolStore.allSymbols.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView === self.wordsQuickCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordsCell", for: indexPath) as! WordsCell
            if isTyping {
                cell.wordslabel.text = pinyinStore.words[indexPath.row]
            }
            return cell

        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymbolCell", for: indexPath) as! SymbolCell
            
            if isTyping {
                cell.addPinyin(pinyinStore.pinyins[indexPath.row], index: indexPath.row)
            } else {
                cell.addKey(symbolStore.allSymbols[indexPath.row])
            }
            cell.keyView?.addTarget(self, action: #selector(tapOtherKey(_:)), for: .touchUpInside)

            return cell
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView === self.wordsQuickCollection {
            
            isClickSpaceOrWord = true

//            proxy.insertText(pinyinStore.words[indexPath.row])
            let word = pinyinStore.words[indexPath.row]
            pinyinStore.wordSelected.append(word)
            if pinyinStore.isInHistory && indexPath.row < pinyinStore.historyCount {
                pinyinStore.allPinyins.append(pinyinStore.splitedPinyinString)
                pinyinStore.pinyins.removeAll()         //就是清除数据
                pinyinStore.needSearchHistory = false
            } else {
                pinyinStore.isInHistory = false
                pinyinStore.needSearchHistory = false
                pinyinStore.currentIndex = selectedIndex
                let length = pinyinStore.pinyinSelected.count
                var index = pinyinStore.indexStore.last!
                if saveIndex {
                    index += length
                    pinyinStore.indexStore.append(index)
                    pinyinStore.allPinyins.append(pinyinStore.pinyinSelected)
                }
            }
            
            pinyinStore.pinyinSelected = ""
            saveIndex = true
            selectedIndex = 0
            updateTypingViews()
            
        }
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        if collectionView === self.wordsQuickCollection {
//            let cell = WordsCell(frame: CGRect.zero)
//            cell.wordslabel.text = pinyinStore.words[indexPath.row]
//            cell.layoutIfNeeded()
//            let size = cell.frame.size
//            return size
//        } else {
//            return CGSize(width: 75, height: 40.5)
//        }
//    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//
//        if collectionView === self.wordsQuickCollection {
//
//            return 10
//        }
//
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//
//        if collectionView === self.wordsQuickCollection {
//            return 10
//        }
//
//        return 0
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        if collectionView === self.wordsQuickCollection {
//            let width = collectionView.bounds.width
//            let height = collectionView.bounds.height
//            let size = CGSize(width: width, height: height/4)
//            return size
//        }
//    }
    
    
    deinit {
        print("Keyboard Deinit")
    }
   
}
func saveToHistory(withId key: String, pinyin: String, word: String) {
    
    if let dict = historyDictionary {
        let value = dict.value(forKey: key) as? Array<[String]>
        if value != nil {
            var pinyins = value![0]
            var words = value![1]
            var frequence = value![2]
            var oldIndex: Int = 0
            var index = 0
            var fre = 0
            var flag = false
            for (i, str) in words.enumerated() {
                if str == word {
                    oldIndex = i
                    fre = Int(frequence[i])!
                    fre += 1
                    flag = true
                    break
                }
            }
            for (i, str) in frequence.enumerated() {
                let num = Int(str)!
                if num < fre {
                    index = i
                    break
                }
            }
            
            if flag {       //有这个值
                words.remove(at: oldIndex)
                pinyins.remove(at: oldIndex)
                frequence.remove(at: oldIndex)
                
                words.insert(word, at: index)
                pinyins.insert(pinyin, at: index)
                frequence.insert("\(fre)", at: index)
            } else {
                words.append(word)
                pinyins.append(pinyin)
                frequence.append("1")
            }
            dict.setObject([pinyins, words, frequence], forKey: key as NSCopying)
            dict.write(toFile: historyPath, atomically: true)
            
        } else {
            dict.setObject([[pinyin], [word], ["1"]], forKey: key as NSCopying)
            dict.write(toFile: historyPath, atomically: true)
        }
    } else {
        let dict = NSMutableDictionary()
        dict.setObject([[pinyin], [word], ["1"]], forKey: key as NSCopying)
        dict.write(toFile: historyPath, atomically: true)
    }
}

//扩展UICollectionView 使得滑动scrollView可以取消UIControl的点击事件
extension UICollectionView {
    override open func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}


extension UIImage{
    static func fromColor(color:UIColor,size:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let  con = UIGraphicsGetCurrentContext()
        con?.setFillColor(color.cgColor)
        con?.fill(CGRect(origin: CGPoint.zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
