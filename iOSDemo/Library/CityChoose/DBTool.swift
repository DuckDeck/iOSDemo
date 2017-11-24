//
//  DBTool.swift
//  EasyCollection
//
//  Created by Stan Hu on 22/11/2017.
//  Copyright © 2017 Dafy. All rights reserved.
//

import FMDB

class DBTool {

    var dbQueue:FMDatabaseQueue
    init(){
        dbQueue = DBManager.sharedInstance.commonQueue
    }
    func createTable(tbName:String,sql:String) -> Bool {
        var flag = true
        dbQueue.inDatabase { (db) in
            if  !db.tableExists(tbName){
                flag = db.executeUpdate(sql, withArgumentsIn: [])
            }
        }
        return flag
    }
    
    func excuteSql(sql:String,para:[Any]) -> Bool {
        var flag = true
        dbQueue.inDatabase { (db) in

            flag = db.executeUpdate(sql, withArgumentsIn: para)
        }
        return flag
    }
    
    func excuteSql(sql:String,paraDict:[NSObject: AnyObject]) -> Bool {
        var flag = true
        dbQueue.inDatabase { (db) in

            flag = db.executeUpdate(sql, withParameterDictionary: paraDict)
        }
        return flag
    }
    
    
    
    func excuteSql(sql:String,block:@escaping (_ result:FMResultSet)->Void) {
        dbQueue.inDatabase { (db) in
        
            let result = db.executeQuery(sql, withArgumentsIn: [])
            block(result!)
        }
    }
    
    func excuteSql(sql:String)  -> Bool{
        var flag = false
        dbQueue.inDatabase { (db) in

            flag = db.executeUpdate(sql, withArgumentsIn: [])
        }
        return flag
    }
    

}

class DBManager {
    var commonQueue:FMDatabaseQueue
    // var messageQueue:FMDatabaseQueue
    init() {
        var pathDbCommon = "\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!)/DB/"
        if !FileManager.default.fileExists(atPath: pathDbCommon){
            do {
                try   FileManager.default.createDirectory(atPath: pathDbCommon, withIntermediateDirectories: true, attributes: nil)
            }
            catch (_){
            }
        }
        
        pathDbCommon = "\(pathDbCommon)common.sqlite3"
        commonQueue =  FMDatabaseQueue(path: pathDbCommon)!
    }
    static  let sharedInstance = DBManager()
}
