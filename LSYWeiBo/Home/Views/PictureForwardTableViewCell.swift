//
//  PictureForwardTableViewCell.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/13.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import HYLabel
class PictureForwardTableViewCell: HomeTableViewCell {
    
    override var statues: Statuses?{
        didSet{
            forwardContent.attributedText = statues?.retweeted_status?.attributedString
        }
    }
    
    override func setUI() {
        super.setUI()
        // 监听@谁谁谁的点击
        forwardContent.userTapHandler = { (label, user, range) in
   
        }
        
        // 监听链接的点击
        forwardContent.linkTapHandler = {[weak self] (label, link, range) in
          
            self!.delegate?.linkTap(link)
        }
        
        // 监听话题的点击
        forwardContent.topicTapHandler = { (label, topic, range) in
         
        }

        contentView.insertSubview(backgroundButton, belowSubview: pictureView)
        backgroundButton.addSubview(forwardContent)
        
        // 布局
        forwardContent.snp_makeConstraints { (make) in
            make.top.equalTo(topView.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.bottom.equalTo(pictureView.snp_top).offset(-10)        }
        
        pictureView.snp_makeConstraints { (make) in
            
            make.left.equalTo(contentView.snp_left).offset(10)
            make.bottom.equalTo(bottomView.snp_top).offset(-10).priorityLow()
        }
        
        
        bottomView.snp_makeConstraints { (make) in
            make.height.equalTo(50).priorityLow()
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
                
        
        backgroundButton.snp_makeConstraints { (make) in
            make.top.equalTo(topView.snp_bottom)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(bottomView.snp_top)
        }
    }
}




