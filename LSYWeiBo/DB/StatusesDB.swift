//
//  StatusesDB.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/15.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import FMDB
import ObjectMapper

class StatusesDB: NSObject {
    
    private static var queue: FMDatabaseQueue?
    override class func initialize() {
        let path = "LSYWeiBo.sqlite".cacheDir()
        queue = FMDatabaseQueue(path: path)
        print(path)
        // 建表
        queue?.inDatabase({ (db) in
            do {
                try db.executeUpdate("CREATE TABLE IF NOT EXISTS t_status (id integer PRIMARY KEY, status blob NOT NULL, statusesID integer NOT NULL, attitudes boolean);", values: nil)
            } catch {
                print("建表error: \(error)")
            }
        })
    }
    
    //MARK: - 保存微博
    class func seveStatus(stats: [Statuses]) {
        if stats.count == 0 {
            return
        }
  
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for status in stats {
                
                let statusJson = status.toJSON()
                let data = NSKeyedArchiver.archivedDataWithRootObject(statusJson)
                queue?.inTransaction({ (db, back) in
                    do {
                        try db.executeUpdate("INSERT OR REPLACE INTO t_status (status, statusesID, attitudes) VALUES (?,?,?)", values: [data, status.id, false])
                    } catch {
                        // 失败就回滚
                        back.memory = true
                        print("保存error: \(error)")
                    }
                })
            }
        }
    }
    
    enum DBError: ErrorType {
        case NonData, SQLError
    }
    //MARK: - 读取微博
    class func readStatus(since: Int, max: Int) throws -> [Statuses] {
        
        var sqlError: DBError?
        var sql = "SELECT * FROM t_status "
        if since > 0 {
            sql += "WHERE statusesID > \(since) "
        } else if max > 0{
            sql += "WHERE statusesID < \(max) "
        }
        
        sql += "ORDER BY statusesID DESC "
        sql += "LIMIT 10;"
        
        var statuses = [Statuses]()

            queue?.inDatabase({ (db) in
                do {
                    let result = try db.executeQuery(sql, values: nil)
                    while result.next() {
                        
                        let data = result.dataForColumn("status")
                        let attitudes = result.boolForColumn("attitudes")
                        let statusJson = NSKeyedUnarchiver.unarchiveObjectWithData(data)
                        let status = Mapper<Statuses>().map(statusJson)
                        status?.attitudes = attitudes
                        if let status = status {
                            statuses.append(status)
                        }
                    }
                } catch {
                    print("保存error: \(error)")
                    sqlError = DBError.SQLError
                }
            })
        if sqlError != nil {
            throw DBError.SQLError
        }
        
        if statuses.count == 0 {
            throw DBError.NonData
        }
        return statuses
    }
    
    // 更新
    class func upDateStatuses(status: Statuses, newAttitudes: Bool) {
        
        queue?.inDatabase({ (db) in
            do {
                let statusJson = status.toJSON()
                let data = NSKeyedArchiver.archivedDataWithRootObject(statusJson)
                try db.executeUpdate("update t_status set attitudes = ?, status = ? where statusesID = ?;", values: [newAttitudes, data, status.id])
            } catch {
                print("更新error: \(error)")
            }
        })
    }
}
