//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/26.
//
import UIKit
import CoreMotion
import SnapKit
import GrandTime
import CommonLibrary
import SwiftUI

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
        img.image = UIImage(named: "2")
        img.contentMode = .scaleAspectFit
        view.addSubview(img)
        img.snp.makeConstraints { (m) in
           m.edges.equalTo(view)
        }
        
        
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
        
        
        
      
        
        view.backgroundColor = UIColor.white
        
        if cmManager.isAccelerometerAvailable {
            cmManager.accelerometerUpdateInterval = 0.02
            cmManager.startAccelerometerUpdates()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "拉", style: .plain, target: self, action: #selector(getData))
        weak var weakself = self
        #if arch(x86_64) || arch(i386)
            let vc = UIAlertController(title: "你正在使用模拟器", message: "模拟器无法使用传感器", preferredStyle: .alert)
            vc.action(title: "确定") { (alert) in
                
            }.show()
            return
        #endif
        timer = GrandTimer.every(TimeSpan.fromTicks(80), block: {
            
            print("x=\(String(describing: weakself?.cmManager.accelerometerData?.acceleration.x.roundTo(places: 2)))")
            print("y=\(String(describing: weakself?.cmManager.accelerometerData?.acceleration.y.roundTo(places: 2)))")
            print("z=\(String(describing: weakself?.cmManager.accelerometerData?.acceleration.z.roundTo(places: 2)))")
            weakself?.lbl1.text = "x: \(weakself!.cmManager.accelerometerData!.acceleration.x.roundTo(places: 2))"
            
            weakself?.lbl2.text = "y: \(weakself!.cmManager.accelerometerData!.acceleration.y.roundTo(places: 2))"
            
            weakself?.lbl3.text = "z: \(weakself!.cmManager.accelerometerData!.acceleration.z.roundTo(places: 2))"
            
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
        timer?.fire()
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
}

struct MotionSensorDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = ImageRotationViewController
    
    func makeUIViewController(context: Context) -> ImageRotationViewController {
        return ImageRotationViewController()
    }
}
