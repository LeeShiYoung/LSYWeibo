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

            if let reposts_count = reposts_count {
                setUpButtonInfo(reposts_count, count: (status?.reposts_count)!, title: "转发")
                setUpButtonInfo(comments_count, count: (status?.comments_count)!, title: "评论")
                setUpButtonInfo(attitudes_count, count: (status?.attitudes_count)!, title: "赞")
            }
        }
    }
    
    // 设置按钮标题
    private func setUpButtonInfo(btn: UIButton, count: Int, title: String) {
        
        status?.attitudes == true ? (btn.selected = true) : (btn.selected = false)
        func configurationButton(title: String) {

            btn.setTitle(title, forState: UIControlState.Normal)
        }
        
        count == 0 ? configurationButton(title) : configurationButton("\( count)")
        
    }
    
    @IBAction func commentsClick(sender: UIButton) {
        
    }
    
    @IBAction func attitudesClick(sender: UIButton) {
        
        func upDateConfigurationButton(count: Int) {
            sender.setTitle("\(count)", forState: .Normal)
           
            status?.attitudes = !status!.attitudes
            status?.attitudes_count = count
            
            // 更新
            StatusesDB.upDateStatuses(status!, newAttitudes: status!.attitudes)
        }
        
        sender.imageView!.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
            
            sender.imageView!.transform = CGAffineTransformIdentity
            sender.selected = !sender.selected
            
            sender.selected ? upDateConfigurationButton(self.status!.attitudes_count+1) : upDateConfigurationButton(self.status!.attitudes_count-1)
            }) { (_) in
                
        }
    }
    
    @IBAction func repostsClick(sender: UIButton) {
        
    }
    
}
