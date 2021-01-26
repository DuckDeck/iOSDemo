//
//  TouchTestViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 17/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class TouchTestViewController: UIViewController,drawViewDelegate {
    var _drawView:DrawView?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true //目前这个功能无解,无法在App里面用代码禁用多任务手势
        view.isMultipleTouchEnabled = true  //允许多点  //因为和多任务手势冲突,所以当用4指的4指以上时会导致功能不可用.这个要关掉系统的多任务手势就行了,现在是想办法能让代码关了多任务手势
        view.backgroundColor = UIColor.black
        view.addSubview(drawView)
        view.sendSubviewToBack(drawView)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    var drawView:DrawView
    {
        get{
            if(_drawView == nil)
            {
                _drawView = DrawView(frame: view.frame)
                _drawView?.delegate = self
            }
            return _drawView!
        }
    }
    
    func btnClick(sender: UIButton) {
        let setting = SettingViewController()
        self.present(setting, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
