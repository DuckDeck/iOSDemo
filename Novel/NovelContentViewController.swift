//
//  NovelContentViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 15/9/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import URLNavigator
final class NovelContentViewController: UIViewController {
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")  }
    var tb = UITableView()
    var novelInfo:NovelInfo?
    var currentSection : SectionInfo?
    var arrSectionUrl : [SectionInfo]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension NovelContentViewController:URLNavigable{
    convenience init?(navigation: Navigation) {
        guard let dict = navigation.navigationContext as? [String:Any] else { return nil }
        self.init()
       novelInfo = dict["novelInfo"] as? NovelInfo
       currentSection = dict["currentSection"] as? SectionInfo
       arrSectionUrl = dict["arrSectionUrl"] as? [SectionInfo]
    }
}
