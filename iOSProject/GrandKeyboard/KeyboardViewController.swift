//
//  KeyboardViewController.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/3/25.
//

import UIKit
import CommonLibrary
import Kingfisher
class KeyboardViewController: UIInputViewController {

     var nextKeyboardButton: UIButton!
    var img = UIImageView()
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        
        img.frame = CGRect(x: 0, y: 20, width: 200, height: 200)
        view.addSubview(img)
        img.kf.setImage(with: Source.network(ImageResource(downloadURL: URL(string: "https://img1.gamersky.com/upimg/users/2021/04/10/origin_202104101719515372.jpg")!)))
        
        if let item =  "434g+0.54.5*1.3.4+9.0.2-9.2+123.77".numOperatePart(){
           let _ = calculatorResult(numOperas: item)
        }
        
        let cal = StringCalculator()
        //434g+0.54.5*1.3.4+9%-0.2-9.2+123.77
        //434g+0.54.5*1.3.4+9%-0.2-9.2+123.77
        let tmp = cal.parse(st: "(-5.9-7.2)*-550")
        print(tmp)

    }
    


//    override func viewWillLayoutSubviews() {
//        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
//        super.viewWillLayoutSubviews()
//    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    func calculatorResult(numOperas:([Double],[NumOperate])?) -> (String,String)? {
        if let nums = numOperas{
            var tmp:Decimal = 0.0
            var operaString = ""
            for item in nums.1.enumerated() {
                if item.offset == 0{
                    tmp = Decimal(nums.0[0])
                }
                switch item.element {
                case .Add:
                    tmp = tmp + Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "+"
                case .Minus:
                    tmp = tmp - Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "-"
                case .Multiply:
                    tmp = tmp * Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "x"
                case .Devided:
                    tmp = tmp / Decimal(nums.0[item.offset + 1])
                    operaString += String(nums.0[item.offset]) + "/"
                }
                if item.offset == nums.1.count - 1 {
                    operaString += String(nums.0[item.offset + 1])
                }
            }
            return ("\(tmp)",operaString + "=\(tmp)")
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        HttpClient.download(url: URL(string: "https://img1.gamersky.com/upimg/users/2021/04/10/origin_202104101719515372.jpg")!, toFile: URL(fileURLWithPath: NSTemporaryDirectory() + "2.jpg")) { (err) in
            print(err)
        }
        
        HttpClient.get("http://lovelive.ink:7110/five/%E6%88%91").completion { (data, err) in
            print(data)
            print(err)
        }
       
        
    }
    
   
}
