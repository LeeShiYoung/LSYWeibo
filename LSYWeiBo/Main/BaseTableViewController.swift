//
//  BaseTableViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController  {
    var visitorView: VisitorView?
    
    let login = UserAccount.userLogin()
    override func loadView() {
        
        // 未登录显示 访客界面
        login ? super.loadView() : createVisitorView()
    }
    
    
    //MARK: - 初始化 未登录 界面
    private func createVisitorView() {
        let customView = NSBundle.mainBundle().loadNibNamed("VisitorView", owner: self, options: nil).last as! VisitorView
        view = customView
        visitorView = customView
        visitorView?.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: .registerBtnClick)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: .loginBtnClick)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //注册(导航栏）
    func registerBtnWillClick() {
        print(#function)
        
    }
    
    // 登录(导航栏）
    func loginBtnWillClick() {
        presentViewController("OAuthViewController".storyBoard(), animated: true, completion: nil)
        
    }
}

extension BaseTableViewController: VisitorViewDelegate
{
    func registerClick() {
        
    }
    
    func loginClick() {
    
        presentViewController("OAuthViewController".storyBoard(), animated: true, completion: nil)
    
    }
}

private extension Selector {
    static let registerBtnClick = #selector(BaseTableViewController.registerBtnWillClick)
   static let loginBtnClick = #selector(BaseTableViewController.loginBtnWillClick)
}
