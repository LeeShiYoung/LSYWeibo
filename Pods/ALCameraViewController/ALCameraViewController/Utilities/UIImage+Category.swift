//
//  UIImage+Category.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/3.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
extension UIImage {
    
    func imageWithScale(width: CGFloat) -> UIImage
    {

        let height = width *  size.height / size.width
        
        let currentSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        drawInRect(CGRect(origin: CGPointZero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}