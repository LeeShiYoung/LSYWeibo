//
//  StatuesMessage.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/16.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class StatuesMessage: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        frame = CGRect(x: 0, y: 44 - 35, width: LSYStruct.screen_w, height: 35)
    }
    
    func showNewStatuesCount(count: Int) {
        if count == 0 {
            return
        }
        
        self.hidden = false
        let text = count == 0 ? "暂无最新微博": "更新\(count)条微博"
        self.text = text

        UIView.animateWithDuration(1, animations: {
            
            self.frame.origin.y =  self.frame.origin.y + 35
            }) { (_) in
                
                UIView.animateWithDuration(1, delay: 2, options: UIViewAnimationOptions(rawValue: 0), animations: { 
                    
                    self.frame.origin.y = 44 - 35
                    }, completion: { (_) in
                        
                        self.hidden = true
                })
            }
        }
}
