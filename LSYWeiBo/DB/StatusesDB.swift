//
//  StatusesDB.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/15.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import FMDB

class StatusesDB: NSObject {
    
    static var queue: FMDatabaseQueue?
    override class func initialize() {
        let path = "LSYWeiBo.sqlite".cacheDir()
        queue = FMDatabaseQueue(path: path)
        print(path)
        // 建表
        queue?.inDatabase({ (db) in
            do {
                try db.executeUpdate("CREATE TABLE IF NOT EXISTS t_status (id integer PRIMARY KEY, status blob NOT NULL, statusesID integer NOT NULL);", values: nil)
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
        
        // 忽略属性
        Statuses.mj_setupIgnoredCodingPropertyNames { () -> [AnyObject]! in
            return ["statePic_URLs", "stateOriginal_URLs"]
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for status in stats {
                
                let data = NSKeyedArchiver.archivedDataWithRootObject(status)
                queue?.inTransaction({ (db, back) in
                    do {
                        try db.executeUpdate("INSERT OR REPLACE INTO t_status (status, statusesID) VALUES (?,?)", values: [data, status.id])
                    } catch {
                        // 失败就回滚
                        back.memory = true
                        print("保存error: \(error)")
                    }
                })
            }
        }
    }
    
    //MARK: - 读取微博
    class func readStatus(since: Int, max: Int, finsih: (statuses: [Statuses], error: ErrorType?) -> ()) {
        var sql = "SELECT * FROM t_status "
        if since > 0 {
            sql += "WHERE statusesID > \(since) "
        } else if max > 0{
            sql += "WHERE statusesID < \(max) "
        }
        
        sql += "ORDER BY statusesID DESC "
        sql += "LIMIT 10;"
        
        var statuses = [Statuses]()
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            queue?.inDatabase({ (db) in
                do {
                    let result = try db.executeQuery(sql, values: nil)
                    while result.next() {
                        
                        let data = result.dataForColumn("status")
                        let status = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Statuses
                        statuses.append(status)
                    }
                    finsih(statuses: statuses, error: nil)
                } catch {
                    
                    print("保存error: \(error)")
                    finsih(statuses: statuses, error: error)
                }
            })
//        }
    }
}
