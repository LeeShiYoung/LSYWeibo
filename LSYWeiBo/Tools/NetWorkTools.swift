//
//  NetWorkTools.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let baseURL = "https://api.weibo.com/"
class NetWorkTools: NSObject {
    
    //GET
    class func GET_Request(http: String, parameters: [String: AnyObject]?, success:(result: [String: AnyObject]) -> (), filed:(error:NSError?) -> ()) {
        
        let urlStr = baseURL + http
        Alamofire.request(.GET, urlStr, parameters: parameters)
            .response { request, response, data, error in
                
                let json = JSON(data: data!).dictionaryObject
                if let json = json {
                    success(result: json)
                } else {
                    
                    
                    filed(error: error)
                }

        }
    }
    
    // POST
    class func POST_Request(http: String, parameters: [String: AnyObject], success:(result: [String: AnyObject]) -> (), filed:(error:NSError?) -> ()) {
        
        let urlStr = baseURL + http
        Alamofire.request(.POST, urlStr, parameters: parameters)
            .response { request, response, data, error in
                
                let json = JSON(data: data!).dictionaryObject
                if let json = json {
                    success(result: json)
                } else {
                    filed(error: error)
                }

        }
    }
    
    // 发送微博
    class func sendStatues(pictures: [Pictures], status: String, success:() -> (), failure:() -> ()) {
        
        
        let parameters = ["access_token": UserAccount.loadAccount()!.access_token!,
                          "status": status]
        if pictures.count == 1 {
            
            
            NetWorkTools.POST_Request("2/statuses/update.json", parameters: parameters, success: { (result) in
                
                success()
            }) { (error) in
                
                failure()
            }
        } else {
            Alamofire.upload(.POST, baseURL + "2/statuses/upload.json", multipartFormData: { multipartFormData in
                let access_token = parameters["access_token"]!.dataUsingEncoding(NSUTF8StringEncoding)
                
                let status = parameters["status"]!.dataUsingEncoding(NSUTF8StringEncoding)
                
                multipartFormData.appendBodyPart(data: access_token!, name: "access_token")
                multipartFormData.appendBodyPart(data: status!, name: "status")
                
                for i in 0..<pictures.count - 1
                {
                    let data = UIImagePNGRepresentation(pictures[i].image!)
                    multipartFormData.appendBodyPart(data: data!, name: "pic", fileName: "abc.png", mimeType: "application/octet-stream")
                }
                
                },encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            success()
                            
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        failure()
                    }
                }
            )
        }
    }
}
