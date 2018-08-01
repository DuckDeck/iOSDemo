//
//  DemoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/8/1.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class DemoViewController: BaseViewController {

    let btnLargeTouch = UIButton()
    let btnLargeTouch2 = TouchIncreaseButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        btnLargeTouch.layer.cornerRadius = 50
        btnLargeTouch.touchInsets = UIEdgeInsets(top: -30, left: -30, bottom: 30, right: 30) //这样没有用，因为根本没触发到
        btnLargeTouch.addTarget(self, action: #selector(testTouch), for: .touchUpInside)
        btnLargeTouch.color(color: UIColor.gray).title(title: "大的边缘范围").bgColor(color: UIColor.yellow).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(100)
            m.top.equalTo(200)
            m.width.height.equalTo(100)
        }
        
        btnLargeTouch2.layer.cornerRadius = 50
        btnLargeTouch2.addTarget(self, action: #selector(testTouch2), for: .touchUpInside)
        btnLargeTouch2.color(color: UIColor.gray).title(title: "大的边缘范围").bgColor(color: UIColor.yellow).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(100)
            m.top.equalTo(400)
            m.width.height.equalTo(100)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         btnLargeTouch.touchInsets = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50) //要这样写才有用，那我还是感觉实用不是很大
    }
    
    @objc func testTouch() {
        Log(message: "这里也可以点到我")
    }
    
    @objc func testTouch2() {
        Log(message: "这里也可以点到我的另一个")
    }
}


class TouchIncreaseButton: UIButton {
    
    private let btnWidth : CGFloat = 44
    private let btnHeight : CGFloat = 44
    
    private func hitTestBounds(minimumHitTestWidth minWidth : CGFloat,minimumHitTestHeight minHeight : CGFloat) -> CGRect {
        var hitTestBounds = self.bounds
        if minWidth > bounds.size.width {
            hitTestBounds.size.width = minWidth
            hitTestBounds.origin.x -= (hitTestBounds.size.width - bounds.size.width)/2
        }
        if minHeight > bounds.size.height {
            hitTestBounds.size.height = minHeight
            hitTestBounds.origin.y -= (hitTestBounds.size.height - bounds.size.height)/2
        }
        
        return hitTestBounds
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = hitTestBounds(minimumHitTestWidth: btnWidth, minimumHitTestHeight: btnHeight)
        return rect.contains(point)
    }
}
