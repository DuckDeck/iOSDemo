//
//  CitySearchView.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
protocol CitySearchDelegate:NSObjectProtocol {
    func searchBeginEdit()
    func searchSelectCancel()
    func searchString(keyword:String)
}
class CitySearchView: UIView,UISearchBarDelegate {

 
    var searchBar:UISearchBar = UISearchBar()
    var btnCacnel = UIButton()
    weak var delegate:CitySearchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.Hex(hexString: "#f0f1f1")
        searchBar.placeholder = "请输入城市名称或首字母"
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.isTranslucent = true
        searchBar.tintColor = UIColor.Hex(hexString: "#48a1ff")
        addSubview(searchBar)
        
//        searchBar.backgroundImage = UIColor.imageFromColor(UIColor.clearColor(), frame: CGRect(x: 0, y: 0, width: ScreenWidth - 10, height: 40))
        searchBar.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(5)
            make.width.equalTo(ScreenWidth - 10)
            make.height.equalTo(40)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        if searchBar.text?.count == 0 {
            if delegate != nil {
                delegate!.searchBeginEdit()
            }
        } else {
            if delegate != nil {
                delegate!.searchString(keyword: searchBar.text!)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        if delegate != nil {
            delegate!.searchSelectCancel()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if delegate != nil {
            delegate!.searchString(keyword: searchBar.text!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
