
//
//  WelcomeViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/6.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {
    
    //用户头像
    @IBOutlet weak var userIcon: UIImageView!
    //用户名
    @IBOutlet weak var userName: UILabel!
    //用户头像约束
    @IBOutlet weak var iconCon: NSLayoutConstraint!
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 加载用户头像
        let iconStr = UserAccount.loadAccount()?.avatar_large
        userIcon.LSY_CircleImage(url: NSURL(string: iconStr!))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.transform = CGAffineTransformMakeScale(0, 0)
        userIcon.alpha = 0.0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //执行欢迎动画
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.userIcon.alpha = 1.0
            self.iconCon.active = true
            self.iconCon.constant = LSYStruct.screen_h - 200
            self.view.layoutIfNeeded()
        }) { (_) in
            
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions(rawValue: 0), animations: {
                
                self.userName.transform = CGAffineTransformIdentity
                }, completion: { (_) in
                    
                    //进入主界面
                    NSNotificationCenter.defaultCenter().postNotificationName(AppdelegateNotifiKey, object: true)
            })
        }
    }
}
