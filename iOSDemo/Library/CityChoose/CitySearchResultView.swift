
//
//  CitySearchResultView.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
protocol CitySearchResultDelegate:NSObjectProtocol {
    func didScroll()
    func didSelectCity(city:AddressInfo)
}
class CitySearchResultView: UIView ,UITableViewDelegate,UITableViewDataSource{

    var arrCity:[AddressInfo]?
    var tbCity = UITableView()
    weak var delegate:CitySearchResultDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        tbCity.frame = self.bounds
        tbCity.delegate = self
        tbCity.dataSource = self
        tbCity.tableFooterView = UIView()
        tbCity.backgroundColor = UIColor.Hex(hexString: "#f0f1f1")
//        let str = NSMutableAttributedString(string: "抱歉，未找到相关城市，可尝试修改后重试")
//        str.addAttributes([NSAttributedStringKey.foregroundColor:UIColor.Hex(hexString: "#999999"),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, str.length))
//        tbCity.setEmptyInfo("CitySearch", emptyMessage: str, imgUrl: "empty_city_search_gray", imageYScale: 0.16, imageHeight: 60, messageDistanseFromImage: 15, messageHeight: 18)
        addSubview(tbCity)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = arrCity?.count {
            return count
        }
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = arrCity![indexPath.row]
        if let del = delegate {
            del.didSelectCity(city: city)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrCity![indexPath.row].city
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.textLabel?.textColor = UIColor.Hex(hexString: "#999999")
        return cell!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let del = delegate {
            del.didScroll()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
