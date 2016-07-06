//
//  LSYProgressView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/7/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class LSYProgressView: UIView {

    var progress : CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // 1.获取参数
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let r = min(rect.width, rect.height) * 0.5 - 6
        let start = CGFloat(-M_PI_2)
        let end = start + progress * 2 * CGFloat(M_PI)
        
        /**
         参数：
         1. 中心点
         2. 半径
         3. 起始弧度
         4. 截至弧度
         5. 是否顺时针
         */
        
        // 2.根据进度画出中间的圆
        let path = UIBezierPath(arcCenter: center, radius: r, startAngle: start, endAngle: end, clockwise: true)
        path.addLineToPoint(center)
        path.closePath()
        UIColor(white: 1.0, alpha: 0.5).setFill()
        path.fill()
        
        // 3.画出边线
        let rEdge = min(rect.width, rect.height) * 0.5 - 2
        let endEdge = start + 2 * CGFloat(M_PI)
        let pathEdge = UIBezierPath(arcCenter: center, radius: rEdge, startAngle: start, endAngle: endEdge, clockwise: true)
        UIColor(white: 1.0, alpha: 0.5).setStroke()
        pathEdge.stroke()

    }
}
