//
//  OAuthViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SVProgressHUD

let client_id = "3092083192"
let redirect_uri = "http://www.youmeishi.cn"
let client_secret = "99e5d4682c4fe113e5ddd28e3fc5453e"

class OAuthViewController: UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
        
 
        let http = baseURL + "oauth2/authorize?" + "client_id=\(client_id)" + "&" + "redirect_uri=\(redirect_uri)"
        webView.loadRequest(NSURLRequest(URL: NSURL(string: http)!))
        
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - webViewDelegate
extension OAuthViewController:  UIWebViewDelegate
{
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestStr = request.URL?.absoluteString
        
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.Clear)
        }
        
        if requestStr!.hasSuffix(redirect_uri) {
            return true
        }
        
        if requestStr!.hasPrefix(redirect_uri + "/?") {
            
            let codeStr = redirect_uri + "/?code="
            
            // 截取 requestToken
            let requestToken = requestStr?.substringWithRange(Range(codeStr.endIndex..<requestStr!.endIndex))
            
            // 根据 requestToken 获取 access_token
            obtainAccess_token(requestToken!, response: { (accessToken) in
                
                // 将带有 accessToken 的数据 存入模型
                let account = UserAccount.mj_objectWithKeyValues(accessToken)
                
                //获取用户信息
                account.loadUserInfo({ (error) in
                    
                    if error == nil{
                        
                        // 将用户信息保存
                        account?.save()
                        
                        // 进入主界面
                        NSNotificationCenter.defaultCenter().postNotificationName(AppdelegateNotifiKey, object: true)
                    }
                })
            })
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("加载完成")
        SVProgressHUD.dismiss()
    }
    
    //获取 access_token
    private func obtainAccess_token(requestToken: String, response:(accessToken: [String: AnyObject]) -> ()) {
        
        let parameters = ["client_id": client_id, "client_secret": client_secret, "grant_type": "authorization_code", "code": requestToken, "redirect_uri": redirect_uri];
        
        NetWorkTools.POST_Request("oauth2/access_token", parameters: parameters, success: { (result) in
            
            response(accessToken:(result))
            
        }) { (error) in
            
            print("授权失败")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
    }
}
