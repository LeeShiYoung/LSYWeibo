//
//  TransitionAnimator.swift
//  LSYPhotoBrowser
//
//  Created by 李世洋 on 16/7/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

protocol  LSYTransitionAnimatorDelegate: NSObjectProtocol {
    func imageViewForPresent(indexPath: NSIndexPath?) -> UIImageView
    func startAnimationFrame(indexPath: NSIndexPath?) -> CGRect
    func endAnimationFrame(indexPath: NSIndexPath?) -> CGRect
    
    func imageViewForDismiss() -> UIImageView
    func indexForDisMiss() -> NSIndexPath
}

class LSYTransitionAnimator: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning  {

    private var indexpath: NSIndexPath?
    // 设置属性
    func setInfo(presentedDelegate: LSYTransitionAnimatorDelegate, indexPath: NSIndexPath?) {
        self.lsytansitionAnimatorDelegate = presentedDelegate
        self.indexpath = indexPath
    }
    
    // 动画显示的图片
    var imageUrl: NSURL?
    
    weak var lsytansitionAnimatorDelegate: LSYTransitionAnimatorDelegate?
    private var isPresent = true

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
        isPresent == true ? showAnimation(transitionContext) : disMissAnimation(transitionContext)
        
    }
    
    // 弹出动画
    private func showAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let toview = transitionContext.viewForKey(UITransitionContextToViewKey)
        transitionContext.containerView()!.addSubview(toview!)
        
        let imageView = lsytansitionAnimatorDelegate!.imageViewForPresent(indexpath)
        imageView.frame = lsytansitionAnimatorDelegate!.startAnimationFrame(indexpath)
         transitionContext.containerView()!.backgroundColor = UIColor.blackColor()
        transitionContext.containerView()!.addSubview(imageView)
        
        toview?.alpha = 0
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            
             imageView.frame = self.lsytansitionAnimatorDelegate!.endAnimationFrame(self.indexpath)
            
            }) { (_) in
                imageView.removeFromSuperview()
                toview?.alpha = 1
                transitionContext.completeTransition(true)
        }
    }

    //消失动画
    private func disMissAnimation(transitionContext: UIViewControllerContextTransitioning) {
      
        guard let delegate = lsytansitionAnimatorDelegate else {
            return
        }
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        fromView?.alpha = 0
        transitionContext.containerView()?.backgroundColor = UIColor.clearColor()
        let disMissImage = lsytansitionAnimatorDelegate!.imageViewForDismiss()
        transitionContext.containerView()?.addSubview(disMissImage)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { 
            
            disMissImage.frame = delegate.startAnimationFrame(delegate.indexForDisMiss())
            }) { (_) in
            disMissImage.removeFromSuperview()
               transitionContext.completeTransition(true)
        }
    }
    
    private lazy var animationImage: UIImageView = {
       
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.redColor()
        return imageView
    }()
}



class LSYPresentationController: UIPresentationController {
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
}