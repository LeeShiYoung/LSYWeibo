//
//  UIViewController+Category.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/27.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func transitionAnimatior(transitior: Transitior, animationType: PresentationAnimations, showMask: Bool, presented: UIViewController, presentingFrame: () -> CGRect?) {
        
        self.transitioningDelegate = transitior
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        transitior.animationType = animationType
        transitior.showMask = showMask
        transitior.presentationViewFrame = presentingFrame()
       
        presented.presentViewController(self, animated: true, completion: nil)
    }
}