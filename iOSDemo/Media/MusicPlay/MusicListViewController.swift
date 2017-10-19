//
//  MusicListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/10/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
class MusicListViewController: UIViewController {

    let tb = UITableView()
    let arrMusics = [String]()
    
    
    
    override func loadView() {
        
        self.view = TGLinearLayout(.vert)
        
        view.addSubview(tb)
        tb.tg_width.equal(.fill)
        tb.tg_height.equal(.fill)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
