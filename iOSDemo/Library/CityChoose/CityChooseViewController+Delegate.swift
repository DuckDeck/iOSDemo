//
//  CityChooseViewController+Delegate.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

extension CityChooseViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = arrSectionTitle?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        if arrCities != nil && arrSectionTitle != nil {
            let title = arrSectionTitle![section]
            return arrCities![title.lowercased()]!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if arrSectionTitle == nil{
            return nil
        }
        var head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if head == nil {
            head = UITableViewHeaderFooterView(reuseIdentifier: "header")
            let lblTitle = UILabel(frame:  CGRect(x: 10, y: 0, w: 80, h: 25)).text(text: "").color(color: UIColor.Hex(hexString: "#999999")).bgColor(color: UIColor.Hex(hexString: "#f0f1f1"))
            lblTitle.tag = 1
            lblTitle.font = UIFont.systemFont(ofSize: 13)
            head?.contentView.addSubview(lblTitle)
        }
        head?.contentView.backgroundColor = UIColor.Hex(hexString: "#f0f1f1")
        let lbl = head?.viewWithTag(1) as! UILabel
        lbl.text = arrSectionTitle![section].uppercased()
        return head!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 56
        } else if indexPath.section == 1 {
            return 145
        }
        return 38
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "locateCell" ) as? locationTableViewCell
            if cell == nil {
                cell = locationTableViewCell(style: .default, reuseIdentifier: "locateCell")
                cell?.locateBlock = {[ weak self] (status:Int,button:UIButton) in
                    if status == 2 {
                    }
                    if status == 1 {
                        if let city = self?.currentLocateCity {
                            self?.chooseCity(city: city)
                        }
                    }
                }
                cell?.selectionStyle = .none
            }
            return cell!
        }
        if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cityCell") as? CityTableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cityCell")
                cell?.cityChooseBlock = {[weak self](city:AddressInfo) in
                    self?.chooseCity(city: city)
                }
                cell?.selectionStyle = .none
            }
            cell?.info = arrHotCity
            return cell!
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            let title = arrSectionTitle![indexPath.section]
            let pyCity = arrCities![title.lowercased()]
            cell!.textLabel?.text = pyCity![indexPath.row].city
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell!.textLabel?.textColor = UIColor.Hex(hexString: "#bbbbbb")
            return cell!
        }
    }
    
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        switch cityChooseStatus {
        case .Normal:
            return arrIndexCity
        case .Searching:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index == 0 {
            tableView.setContentOffset(CGPoint(), animated: true)
            return -1
        } else {
            return index + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if indexPath.section > 1 {
            let city = arrCities![arrSectionTitle![indexPath.section].lowercased()]![indexPath.row]
            chooseCity(city: city)
        }
    }
}



extension CityChooseViewController :CitySearchDelegate,CitySearchResultDelegate{
    func searchBeginEdit() {
        view.addSubview(vBlackMask)
        cityChooseStatus = .Searching
        tbCity.reloadSectionIndexTitles()
    }
    
    func searchSelectCancel() {
        cityChooseStatus = .Normal
        tbCity.reloadSectionIndexTitles()
        vSearchResult?.arrCity = nil
        vSearchResult?.tbCity.reloadData()
        vSearchResult?.removeFromSuperview()
    }
    
    func searchString(keyword: String) {
        vSearchResult?.tbCity.removeEmptyPage(withIdentity: "CitySearch")
        if keyword.length == 0 {
            vSearchResult?.arrCity?.removeAll()
            vSearchResult?.tbCity.reloadData()
            return
        }
        //这里不能输入, 用与颪
        if !(keyword =~ "[a-z]|[A-Z]|^[\\u4E00-\\u9FFF]+$") {
            vSearchResult?.tbCity.showEmptyPage(withIdentity: "CitySearch")
            vSearchResult?.arrCity?.removeAll()
            vSearchResult?.tbCity.reloadData()
            return
        }
        let arrResult:[AddressInfo]?
        if isLetter(str: keyword) {
            arrResult = CityDB.sharedInstance.searchCityWithLetter(letter: keyword)
        } else {
            arrResult = CityDB.sharedInstance.searchWithChinese(str: keyword)
        }
        if arrResult!.count == 0 {
            vSearchResult?.tbCity.showEmptyPage(withIdentity: "CitySearch")
            vSearchResult?.arrCity?.removeAll()
            vSearchResult?.tbCity.reloadData()
            return
        }
        
        view.addSubview(vSearchResult!)
        vSearchResult?.arrCity = arrResult
        vSearchResult?.tbCity.reloadData()
    }
    
    func didScroll() {
        vSearch.searchBar.resignFirstResponder()
    }
    
    func didSelectCity(city: AddressInfo) {
        chooseCity(city: city)
    }
    
    func isLetter(str:String) -> Bool {
        return regexTool("^[A-Za-z]+$").match(input: str)
    }
}



class locationTableViewCell: UITableViewCell {
    var btnLocate = UIButton()
    var locateBlock:((_ status:Int,_ sender:UIButton)->Void)?
    func setLocateState(status:String,statueCode:Int) {
        switch statueCode {
        case 0:
            btnLocate.setTitle("正在定位中...", for: .normal)
            btnLocate.tag = 0
        case 1:
            btnLocate.setTitle(status, for: .normal)
            btnLocate.tag = 1
        case 2:
            btnLocate.setTitle("定位失败，请重新再试", for: .normal)
            btnLocate.tag = 2
        case 3:
            btnLocate.setTitle("定位不可用", for: .normal)
            btnLocate.tag = 3
        default:
            btnLocate.setTitle("正在定位中...", for: .normal)
            btnLocate.tag = 0
        }
        
        var width:CGFloat = 100
        if width < (ScreenWidth - 75) / 3 {
            width = (ScreenWidth - 75) / 3
        } else {
            width = width + 20
        }
        //btnLocate.setBgColor(UIColor.whiteColor(), highlightedBgColor: coloreeeff0, size: CGSizeMake(width, 34))
        btnLocate.snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.Hex(hexString: "#f0f1f1")
        btnLocate.backgroundColor = UIColor.white
        btnLocate.layer.borderColor = UIColor.Hex(hexString: "#e6e6e6").cgColor
        btnLocate.layer.borderWidth = lineHeight
        btnLocate.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btnLocate.setTitleColor(UIColor.Hex(hexString: "#bbbbbb"), for: .normal)
        btnLocate.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        addSubview(btnLocate)
        
        btnLocate.snp.makeConstraints{ (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.height.equalTo(34)
        }
        setLocateState(status: "", statueCode: 0)
    }
    
    func btnClick(sender:UIButton) {
        if sender.tag == 2 {
            setLocateState(status: "", statueCode: 0)
        }
        if let blk = locateBlock {
            blk(sender.tag, sender)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
