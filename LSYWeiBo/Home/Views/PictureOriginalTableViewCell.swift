//
//  PictureOriginalTableViewCell.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/13.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class PictureOriginalTableViewCell: HomeTableViewCell {

    override func setUI() {
        super.setUI()
 
        pictureView.snp_makeConstraints { (make) in
            
            make.top.equalTo(topView.snp_bottom)
            make.left.equalTo(10)
            make.bottom.equalTo(bottomView.snp_top).offset(-10).priorityLow()
        }

        bottomView.snp_makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
    }

}
