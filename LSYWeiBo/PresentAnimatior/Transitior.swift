//
//  PopAnimatior.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

// 动画类型
enum PresentationAnimations {
    case Popover
    case CustomActionSheet
    case None
}

class Transitior: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    var presentationViewFrame: CGRect?
    var animationType: PresentationAnimations?
    var showMask = false
     override init() {
        
        self.presentationViewFrame = UIScreen.mainScreen().bounds
        self.animationType = PresentationAnimations?.None
        super.init()
    }
    
    
    // 保存 显示 或者 消失
    private var isPresent = true
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        let customPresentation = CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
        customPresentation.showMask = showMask
        customPresentation.presentationViewFrame = presentationViewFrame
        return customPresentation
    }
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        isPresent = true
        
        switch animationType! {
        case .Popover:
            NSNotificationCenter.defaultCenter().postNotificationName(HomeNotifitionKey, object: isPresent)
        case .CustomActionSheet:
            break
        case .None:
            break
        }
        
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
        switch animationType! {
        case .Popover:
            
            popoverAnimation(transitionContext)
        case .CustomActionSheet:
            
            customActionAnimation(transitionContext)
        case .None:
            break
        }
    }
    
    private func popoverAnimation(transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            toView?.transform = CGAffineTransformMakeScale(1.0, 0.0)
            toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            transitionContext.containerView()?.addSubview(toView!)
            toView?.alpha = 0
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                toView?.transform = CGAffineTransformIdentity
                toView?.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        } else {
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                fromView?.transform = CGAffineTransformMakeScale(1.0, 0.000001)
                fromView?.alpha = 0
                }, completion: { (_) in
                    transitionContext.completeTransition(true)
                    NSNotificationCenter.defaultCenter().postNotificationName(HomeNotifitionKey, object: false)
            })
        }
    }
    
    private func customActionAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresent {
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            toView?.frame.origin.y = LSYStruct.screen_h
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { 
                
                toView?.frame.origin.y = self.presentationViewFrame!.origin.y
                }, completion: { (_) in
                   transitionContext.completeTransition(true)
            })
        } else {
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
            UIView.animateWithDuration(transitionDuration(transitionContext) * 2/3, animations: { 
                
                fromView?.frame.origin.y = LSYStruct.screen_h
                }, completion: { (_) in
                    transitionContext.completeTransition(true)
            })
        }
    }
}
