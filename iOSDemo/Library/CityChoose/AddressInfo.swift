//
//  AddressInfo.swift
//  iOSDemo
//
//  Created by Stan Hu on 24/11/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//


import UIKit
import SwiftyJSON
import CoreLocation

enum AreaLevel:Int,Codable {
    case Country=0,Provice,City,District,Street
}
struct AddressInfo:Codable {
     
    var areaId = 0
    var province = ""
    var city = ""
    var district = ""
    var street = ""
    var areaLevel = AreaLevel.City
    var latitude = 0.0
    var latitudeStr:String{
        set{
            latitude = Double(newValue)!
        }
        get{
            return String(latitude)
        }
    }
    var longitude = 0.0
    var longitudeStr:String{
        set{
            longitude = Double(newValue)!
        }
        get{
            return String(longitude)
        }
    }
    var  coordinate : CLLocationCoordinate2D{
        get{
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var cityPinYIn = ""
    var cityFirstLetterPinYIn = ""
    var cityAllLetterPinyin = ""
    
    
    
    static func saveCIty(complete:@escaping completed){
        var result = ResultInfo()
        let path = Bundle.main.path(forResource: "city", ofType: "json")
        if path == nil {
            result.code = -1
            complete(result)
            return
        }
        let file = FileManager.default.contents(atPath: path!)
        if file == nil{
            result.code = -1
            complete(result)
            return
        }
        let json = try! JSONSerialization.jsonObject(with: file!, options: .allowFragments)
        let js = JSON(json).arrayValue
        var cities = [AddressInfo]()
        var i = 0
        for j in js{
            var city = AddressInfo()
            city.areaId = j["id"].intValue
            city.city = j["city"].stringValue
            if city.city == "市辖区" || city.city == "县"{
                city.city = j["province"].stringValue + city.city
            }
            city.cityPinYIn = Tool.ChineseToPinyin(chinese: city.city).lowercased()
            city.cityFirstLetterPinYIn = city.cityPinYIn.substring(from: 0, length: 1)
            let letters = city.cityPinYIn.components(separatedBy: " ")
            var allPy = ""
            for c in letters{
                allPy += c.substring(from: 0, length: 1)
            }
            city.cityAllLetterPinyin = allPy
            i += 1
            cities.append(city)
            _ = CityDB.sharedInstance.addCity(city: city)
        }
        result.data = cities
        complete(result)
    }
    
    
    static func getCoorFromCity(city:String,complete:@escaping completed){
        var result = ResultInfo()
        let url = "http://api.map.baidu.com/geocoder/v2/?&output=json&ak=GmgLlkoB8sqMU3HFHuztPezuo2Zpp1mi&address=" + city.urlEncoded()

        HttpClient.get(url).completion  { (data, err) in
            if data == nil || err != nil{
                result.code = -1
                complete(result)
                return
            }
            let js = JSON(data!)
            if js["status"].intValue != 0{
                result.code = js["status"].intValue
                complete(result)
                return
            }
            var address = AddressInfo()
            address.city = city
            address.latitude = js["result"]["location"]["lat"].doubleValue
            address.longitude = js["result"]["location"]["lng"].doubleValue
            result.data = address
            complete(result)
        }
        
        
    }
    
    
}

