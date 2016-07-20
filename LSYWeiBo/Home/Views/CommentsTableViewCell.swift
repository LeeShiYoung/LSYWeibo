//
//  CommentsTableViewCell.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/7/14.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import HYLabel
import SnapKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentsTime: UILabel!
    @IBOutlet weak var commentsContent: HYLabel!
    @IBOutlet weak var mbrank: UIImageView!
    
    var comments: Comments? {
        didSet{
            commentsContent.attributedText = comments?.attributedText
            userIcon.sd_setImageWithURL(comments?.user?.imageURL)
            userIcon.kt_addCorner(radius: 30/2)
            userName.text = comments?.user?.name
            userName.textColor = comments?.user?.mbrank_Color
            commentsTime.text = comments?.created_at_Str
            mbrank.image = comments?.user?.mbrankImage
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    @IBAction func praiseBtnClick(sender: UIButton) {
        
    }
}


struct listType {
    var forward = false // 转发
    var comments = false // 评论
}

typealias headViewButtonsClick = (type: listType) -> Void
class CommentsHeaderView: UIView {
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var buttonView: UIView!
    var buttonsClick: headViewButtonsClick?
    var list = listType()
    var status: Statuses? {
        didSet{
            forwardBtn.setTitle("转发 \(status?.reposts_count ?? 0)", forState: .Normal)
            commentsBtn.setTitle("评论 \(status?.comments_count ?? 0)", forState: .Normal)
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonView.layer.contents = UIImage(named: "timeline_card_bottom_background")?.CGImage
        
        buttonView.addSubview(lineView)
        lineView.snp_makeConstraints { (make) in
            make.left.equalTo(commentsBtn.snp_left)
            make.right.equalTo(commentsBtn.snp_right)
            make.bottom.equalTo(buttonView.snp_bottom).offset(-3)
            make.height.equalTo(3)
        }
    }
   
    private lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.orangeColor()
        return v
    }()
    
    @IBAction func commentsBtnClick(sender: UIButton) {
        UIView.animateWithDuration(0.5) {
            self.lineView.snp_remakeConstraints {[weak self] (make) in
                make.left.equalTo(self!.commentsBtn.snp_left)
                make.right.equalTo(self!.commentsBtn.snp_right)
                make.bottom.equalTo(self!.buttonView.snp_bottom).offset(-3)
                make.height.equalTo(3)
            }
        }
        list.comments = true
        list.forward = false
        buttonsClick?(type: list)
    }
    
    @IBAction func forwardBtnClick(sender: UIButton) {
        
        UIView.animateWithDuration(0.5) {
            self.lineView.snp_remakeConstraints {[weak self] (make) in
                
                make.left.equalTo(self!.forwardBtn.snp_left)
                make.right.equalTo(self!.forwardBtn.snp_right)
                make.bottom.equalTo(self!.buttonView.snp_bottom).offset(-3)
                make.height.equalTo(3)
            }
        }
        
        list.forward = true
        list.comments = false
        buttonsClick?(type: list)
    }
}

