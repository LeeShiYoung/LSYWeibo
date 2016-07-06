//
//  UITextView+Category.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/27.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

extension UITextView {
    
    // 插入png表情
    func insterPngEmoji(emoticon: Emoticon) {
        
        // 删除
        if emoticon.removeBtn {
            
            deleteBackward()
        }
        
        // 当前是 emoji
        if let emojiStr = emoticon.emojiStr {
            
            replaceRange(selectedTextRange!, withText: emojiStr)
        }
        
        // 当前是png表情
        if emoticon.png != nil {
            
            let attributImage = EmojiTextAttachment.emojiAttachment(emoticon, font: font!)
            
            let allStr = NSMutableAttributedString(attributedString: attributedText)
            
            let range = selectedRange
            
            allStr.replaceCharactersInRange(range, withAttributedString: attributImage)
            allStr.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(range.location, 1))
            attributedText = allStr
            selectedRange = NSMakeRange(range.location + 1, 0)
            
            delegate?.textViewDidChange!(self)
        }
    }
    
    // 获取发送文本
    func emojiAttributedString() -> String {
        var strM = String()
        attributedText.enumerateAttributesInRange(NSRange(0..<attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (objc, range, _) in
            
            if let achment = objc["NSAttachment"] {
                
                strM += (achment as! EmojiTextAttachment).title!
            } else {
                
                strM += (self.text as NSString).substringWithRange(range)
            }
        })
        return strM
    }
}
