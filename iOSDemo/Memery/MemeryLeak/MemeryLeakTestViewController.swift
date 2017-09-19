//
//  MemeryLeakTestViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
class MemeryLeakTestViewController: UIViewController {

    let lblNum = UILabel()
    var num = 1
    override func loadView() {
        super.loadView()
        self.view = TGFrameLayout(frame: self.view.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        lblNum.tg_top.equal(110)
        lblNum.tg_left.equal(10)
        lblNum.tg_height.equal(40)
        lblNum.tg_width.equal(80)
        view.addSubview(lblNum)
        
        //情况1 nstimer
        
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MemeryLeakTestViewController.tick), userInfo: nil, repeats: true)
        timer.fire()
        //这个MemeryLeakTestViewController不能回收了，因为有timer强引用
        //但是对于instrument来说，这并不算内存leak,在为instrument检查的是代码层面的leak,就算是ARC，也有些地方是需要手动管理内存的，比如
        //class_copyPropertyList方法，返回的对象就需要手动free，如果不free，就会memery leak
        //所以这种leak只能用一些工具来检查
        // 看文档
        //Leaked memory: Memory unreferenced by your application that cannot be used again or freed (also detectable by using the Leaks instrument).
       //Abandoned memory: Memory still referenced by your application that has no useful purpose.
        //Cached memory: Memory still referenced by your application that might be used again for better performance.

 
                  

        
        //情况2 block
        
        //情况3 delegate
        
        //情况4 相互引用
        
        //情况5 句柄等资源没有回收
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func tick()  {
        num += 1
        lblNum.text = "\(num)"
        Log(message: num)
    }
    
    deinit {
        Log(message: "\(type(of:self))已经被回收了")
    }
    
}
