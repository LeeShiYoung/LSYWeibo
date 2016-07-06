//
//  LSYImageView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/7/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

protocol LSYImageViewDelegate: NSObjectProtocol {

    func tapDisMiss()
    func handleImageViewDoubleTap(view: UIImageView, touch: UITouch)
}

class LSYImageView: UIImageView {

  
    weak var lsyimageDelegate: LSYImageViewDelegate?
    init(){
        super.init(frame: CGRectZero)
        
        userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch = touches.first!
        switch touch.tapCount {
        case 1 : handleSingleTap()
        case 2 : handleDoubleTap(touch)
        default: break
        }
        nextResponder()
    }
    
    func handleSingleTap() {
        lsyimageDelegate!.tapDisMiss()
    }
    
    func handleDoubleTap(touch: UITouch) {
        lsyimageDelegate?.handleImageViewDoubleTap(self, touch: touch)
//        if zoomScale > minimumZoomScale {
//            // zoom out
//            setZoomScale(minimumZoomScale, animated: true)
//        } else {
//            zoomToRect(zoomRectForScrollViewWith(maximumZoomScale, touchPoint: touchPoint), animated: true)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
