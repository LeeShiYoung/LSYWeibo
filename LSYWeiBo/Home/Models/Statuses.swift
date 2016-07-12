 //
//  Statuses.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/9.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage
import ObjectMapper

enum CacheType {
    case netPicSize // 从网络获取图片尺寸
    case dirPicSize // 从本地获取图片尺寸
}

class Statuses: Mappable {
    // 微博创建时间
     var created_at: String?{
        
        didSet{
            let createDate = NSDate.dateWithStr(created_at!)
            create_at_Str = createDate.descDate
        }
    }
    
    // 转换后的 创建时间
    var create_at_Str: String?
    // 时间label宽度
     var create_width: CGFloat = 0.0
    // 微博ID
     var id: Int = 0
    // 微博信息内容
    var text: String?
    // 微博来源
     var source: String?{
        didSet{
            if let str = source {
                
                if str == "" {
                    source_sub = ""
                    return
                }
                let start = (str as NSString).rangeOfString(">").location+1
                let end = (str as NSString).rangeOfString("<", options: NSStringCompareOptions.BackwardsSearch).location - start
                source_sub = (str as NSString).substringWithRange(NSMakeRange(start, end))
            }
        }
    }
    
    // 截取后的 微博来源
    var source_sub: String?
    // 转发微博
     var retweeted_status: Statuses?
    // 用户信息
     var user: Users?
    
    // 配图数组
      var pic_urls: [[String: AnyObject]]? {
        didSet{
            
            pic_URLs = [NSURL]()
            original_URLs = [NSURL]()
            
            for objc in pic_urls! {
                let str = objc["thumbnail_pic"] as! String

                let original = str.stringByReplacingOccurrencesOfString("thumbnail", withString: "large")
                pic_URLs?.append(NSURL(string: str)!)
                original_URLs?.append(NSURL(string: original)!)
            }
        }
    }
    
    // 配图全部URL
     var pic_URLs: [NSURL]?
    
    // 全部大图
     var original_URLs:[NSURL]?
    
    // 图片尺寸
     var cachePic_size: CGSize?
    
    // 图片格式
     var pic_type: String?
    
    // 转发 / 原创 配图
     var statePic_URLs: [NSURL]? {
        return retweeted_status?.pic_URLs != nil ? retweeted_status?.pic_URLs : pic_URLs
    }
    
    // 转发 / 原创 配图 (大图)
     var stateOriginal_URLs: [NSURL]? {
        return retweeted_status?.original_URLs != nil ? retweeted_status?.original_URLs : original_URLs
    }
    
    // 转发数
     var reposts_count: Int = 0
    
    // 评论数
     var comments_count: Int = 0
    
    // 表态数
     var attitudes_count: Int = 0
    
    // text 图文混排的 字符串
    var attributedString: NSAttributedString?
    
    // 获取 微博 数据
    class func loadStatuses(since: Int, max: Int, datas:(statuses: [Statuses]) -> (), field:(error: NSError?) -> ()) {
        
        // 读取缓存数据
        StatusesDB.readStatus(since, max: max) { (statuses, error) in
       
            if statuses.count != 0 {// 有缓存
                
                downLoadCachePictures(statuses, statuses: datas)
                return
            }
            
        // 读取 accessToken
        let accessToken = UserAccount.loadAccount()?.access_token
        var parameters: [String: AnyObject] = ["access_token": accessToken!, "count": 10]
        
        parameters["since_id"] = since
        parameters["max_id"] = max
        
        NetWorkTools.GET_Request("2/statuses/home_timeline.json", parameters: parameters, success: { (result) in
  
            let modelArr = Mapper<Statuses>().mapArray(result["statuses"])
            if let modelArr = modelArr {
            // 缓存数据
                StatusesDB.seveStatus(modelArr)
                // 获取图片尺寸
                downLoadCachePictures(modelArr, statuses: datas)
            } else {
                
                field(error: nil)
            }
            
        }) { (error) in
            
            field(error: error)
            }
        }
    }
    
    // 缓存 配图尺寸
    private class func downLoadCachePictures(statues: [Statuses], statuses:(statuses: [Statuses]) -> ()) {
        
        if statues.count == 0 {
            statuses(statuses: statues)
            return
        }
        
        let group = dispatch_group_create()
        for stat in statues {
            // 原创微博内容(图文)
            if let statText = stat.text {
                stat.attributedString = EmoticonPackage.emoticonAttributedString(statText)
            }
            // 转发微博内容(图文)
            if let retweerStat = stat.retweeted_status {
                let name = retweerStat.user?.name ?? ""
                let text = retweerStat.text ?? ""
                retweerStat.attributedString = EmoticonPackage.emoticonAttributedString("@" + name + ": " + text)
            }
            
            guard let _ = stat.pic_URLs else {
                // 进入下一循环
                continue
            }
            
            let URLS = stat.statePic_URLs
            for url in URLS! {
                dispatch_group_enter(group)
                
                // 从本地获取图片 -> 得到尺寸
                let diskClourse = {
                    (diskImage: UIImage) -> Void in
                    stat.cachePic_size = diskImage.size
                    stat.pic_type = url.pathExtension;
                    dispatch_group_leave(group)
                }
                
                // 从网络获取图片尺寸
                let netClourse = {
                    (url: NSURL) -> Void in
                    /*ImageScout.scoutManager.scoutImageWithURL(url, completion: { (error, size, type) in
                        
                        stat.cachePic_size = size
                        stat.pic_type = type.rawValue
                        dispatch_group_leave(group)
                    })*/
                    SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, error, _, _, _) in
                        stat.cachePic_size = image.size
                        dispatch_group_leave(group)
                    })
                }
                
                let diskImage = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(url.absoluteString)
                
            diskImage != nil ? (diskClourse(diskImage)) : (netClourse(url))
           }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            // 下载完成
            print("获取图片尺寸完成")
            statuses(statuses: statues)
        }
    }

    /***********ObjectMapper****************/
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        created_at <- map["created_at"]
        id <- map["id"]
        text <- map["text"]
        source <- map["source"]
        retweeted_status <- map["retweeted_status"]
        user <- map["user"]
        reposts_count <- map["reposts_count"]
        comments_count <- map["comments_count"]
        attitudes_count <- map["attitudes_count"]
        pic_urls <- map["pic_urls"]
    }
    
}
