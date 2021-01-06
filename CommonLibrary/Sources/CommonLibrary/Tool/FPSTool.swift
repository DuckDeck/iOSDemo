//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/6.
//

import UIKit
public class WeakProxy: NSObject {
    weak var target:NSObjectProtocol?
    init(target:NSObjectProtocol) {
        self.target = target
        super.init()
    }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        return (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}

public class FPSLable: UILabel {
    var link:CADisplayLink!
    //记录上次方法执行次数
    var count = 0
    var lastTime:TimeInterval = 0
    var _font:UIFont!
    var _subFont:UIFont!
    fileprivate let defaultSize = CGSize(width: 55, height: 20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if frame.size.width == 0 && frame.size.height == 0 {
            self.frame.size = defaultSize
        }
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.textAlignment = .center
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        _font = UIFont(name: "Menlo", size: 14)
        if _font != nil {
            _subFont = UIFont(name: "Menlo", size: 4)
        }
        else{
            _font = UIFont(name: "Courier", size: 14)
            _subFont = UIFont(name: "Courier", size: 4)

        }
        
        link = CADisplayLink(target: WeakProxy.init(target: self), selector: #selector(tick(link:)))
        link.add(to: RunLoop.main, forMode: .common)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        link.invalidate()
    }
    
    @objc func tick(link:CADisplayLink) {
        guard lastTime != 0 else {
            lastTime = link.timestamp
            return
        }
        
        count += 1
        let timePassed = link.timestamp - lastTime
        guard timePassed >= 1 else {
            return
        }
        lastTime = link.timestamp
        let fps = Double(count) / timePassed
        count = 0
        
        
        let progeress = fps / 60
        let color = UIColor(hue: CGFloat(0.27 * (progeress - 0.2)), saturation: 1, brightness: 0.9, alpha: 1)
        let text = NSMutableAttributedString(string: "\(Int(round(fps))) FPS")
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: text.length - 3))
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: text.length - 3, length: 3))
        text.addAttribute(NSAttributedString.Key.font, value: _font, range: NSRange(location: 0, length: text.length))
        text.addAttribute(NSAttributedString.Key.font, value: _subFont, range: NSRange(location: text.length - 4, length: 1))
        self.attributedText = text
    }
}
