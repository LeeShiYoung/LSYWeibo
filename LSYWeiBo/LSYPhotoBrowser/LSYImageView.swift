//
//  LSYImageView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/7/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

protocol LSYImageViewDelegate: NSObjectProtocol {

    func handleImageDisMiss(ges: UITapGestureRecognizer)
    func handleImageViewDoubleTap(ges: UITapGestureRecognizer)
}

class LSYImageView: UIImageView {

  
    weak var lsyimageDelegate: LSYImageViewDelegate?
    init(){
        super.init(frame: CGRectZero)
   
        userInteractionEnabled = true
        
        // 添加手势
       let doubleTapGesture = UITapGestureRecognizer(target: self, action: .doubleTap)
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        
       let singleTapGesture = UITapGestureRecognizer(target: self, action: .singleTap)
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTapGesture)
        addGestureRecognizer(singleTapGesture)
    }
  

    func handleSingleTap(ges: UITapGestureRecognizer) {
        lsyimageDelegate!.handleImageDisMiss(ges)
    }
    
    func handleDoubleTap(ges: UITapGestureRecognizer) {
        lsyimageDelegate?.handleImageViewDoubleTap(ges)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Selector {
    static let singleTap = #selector(LSYImageView.handleSingleTap(_:))
    static let doubleTap = #selector(LSYImageView.handleDoubleTap(_:))
}
