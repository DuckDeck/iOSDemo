
//
//  ContentViewController.swift
//  DemoLayout
//
//  Created by Stan Hu on 11/6/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
//recomand you start to request date in the viewWillAppear func to get data
open class GrandContentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    open var canScroll = false;
    open var tableView = UITableView()
    open var fingerIsTouch = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
       tableView = UITableView()
       tableView.dataSource = self
       tableView.delegate = self
        view.addSubview(tableView)
    }
    
    override open func viewWillLayoutSubviews() {
       tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - CGFloat(menuHeight))
    }

   open var menuHeight:Float{
        return 0
    }
    
   open  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }


    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        fingerIsTouch = true
    }

    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        fingerIsTouch = false
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !canScroll{
            scrollView.contentOffset = CGPoint()
        }
        if scrollView.contentOffset.y <= 0{
            canScroll = false
            scrollView.contentOffset = CGPoint()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "leaveTop"), object: nil)
        }
        tableView.showsVerticalScrollIndicator = canScroll
    }
}




