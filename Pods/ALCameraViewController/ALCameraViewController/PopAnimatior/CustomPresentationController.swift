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
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    override func containerViewWillLayoutSubviews() {
   
        let presentedV = presentedView()
        presentedV?.frame = presentationViewFrame ?? CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
 
        containerView?.addSubview(presentedV!)
    }
    
    // MARK: - 懒加载
    private lazy var maskView: UIView = {
        let v = UIView()
        v.frame = UIScreen.mainScreen().bounds
        v.backgroundColor = UIColor.clearColor()
        let tap = UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.dismMiss))
        v.addGestureRecognizer(tap)
        return v
    }()
    
    @objc private func dismMiss() {
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
