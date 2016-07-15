//
//  Comments.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/7/13.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import ObjectMapper

class Comments: Mappable {

    // 回复时间
    var created_at: String? {
        didSet{
            let createDate = NSDate.dateWithStr(created_at!)
            created_at_Str = createDate.descDate
        }
    }
    // 评论id
    var id: Int = 0
    // 评论的内容
    var text: String?
    // 用户
    var user: Users?
    //  处理后的时间
    var created_at_Str: String?
    // 评论内容的图文
    var attributedText: NSAttributedString?
    
    // 请求评论列表
    class func loadComments(statuesID: Int, finish: (comments: [Comments]) -> (), field: (error: NSError?) -> ()) {
  
        let accessToken = UserAccount.loadAccount()?.access_token
        let parameters: [String: AnyObject] = ["access_token": accessToken!, "id": statuesID]
        
        NetWorkTools.GET_Request("comments/show.json", parameters: parameters, success: { (result) in
          
            let cs = Mapper<Comments>().mapArray(result["comments"])
            
            for c in cs! {
                c.attributedText = EmoticonPackage.emoticonAttributedString(c.text!)
            }
            
            finish(comments: cs!)
            }) { (error) in
              field(error: error)
        }
    }
    
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        created_at <- map["created_at"]
        id <- map["id"]
        text <- map["text"]
        user <- map["user"]
    }
}

