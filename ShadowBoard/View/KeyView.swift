//
//  KeyView.swift
//  GrandKeyboard
//
//  Created by chen liang on 2021/4/15.
//

import UIKit
let grayColor = UIColor.init(red: 200/255.0, green: 203/255.0, blue: 211/255.0, alpha: 1)
let blueColor = UIColor.init(red: 10/255.0, green: 96/255.0, blue: 254/255.0, alpha: 1)

class KeyView: UIControl {
    
    let titleLabel = UILabel()
    let key: Key
    
    init(withKey key: Key) {
        self.key = key

        super.init(frame: CGRect.zero)
        updateBackgroundColorWithType(key.type)

        titleLabel.text = key.title
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        titleLabel.snp.makeConstraints({ (make) -> Void in
            make.center.equalToSuperview()
        })

        super.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let color = self.backgroundColor
        if color == UIColor.white {
            self.backgroundColor = grayColor
        } else {
            self.backgroundColor = UIColor.white
            if self.key.type == .return {
                self.titleLabel.textColor = UIColor.black
            }
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updateBackgroundColorWithType(key.type)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        updateBackgroundColorWithType(key.type)
    }

    func updateBackgroundColorWithType(_ type: KeyType) {
        switch type {
        case .symbol,
             .backspace,
             .nextKeyboard,
             .pinyin,
             .reType:
            backgroundColor = grayColor
        case .return:
            backgroundColor = blueColor
            titleLabel.textColor = UIColor.white
            
        default:
            backgroundColor = UIColor.white
        }

    }
}
