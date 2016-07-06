//
//  WebViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/27.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import WebKit
import FDFullscreenPopGesture

private let progressKey = "estimatedProgress"
private let titleKey = "title"
class WebViewController: UIViewController {
    
    var loadString: String?
    var progress: UIProgressView?
    
    override func loadView() {
        
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "加载中..."
        self.fd_interactivePopDisabled = true
        setupNavi()
        setUpProgress()
        
        if let string = loadString {
            let request = NSURLRequest(URL: NSURL(string: string)!)
            webView.loadRequest(request)
            
            // 添加KVO
            webView.addObserver(self, forKeyPath: progressKey, options: NSKeyValueObservingOptions.New, context: nil)
            webView.addObserver(self, forKeyPath: titleKey, options: NSKeyValueObservingOptions.New, context: nil)
        }
    }
   
    private func setUpProgress() {
        progress = UIProgressView()
        progress!.frame = CGRect(x: 0, y: 44, width: LSYStruct.screen_w, height: 5)
        progress!.progress = 0.0
        progress!.progressTintColor = UIColor(red: 44 / 255.0, green: 103 / 255.0, blue: 161 / 255.0, alpha: 0.7)
        progress!.trackTintColor = UIColor.clearColor()
        progress!.hidden = true

        navigationController?.navigationBar.insertSubview(progress!, atIndex: 0)
    }
    
    private func setupNavi() {
        let backItem = UIBarButtonItem(imageName: "backbutton", title: nil, targrt: self, selector: .popBack)
        let closeItem = UIBarButtonItem(imageName: nil, title: "关闭", targrt: self, selector: .close)
        navigationItem.leftBarButtonItems = [backItem, closeItem]
  
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    
        if keyPath == progressKey {
            if let change = change {
                let pro = change["new"]
                progress!.setProgress(pro!.floatValue, animated: true)
            }
        }
        
        if keyPath == titleKey {
            if let change = change {
                let title = change["new"]
                if let title = title {
                    self.title = "\(title)"
                } else {
                    self.title = ""
                }
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let pro = progress {
            pro.hidden = true
        }
    }
    // webView
    private lazy var webView: WKWebView = {
        let web = WKWebView()
        web.navigationDelegate = self
        web.UIDelegate = self
        web.allowsBackForwardNavigationGestures = true
        
        // swipe手势
        let swipe = UISwipeGestureRecognizer(target: self, action: .goBack)
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        web.addGestureRecognizer(swipe)
        return web
    }()
    
    private lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(13.0)
        label.textColor = UIColor.darkGrayColor()
        label.frame = CGRect(x: 0, y: 64, width: LSYStruct.screen_w, height: 20)
        label.backgroundColor = UIColor.redColor()
        return label
    }()
    
    @objc private func webBack() {
        webView.goBack()
    }
    
    @objc private func close() {
       navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func popBack() {
        
        if webView.canGoBack {
            webView.goBack()
            return
        }
        navigationController?.popViewControllerAnimated(true)
    }
    deinit{
        webView.removeObserver(self, forKeyPath: progressKey)
        webView.removeObserver(self, forKeyPath: titleKey)
        
        if let pro = progress {
            pro.removeFromSuperview()
        }
    }
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

        progress!.hidden = false
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {

        progress!.hidden = true
        progress!.setProgress(0.0, animated: false)
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        progress!.hidden = true
        progress!.setProgress(0.0, animated: false)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {

        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if !(navigationAction.targetFrame?.mainFrame != nil) {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
}

private extension Selector {
    static let goBack = #selector(WebViewController.webBack)
    static let popBack = #selector(WebViewController.popBack)
    static let close = #selector(WebViewController.close)
}