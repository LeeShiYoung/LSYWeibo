//
//  UserAccess.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/6.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import ObjectMapper

let userAccess = "userAccess"

class UserAccount: Mappable {
    
    /// 用于调用access_token，接口获取授权后的access token。
    var access_token: String?
    /// access_token的生命周期，单位是秒数。
    var expires_in: NSNumber? {
        didSet{
            expires_Date = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
        }
    }
    /// 当前授权用户的UID。
    var uid:String?
    /// 保存用户过期时间
    var expires_Date: NSDate?
    
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    /// 用户昵称
    var screen_name: String?
    
    // 获取用户信息
    func loadUserInfo(finish: (error: NSError?) -> ()) {
        NetWorkTools.GET_Request("2/users/show.json", parameters: ["access_token": access_token!, "uid": uid!], success: { (result) in
            
            if result["error"] == nil{
                
                self.screen_name = result["screen_name"] as? String
                self.avatar_large = result["avatar_large"] as? String
              
                finish(error: nil)
            }
            
        }) { (error) in
            finish(error: error)
        }
        
    }
    
    // 获取 保存 到本地的用户信息
    static var account: UserAccount?
    class func loadAccount() -> UserAccount?
    {
        if account != nil {
            return account!
        }
        
        let accountJson = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        account = Mapper<UserAccount>().map(accountJson)
        
        if account?.expires_Date?.compare(NSDate()) == NSComparisonResult.OrderedAscending
        {
            // 已经过期
            return nil
        }
        
        return account
    }
    
    // 用户是否登录
    class func userLogin() -> Bool {
        print(UserAccount.loadAccount() != nil)
        return UserAccount.loadAccount() != nil
    }
    
    // 归档
    static let path = "Account.plist".cacheDir()
    func save()
    {
        print(UserAccount.path)
        let accountJson = self.toJSON()
        NSKeyedArchiver.archiveRootObject(accountJson, toFile: UserAccount.path)
    }
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        access_token <- map["access_token"]
        expires_in <- map["expires_in"]
        uid <- map["uid"]
        expires_Date <- map["expires_Date"]
        avatar_large <- map["avatar_large"]
        screen_name <- map["screen_name"]
    } 
}

