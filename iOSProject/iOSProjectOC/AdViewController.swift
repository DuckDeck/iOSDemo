//
//  AdViewController.swift
//  iOSProjectOC
//
//  Created by chen liang on 2021/3/19.
//

import UIKit
import CommonLibrary

class AdViewController: UIViewController {
    lazy var timer  = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
    var seconds = 5
    lazy var btnCount = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        timeCountDown()
        
        btnCount.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        btnCount.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 120, width: 80, height: 30)
        btnCount.addTarget(self, action: #selector(skipToHome), for: .touchUpInside)
        view.addSubview(btnCount)
        
        
    }
    
    func timeCountDown() {
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
            let newNav = UINavigationController(rootViewController: ViewController())
            window.rootViewController = newNav
            UIView.setAnimationsEnabled(old)
            
        } completion: { (_) in
            self.downloadImage()
        }

    }
    
    func downloadImage() {
//        download(url: URL(string: "https://xcimg.szwego.com/20210412/i1618225504_1963_0.jpg")!, toFile: URL(fileURLWithPath: NSTemporaryDirectory() + "1.jpg")) { (err) in
//            
//        }
    }

    
    
    
    func patch() {
        let path1 = Bundle.main.path(forResource: "old", ofType: "zip")
        let strs = ["bspatch",path1,createPath(file: "test.zip"),"\(NSTemporaryDirectory())diff_Test"]
        var args = strs.map{strdup($0)}
        defer {
            args.forEach{$0?.deallocate()}
        }
        let result = BsdiffUntils_bspatch(4, &args)
        print(result)
    }
    
    func createPath(file:String) -> String {
        let tmp = NSTemporaryDirectory()
        let filePath = "\(tmp)\(file)"
        if !FileManager.default.fileExists(atPath: filePath) {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        return filePath
    }
}
