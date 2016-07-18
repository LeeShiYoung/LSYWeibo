//
//  BottomView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/10.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class BottomView: UIView {

    // 转发
    @IBOutlet weak var reposts_count: UIButton!
    // 评论
    @IBOutlet weak var comments_count: UIButton!
    // 赞
    @IBOutlet weak var attitudes_count: UIButton!
    
    var status: Statuses? {
        
        didSet{
            if status != nil {
            setUpButtonInfo(reposts_count, count: (status?.reposts_count)!, title: "转发")
            setUpButtonInfo(comments_count, count: (status?.comments_count)!, title: "评论")
            setUpButtonInfo(attitudes_count, count: (status?.attitudes_count)!, title: "赞")
            }
        }
    }
    
    // 设置按钮标题
    private func setUpButtonInfo(btn: UIButton, count: Int, title: String) {
        
        count == 0 ? btn.setTitle(title, forState: UIControlState.Normal) : btn.setTitle("\( count)", forState: UIControlState.Normal)
    }
}
