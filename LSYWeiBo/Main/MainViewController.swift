//
//  MainViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //添加子视图
        addChildViewControllers()
    }
    
    @objc private func sendMessage() {
  
        // 判断是否登录
        let login = UserAccount.userLogin()
        if !login {
            SVProgressHUD.showInfoWithStatus("登陆后才可发送微博")
            SVProgressHUD.setDefaultStyle(.Dark)
            SVProgressHUD.setDefaultMaskType(.Clear)
            
            return
        }
        
        let smVC = "EmojiViewController".storyBoard()
        self.presentViewController(smVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.addSubview(midBth)
        
        let w = LSYStruct.screen_w / CGFloat(viewControllers!.count)
        midBth.frame = CGRectOffset(CGRect(x: 0, y: 0, width: w, height: 49), 2 * w, 0)
        midBth.addTarget(self, action: #selector(MainViewController.sendMessage), forControlEvents: UIControlEvents.TouchUpInside)
        
        }
    
    private func addChildViewControllers() {
        let path = NSBundle.mainBundle().pathForResource("MainVCSettings.json", ofType: nil)
        let data = NSData(contentsOfFile: path!)
        
        do {
             let jsonArr = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            for dict in jsonArr as! [[String: String]]
            {
                addChildViewController(dict["vcName"]!, title: dict["title"]!, imageName: dict["imageName"]!)
            }
            
        } catch {
            
            print(error)
            
            addChildViewController("HomeTableViewController", title: "首页", imageName: "tabbar_home")
            addChildViewController("MessageTableViewController", title: "消息", imageName: "tabbar_message_center")
            addChildViewController("DiscoverTableViewController", title: "广场", imageName: "tabbar_discover")
            addChildViewController("DiscoverTableViewController", title: "我", imageName: "tabbar_profile")
        }
    }
    
    private func addChildViewController(clildControllerName: String, title: String, imageName: String) {
        
        let vc = UIStoryboard(name: clildControllerName, bundle: nil).instantiateInitialViewController()
        vc?.tabBarItem.image = UIImage(named: imageName)
        vc?.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        vc?.title = title
        addChildViewController(vc!)
    }
    
   
    
    
    // MARK: - 懒加载 中间 加号 按钮
    private lazy var midBth: UIButton = {
        let btn = NSBundle.mainBundle().loadNibNamed("MiddleButton", owner: self, options: nil).last as! UIButton
        return btn
        
    }()
}
