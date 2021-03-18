//
//  File.swift
//  
//
//  Created by chen liang on 2021/3/17.
//

import UIKit
import CommonLibrary
import SnapKit
import SwiftUI
import GrandTime
class UIDemoViewController: UIViewController {
    var tick:Double = 1
    var timer:GrandTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let circle = CircleProgressView()
        view.addSubview(circle)
        circle.snp.makeConstraints { (m) in
            m.left.equalTo(50)
            m.top.equalTo(100)
            m.width.height.equalTo(100)
        }
        
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromSeconds(1), block: {
            circle.progress = self.tick / 100.0
            self.tick += 1.0
        }, repeats: true, dispatchQueue: DispatchQueue.global())
        timer.fire()
    }
    
}


struct UIDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIDemoViewController, context: Context) {
        
    }
    typealias UIViewControllerType = UIDemoViewController
    
    func makeUIViewController(context: Context) -> UIDemoViewController {
        return UIDemoViewController()
    }
}

