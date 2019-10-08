//
//  PorcessVideoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/9/26.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class PorcessVideoViewController: UIViewController {
    let imgView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
// NSString* path = [[NSBundle mainBundle] pathForResource:@"cxk" ofType:@"mp4"];
        if let path = Bundle.main.path(forResource: "cxk", ofType: "mp4"){
            opencvTool.getVideoImage(path) { (img) in
                self.imgView.image = img
            }
        }
        imgView.contentMode = .scaleAspectFit
        imgView.addTo(view: view).snp.makeConstraints { (m) in
           m.edges.equalTo(view)
       }
    }
    

   

}
