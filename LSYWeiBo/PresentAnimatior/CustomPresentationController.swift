//
//  CustomPresentationController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {

    var presentationViewFrame: CGRect?
    var showMask = false
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView()?.frame = presentationViewFrame ?? CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
        
        if !showMask {
            maskView.backgroundColor = UIColor.clearColor()
        } else {
            maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
            maskView.alpha = 0
            UIView.animateWithDuration(0.2, animations: {
                self.maskView.alpha = 1
            })
        }
        
        containerView?.insertSubview(maskView, atIndex: 0)
        containerView?.addSubview(presentedView()!)
    }
    
    // MARK: - 懒加载
    private lazy var maskView: UIView = {
        let v = UIView()
        v.frame = UIScreen.mainScreen().bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.dismMiss))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    @objc private func dismMiss() {
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }

}
