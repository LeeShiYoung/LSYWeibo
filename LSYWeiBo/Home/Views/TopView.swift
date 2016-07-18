//
//  TopView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/10.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage
import HYLabel

typealias downBtnCompleteion = (btn: UIButton) -> Void
typealias linkTapCompleteion = (link: String) -> Void

class TopView: UIView {

    @IBOutlet weak var mbrankImageView: UIImageView!
    // 用户头像
    @IBOutlet weak var iconView: UIImageView!
    // 用户名字
    @IBOutlet weak var nameLabel: UILabel!
    // 发表时间
    @IBOutlet weak var timeLabel: UILabel!

    // 来源
    @IBOutlet weak var soureLabel: UILabel!
    
    // 发布的内容
    @IBOutlet weak var contentLabel: HYLabel!
    
    // 认证图标
    @IBOutlet weak var acatarView: UIImageView!

    @IBAction func downBtnDidClick(sender: UIButton) {
        
        downComplete!(btn: sender)
    }
    
    var downComplete: downBtnCompleteion?
    var linkComplete: linkTapCompleteion?
    var statues: Statuses? {
        didSet{
            
            iconView.sd_setImageWithURL(statues?.user?.imageURL)
            iconView.kt_addCorner(radius: 25)
            nameLabel.text = statues?.user?.name
            
            nameLabel.textColor = statues?.user?.mbrank_Color
            
            timeLabel.text = statues?.create_at_Str
            mbrankImageView.image = statues?.user?.mbrankImage
            soureLabel.text = "来自: " + statues!.source_sub!
            contentLabel.attributedText = statues?.attributedString
            acatarView.image = statues?.user?.acatarImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        // 监听@谁谁谁的点击
        contentLabel.userTapHandler = { (label, user, range) in
       
        }
        
        // 监听链接的点击
        contentLabel.linkTapHandler = {[weak self] (label, link, range) in
            self!.linkComplete!(link: link)
        }
        
        // 监听话题的点击
        contentLabel.topicTapHandler = { (label, topic, range) in
         
        }
      
    }

}