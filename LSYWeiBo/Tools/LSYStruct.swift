//
//  MyDefine.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/23.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

struct LSYStruct {
    static let screen_w = UIScreen.mainScreen().bounds.size.width
    static let screen_h = UIScreen.mainScreen().bounds.size.height
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
