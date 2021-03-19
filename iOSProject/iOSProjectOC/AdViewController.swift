//
//  AdViewController.swift
//  iOSProjectOC
//
//  Created by chen liang on 2021/3/19.
//

import UIKit
class AdViewController: UIViewController {
    lazy var timer  = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    var seconds = 5
    lazy var btnCount = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        timeCOuntDown()
        
        btnCount.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        btnCount.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 120, width: 80, height: 30)
        btnCount.addTarget(self, action: #selector(skipToHome), for: .touchUpInside)
        view.addSubview(btnCount)
    }
    
    func timeCOuntDown() {
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler {
            DispatchQueue.main.async { [weak self] in
                if self!.seconds <= 0{
                    self?.terminate()
                }
                self?.btnCount.setTitle("跳过\(self!.seconds)", for: .normal)
                self!.seconds -= 1
            }
        }
        timer.resume()
    }
    
   @objc func skipToHome() {
        terminate()
    }
    
    func terminate() {
        timer.cancel()
        switchRootViewController()
    }
    
    func switchRootViewController() {
        let window = UIApplication.shared.windows.first!
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            let old = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = ViewController()
            UIView.setAnimationsEnabled(old)
        } completion: { (_) in
            
        }

    }
}
