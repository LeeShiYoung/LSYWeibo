//
//  AppDelegate.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/4/30.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

let AppdelegateNotifiKey = "AppdelegateNotifiKey"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //注册通知 用于 切换 控制器
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.changeViewController(_:)), name: AppdelegateNotifiKey, object: nil)
        
        UITabBar.appearance().tintColor = UIColor.orangeColor()
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = defultController()
        window?.makeKeyAndVisible()
        return true
    }
    
    // 接受通知 切换 控制器
    func changeViewController(noti: NSNotification) {
        if noti.object as! Bool {
            window?.rootViewController = MainViewController()
        } else {
            
            window?.rootViewController = "NewfeatureCollectionViewController".storyBoard()
        }
    }
    
    //获取 默认控制器
    private func defultController() -> UIViewController {
        
        if UserAccount.userLogin() {
            return isNewUpdate() ? "NewfeatureCollectionViewController".storyBoard() : "WelcomeViewController".storyBoard()
        }
        
        return MainViewController()
    }
    
    //判断是否有新版本
    private func isNewUpdate() -> Bool{
        
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
   
        let sandboxVersion =  NSUserDefaults.standardUserDefaults().objectForKey("CFBundleShortVersionString") as? String ?? ""
        
        if currentVersion.compare(sandboxVersion) == NSComparisonResult.OrderedDescending
        {
            NSUserDefaults.standardUserDefaults().setObject(currentVersion, forKey: "CFBundleShortVersionString")
            return true
        }
        
        return false
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

