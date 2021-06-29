//
//  CityDB.swift
//  EasyCollection
//
//  Created by Stan Hu on 22/11/2017.
//  Copyright © 2017 Dafy. All rights reserved.
//
let City_Db_Name = "city"
let  Sql_Create_City_Table = "CREATE TABLE IF NOT EXISTS %@ (cityId INTEGER DEFAULT (0),  cityName TEXT,  cityPinyin TEXT, cityFirstLetterPinyin TEXT, latitude DOUBLE, longitude DOUBLE, cityAllLetterPinyin TEXT,  PRIMARY KEY(cityId),  UNIQUE(cityId))"
let Sql_Add_City = "REPLACE INTO %@ (cityId , cityName , cityPinyin, cityFirstLetterPinyin ,cityAllLetterPinyin,latitude,longitude) values (?,?,?,?,?,?,?)"
let Sql_Select_All_City = "select * from %@"
let Sql_Select_First_CityPinyin = "select cityFirstLetterPinyin from %@ group by cityFirstLetterPinyin"


class CityDB: DBTool {
    static let sharedInstance = CityDB()
    override init() {
        super.init()
        let ok = createTable()
        if !ok {
            Log(message: "DB create fail city表创建失败")
        }
    }
    
    func createTable() -> Bool {
        let sql = String(format: Sql_Create_City_Table, City_Db_Name)
        return createTable(tbName: City_Db_Name, sql: sql)
    }
    
    func addCity(city:AddressInfo) -> Bool {
        let sql = String(format: Sql_Add_City, City_Db_Name)
        let arr:[Any] = [city.areaId,city.city,city.cityPinYIn,city.cityFirstLetterPinYIn,city.cityAllLetterPinyin,city.latitude,city.longitude]
        return excuteSql(sql: sql, para: arr)
        
    }
    
    func allCities() -> [AddressInfo] {
        let sql = String(format: Sql_Select_All_City, City_Db_Name)
        var arrCity = [AddressInfo]()
        weak var weakSelf = self
        excuteSql(sql: sql) { (result) in
            while result.next() {
                let city = weakSelf!.dbToCity(reSet: result)
                arrCity.append(city)
            }
            result.close()
        }
        return arrCity
    }
    
    func dbToCity(reSet:FMResultSet) -> AddressInfo {
        var city = AddressInfo()
        city.areaId = Int(reSet.int(forColumn: "cityId"))
        city.city = reSet.string(forColumn: "cityName")!
        city.cityPinYIn = reSet.string(forColumn: "cityPinyin")!
        city.cityFirstLetterPinYIn = reSet.string(forColumn: "cityFirstLetterPinyin")!
        city.cityAllLetterPinyin = reSet.string(forColumn: "cityAllLetterPinyin")!
        city.longitude = reSet.double(forColumn: "longitude")
        city.latitude = reSet.double(forColumn: "latitude")
        return city
    }
    
    func citiesToPinyinGroupCity(cities:[AddressInfo]) -> [String:[AddressInfo]] {
        var result = [String:[AddressInfo]]()
        for c in cities {
            if !result.keys.contains(c.cityFirstLetterPinYIn) {
                result[c.cityFirstLetterPinYIn] = [AddressInfo]()
            }
            result[c.cityFirstLetterPinYIn]?.append(c)
        }
        return result
    }
    
    func allFirstLetter() -> [String] {
        var pinyin = [String]()
        let sql = String(format: Sql_Select_First_CityPinyin, City_Db_Name)
        excuteSql(sql: sql) { (result) in
            while result.next() {
                pinyin.append(result.string(forColumn: "cityFirstLetterPinyin")!)
            }
            result.close()
        }
        return pinyin
    }
    
    func searchCity(city:String) -> [AddressInfo] {
        var arrCity = [AddressInfo]()
        let sql = "select * from city where cityName like '%\(city)%' "
        weak var weakSelf = self
        excuteSql(sql: sql) { (result) in
            while result.next() {
                let city = weakSelf!.dbToCity(reSet: result)
                arrCity.append(city)
            }
            result.close()
        }
        return arrCity
    }
    
    func searchCityWithLetter(letter:String) -> [AddressInfo] {
        var arrCity = [AddressInfo]()
        let sql = "select * from city where cityAllLetterPinyin like '\(letter)%' "
        weak var weakSelf = self
        excuteSql(sql: sql) { (result) in
            while result.next() {
                let city = weakSelf!.dbToCity(reSet: result)
                arrCity.append(city)
            }
            result.close()
        }
        return arrCity
    }
    
    func searchWithChinese(str:String) -> [AddressInfo] {
        var arrCity = [AddressInfo]()
        let sql = "select * from city where cityName like '%\(str)%' "
        weak var weakSelf = self
        excuteSql(sql: sql) { (result) in
            while result.next() {
                let city = weakSelf!.dbToCity(reSet: result)
                arrCity.append(city)
            }
            result.close()
        }
        return arrCity
    }
    
    func cityFromId(id:Int) -> AddressInfo {
        let sql = "select * from city where cityId = \(id) "
        var city:AddressInfo?
        weak var weakSelf = self
        excuteSql(sql: sql) { (result) in
            while result.next() {
                city = weakSelf!.dbToCity(reSet: result)
            }
            result.close()
        }
        if city != nil {
            return city!
        }
        return AddressInfo()
    }
    
    func clearTable() {
        let sql = "delete from  \(City_Db_Name)"
        _ = excuteSql(sql: sql, para: [])
    }

}
