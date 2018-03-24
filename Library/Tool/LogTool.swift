//
//  LogTool.swift
//  iOSDemo
//
//  Created by Stan Hu on 23/03/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import FMDB
//IMEI and IDFA, latitude,longtitude , city,  version ,phone,  do not need store in the sqlite ,it update in the realtime
// logId AUTOINCREMENT
let Log_Db_Name = "log"
let Sql_Create_Log_Table = "CREATE TABLE IF NOT EXISTS %@ (logId INTEGER DEFAULT (0) ,  logTime INTEGER, logText TEXT,  isUpload INTEGER, PRIMARY KEY(logId),  UNIQUE(logId))"
// isUpload 0 is not 1 is upload
let Sql_Add_Log = "REPLACE INTO %@ (logId , logTime , logText,isUpload) values (null,?,?,0)"
let Sql_Select_Not_Upload = "select * from %@ where isUpload = 0"
let Sql_Clear = "delete from  %@ where logTime < %d"

class LogTool:DBTool {

    static let sharedInstance = LogTool()
    override init() {
        super.init()
        let ok = createTable()
        if !ok {
            Log(message: "DB create fail city表创建失败")
        }
    }
    
    func createTable() -> Bool {
        let sql = String(format: Sql_Create_Log_Table, Log_Db_Name)
        return createTable(tbName: Log_Db_Name, sql: sql)
    }
    
    func addLog(log:String) -> Bool {
        let sql = String(format: Sql_Add_Log, Log_Db_Name)
        let arr:[Any] = [DateTime.now.ticks/1000,log]
        return excuteSql(sql: sql, para: arr)
    }
    
    func deleteLog(time:Int) ->Bool {
        let sql = String(format: Sql_Clear, Log_Db_Name,time)
        return excuteSql(sql: sql)
    }
    
    func getNotUploadLog() ->  [LogInfo]{
         let sql = String(format: Sql_Select_Not_Upload,Log_Db_Name)
        var arrLog = [LogInfo]()
        weak var weakSelf = self
        excuteSql(sql: sql) { (result) in
            while result.next() {
                let log = weakSelf!.dbToLog(reSet: result)
                arrLog.append(log)
            }
            result.close()
        }
        return arrLog
    }
    
    func dbToLog(reSet:FMResultSet) -> LogInfo {
        var log = LogInfo()
        log.id = Int(reSet.int(forColumn: "logId"))
        log.time = Int(reSet.int(forColumn: "logTime"))
        log.logText = reSet.string(forColumn: "logText")!
        return log
    }
    
}
