//
//  ReachabilityManger.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/27.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SVProgressHUD

var reachability: Reachability?
extension Reachability {
    
    class func eachabilityManger(connection: () -> ()) {
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            
            print(unsafeAddressOf(reachability!))
            reachability!.whenReachable = { reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    // 检测网络类型
                    if reachability.isReachableViaWiFi() {
                        print("网络类型：Wifi")
                    } else if reachability.isReachableViaWWAN() {
                        print("网络类型：移动网络")
                    } else {
                        print("网络类型：无网络连接")
                        SVProgressHUD.popActivity()
                        SVProgressHUD.showError("网络错误")
                        connection()
                    }
                }
            }
            
            reachability!.whenUnreachable = { reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    print("网络不可用")
                    SVProgressHUD.popActivity()
                    SVProgressHUD.showError("网络错误")
                    connection()
                }
            }
            
        } catch ReachabilityError.FailedToCreateWithAddress(let address) {
            print("Unable to create\nReachability with address:\n\(address)")
            return
        } catch {}
     
        startNotifier()
    }
    
    // 开始监听
    class func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            print("监听失败")
        }
    }
    
    // 停止监听
    class func stopNotifier() {
        reachability?.stopNotifier()
        reachability = nil
    }
}


extension SVProgressHUD {
    
    class func showError(text: String) {
        SVProgressHUD.showErrorWithStatus(text)
        SVProgressHUD.setDefaultStyle(.Dark)
        SVProgressHUD.setDefaultMaskType(.None)
    }
    
    class func showCustom() { 
        SVProgressHUD.show()
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Custom)
        SVProgressHUD.setDefaultMaskType(.Clear)
    }
}