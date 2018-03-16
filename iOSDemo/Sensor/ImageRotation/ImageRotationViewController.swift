//
//  ImageRotationViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 11/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import CoreMotion
import SnapKit
class ImageRotationViewController: UIViewController {

    let cmManager = CMMotionManager()
    var timer:GrandTimer?
    let lbl1 = UILabel()
    let lbl2 = UILabel()
    let lbl3 = UILabel()
    var XArray = [Double]()
    var YArray = [Double]()
    let img = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl1.numberOfLines = 0
        view.addSubview(lbl1)
        lbl1.snp.makeConstraints { (m) in
            m.top.equalTo(64)
            m.height.equalTo(25)
            m.left.equalTo(10)
        }
        lbl2.numberOfLines = 0
        view.addSubview(lbl2)
        lbl2.snp.makeConstraints { (m) in
            m.height.equalTo(25)
            m.top.equalTo(lbl1.snp.bottom)
            m.left.equalTo(10)
        }
        
        
        lbl3.numberOfLines = 0
        view.addSubview(lbl3)
        lbl3.snp.makeConstraints { (m) in
            m.height.equalTo(35)
            m.top.equalTo(lbl2.snp.bottom)
            m.left.equalTo(10)
        }
        
        
        
        img.image = UIImage(named: "2")
        img.contentMode = .scaleAspectFit
        view.addSubview(img)
        img.snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(140)
        }
        
        
        view.backgroundColor = UIColor.white
        
        if cmManager.isAccelerometerAvailable {
            cmManager.accelerometerUpdateInterval = 0.02
            cmManager.startAccelerometerUpdates()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "拉", style: .plain, target: self, action: #selector(getData))
        weak var weakself = self
        timer = GrandTimer.every(TimeSpan.fromTicks(20), block: {
//            print("x=\(String(describing: weakself?.cmManager.accelerometerData?.acceleration.x))")
//            print("y=\(String(describing: weakself?.cmManager.accelerometerData?.acceleration.y))")
//            print("z=\(String(describing: weakself?.cmManager.accelerometerData?.acceleration.z))")
            weakself?.lbl1.text = "x: \(weakself!.cmManager.accelerometerData!.acceleration.x)"
            
            weakself?.lbl2.text = "y: \(weakself!.cmManager.accelerometerData!.acceleration.y)"
            
            weakself?.lbl3.text = "z: \(weakself!.cmManager.accelerometerData!.acceleration.z)"
            
            if weakself!.XArray.count >= 5{
                 weakself!.XArray.removeFirst()
            }
            
            weakself?.XArray.append(weakself!.cmManager.accelerometerData!.acceleration.x)
            
            if weakself!.YArray.count >= 5{
                weakself!.YArray.removeFirst()
            }
            
            weakself?.YArray.append(weakself!.cmManager.accelerometerData!.acceleration.y)
            
            let rotation = atan2(weakself!.getAvgX(), weakself!.getAvgY()) - Double.pi
            weakself?.img.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
        })
        
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        stop()
    }
    
    func stop() {
        if cmManager.isAccelerometerActive{
            cmManager.stopAccelerometerUpdates()
        }
    }
    
    func getAvgX() -> Double {
        var x:Double = 0
        for i in XArray{
            x = i + x
        }
        return x / XArray.count
    }
    
    func getAvgY() -> Double {
        var x:Double = 0
        for i in YArray{
            x = i + x
        }
        return x / YArray.count
    }
    
    @objc func getData()  {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
