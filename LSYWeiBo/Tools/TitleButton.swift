//
//  TitleButton.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/3.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class TitleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_down"), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), forState: UIControlState.Selected)
        setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Highlighted)
        self.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.size.width+5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

