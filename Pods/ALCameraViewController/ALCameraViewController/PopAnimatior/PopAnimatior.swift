//
//  PopAnimatior.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class PopAnimatior: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    let presentCompletion: (toView: UIView?, duration: NSTimeInterval, context: UIViewControllerContextTransitioning) -> ()
    let dismissCompletion: (fromView: UIView?, duration: NSTimeInterval, context: UIViewControllerContextTransitioning) -> ()
    
    init(presentCompletion: (toView: UIView?, duration: NSTimeInterval, context: UIViewControllerContextTransitioning) -> (), dismissCompletion: (fromView: UIView?, duration: NSTimeInterval, context: UIViewControllerContextTransitioning) -> ()) {
        self.presentCompletion = presentCompletion
        self.dismissCompletion = dismissCompletion
        super.init()
    }
    
    var presentationViewFrame: CGRect?
    // 保存 显示 或者 消失
    var isPresent = true
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        let customPresentation = CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
        customPresentation.presentationViewFrame = presentationViewFrame
        return customPresentation
    }
   
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = true
        return self
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = false
        return self
    }
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        // 转场动画
        if isPresent {
         
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            
            presentCompletion(toView: toView, duration: transitionDuration(transitionContext), context: transitionContext)
        } else {
            
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)

            dismissCompletion(fromView: fromView, duration: transitionDuration(transitionContext), context: transitionContext)
        }
    }
}
