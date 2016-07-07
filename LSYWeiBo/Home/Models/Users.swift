//
//  Users.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/10.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import ObjectMapper

class Users: Mappable {

    // 用户ID
    var id: Int = 0
    // 友好显示名称
    var name: String?
    // 用户头像地址（中图），50×50像素
    var profile_image_url: String? {
        didSet{
            imageURL = NSURL(string: profile_image_url!)
        }
    }
    // 用于保存用户头像的URL
    var imageURL: NSURL?
    
    // 时候是认证, true是, false不是
    var verified: Bool = false
    // 用户的认证类型
    var verified_type: Int = -1{
        didSet{
            switch verified_type
            {
            case 0:
                acatarImage = UIImage(named: "avatar_vip")
            case 2, 3, 5:
                acatarImage = UIImage(named: "avatar_enterprise_vip")
            case 220:
                acatarImage = UIImage(named: "avatar_grassroot")
            default:
                acatarImage = nil
            }
        }
    }
    
    // 认证image
    var acatarImage: UIImage?
    
    // 会员
    var mbrank: Int = 0
        {
        didSet{
            if mbrank > 0 && mbrank < 7
            {
                mbrankImage = UIImage(named: "common_icon_membership_level\(mbrank)")
                mbrank_Color = UIColor.orangeColor()
            }
        }
    }
    
    var mbrankImage: UIImage?

    // 会员名 高亮
    var mbrank_Color = UIColor.blackColor()
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        profile_image_url <- map["profile_image_url"]
        verified <- map["verified"]
        verified_type <- map["verified_type"]
        mbrank <- map["mbrank"]
    }
}
