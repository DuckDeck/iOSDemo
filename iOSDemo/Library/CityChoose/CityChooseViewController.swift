//
//  CityChooseViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import CoreLocation
enum CityChooseStatus:Int {
    case Normal=0,Searching
}
class CityChooseViewController: UIViewController {

    var cityChooseStatus = CityChooseStatus.Normal
    var vSearch = CitySearchView()
    var tbCity = UITableView()
    var vBlackMask = UIView()
    var arrSectionTitle:[String]?
    var arrIndexCity:[String]?
    var arrCities:[String:[AddressInfo]]?
    var arrCurrentCity:[String]?
    
    var arrHotCity = [AddressInfo]()
    var vSearchResult:CitySearchResultView?
    var locationManager:CLLocationManager? = nil
    var geoCode:CLGeocoder?
    var currentLocateCity:AddressInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initView()
      
    }

    func initData()  {
        arrCities = CityDB.sharedInstance.citiesToPinyinGroupCity(cities: CityDB.sharedInstance.allCities())
        if arrCities!.count <= 0 {
            GrandCue.showLoading()
            AddressInfo.saveCIty(complete: { (result) in
                if  !handleResult(result: result){
                    return
                }
                self.fillData()
                
            })
        } else {
            fillData()
        }
    }
    
    func fillData() {
        if arrCities!.count <= 0 {
            arrCities = CityDB.sharedInstance.citiesToPinyinGroupCity(cities: CityDB.sharedInstance.allCities())
        }
        arrIndexCity = CityDB.sharedInstance.allFirstLetter().sorted().map(){$0.uppercased()}
        arrSectionTitle = arrIndexCity!
        arrIndexCity?.insert("热门", at: 0)
        arrSectionTitle?.insert("热门城市", at: 0)
        var city = AddressInfo()
        city.areaId = 1
        city.city = "北京市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 3
        city.city = "天津市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 75
        city.city = "上海市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 200
        city.city = "广州市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 202
        city.city = "深圳市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 238
        city.city = "重庆市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 172
        city.city = "武汉市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 241
        city.city = "成都市"
        arrHotCity.append(city)
        city = AddressInfo()
        city.areaId = 90
        city.city = "杭州市"
        arrHotCity.append(city)
        arrSectionTitle?.insert("定位城市", at: 0)
        //        tbCity.reloadData()
    }
    
    
    
    func initView() {
        
        view.backgroundColor = UIColor.white
        
        navigationItem.title = "选择城市"
        
        vSearch.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 20, height: 54)
        vSearch.delegate = self
        vBlackMask.backgroundColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 0.3)
        vBlackMask.alpha = 0.3
        vBlackMask.isUserInteractionEnabled = true
        
        vBlackMask.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CityChooseViewController.blackMaskTap(gesture:))))
        view.addSubview(vBlackMask)
        
        //
        tbCity.delegate = self
        tbCity.dataSource = self
        tbCity.tableHeaderView = vSearch
        tbCity.showsVerticalScrollIndicator = false
        tbCity.sectionIndexColor = UIColor.blue
        tbCity.sectionIndexBackgroundColor = UIColor.clear
        tbCity.tableFooterView = UIView()
        view.addSubview(tbCity)
        
        
        if !Auth.isAuthLocation() {
            setLocateCity(city: nil, status: 3)
        }
        else{
            if let address = APPAreaInfo.Value{
                geoCode = CLGeocoder()
                let lo = CLLocation(latitude: address.latitude, longitude: address.longitude)
                geoCode?.reverseGeocodeLocation(lo, completionHandler: { [weak self](places, err) in
                    if err != nil || places == nil{
                        GrandCue.toast(err!.localizedDescription)
                        return
                    }
                    if let one = places!.first?.locality{
                        address.city = one
                        APPAreaInfo.Value = address
                        let city = AddressInfo()
                        city.city = address.city
                        self?.setLocateCity(city: city, status: 1)
                    }
                })
            }
        }
        
        
        vSearchResult = CitySearchResultView(frame: CGRect(x: 0, y: NavigationBarHeight + 50, width: ScreenWidth, height: ScreenHeight - NavigationBarHeight - 50))
        vSearchResult?.delegate = self
        vBlackMask.frame = CGRect(x: 0, y: NavigationBarHeight + 50, width: ScreenWidth, height: ScreenHeight - 50 - NavigationBarHeight)
        
        tbCity.frame = CGRect(x: 0, y: NavigationBarHeight, width: ScreenWidth, height: ScreenHeight - NavigationBarHeight)
        

    }
    
    @objc func blackMaskTap(gesture:UITapGestureRecognizer) {
        searchSelectCancel()
        //光这样没用
    }
    
    func setLocateCity(city:AddressInfo?,status:Int = 3) {
        let path = IndexPath(item: 0, section: 0 )
        if let cell = tbCity.cellForRow(at: path) as? locationTableViewCell {
            if let c = city {
                cell.setLocateState(status: c.city, statueCode: status)
            } else {
                cell.setLocateState(status: "", statueCode: status)
            }
        }
    }
    
    func chooseCity(city:AddressInfo) {
        let dbCity = CityDB.sharedInstance.cityFromId(id: city.areaId)
        if dbCity.latitude <= 0{
            AddressInfo.getCoorFromCity(city: dbCity.city, complete: { (result) in
                if !handleResult(result: result){
                    return
                }
                let city = result.data! as! AddressInfo
                dbCity.latitude = city.latitude
                dbCity.longitude = city.longitude
                _ = CityDB.sharedInstance.addCity(city: dbCity)
                GrandCue.toast("你选择国\(dbCity.city)")
                self.navigationController?.popViewController(animated: true)
            })
        }
        else{
          
            navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
