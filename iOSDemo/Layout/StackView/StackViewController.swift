//
//  StackViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 26/01/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class StackViewController: BaseViewController {

    var vStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "StackView"
        view.backgroundColor = UIColor.white
        view.addSubview(vStack)
        vStack.axis = .vertical
        vStack.distribution = .fillProportionally
        vStack.snp.makeConstraints { (m) in
            m.top.equalTo(NavigationBarHeight)
            m.left.right.equalTo(0)
        }
        
        let right = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(addView))
        navigationItem.rightBarButtonItem = right
        // Do any additional setup after loading the view.
    }
    
    func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.random
        return view
    }

    @objc func addView()  {
        let v = createView()
        vStack.addArrangedSubview(v)
        v.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.height.equalTo(50)
//            m.top.equalTo(15) //can not use top in stackview
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
