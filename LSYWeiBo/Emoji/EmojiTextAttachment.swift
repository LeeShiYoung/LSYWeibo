//
//  EmojiTextAttachment.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/27.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class EmojiTextAttachment: NSTextAttachment {

    // 表情文字
    var title: String?
    class func emojiAttachment(emoticon: Emoticon, font: UIFont) -> NSAttributedString {
        
        let attachment = EmojiTextAttachment()
        attachment.title = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.pngPath!)
        
        let size = font.lineHeight
        attachment.bounds = CGRectMake(0, -4, size, size)
        return NSAttributedString(attachment: attachment)
    }
}
