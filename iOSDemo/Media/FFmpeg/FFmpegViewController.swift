//
//  FFmpegViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/7/9.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FFmpegViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
       let path = Bundle.main.path(forResource: "test", ofType: "mp4")
       let handle = AVParseHandler(path: path!)
        handle.startParseGetAVPacke { (isVideoFrame, isFinish, packet) in
            if isFinish{
                print("Parse finish!")
                return
            }
        }
    }
    


}
