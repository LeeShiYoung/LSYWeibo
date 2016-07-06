//
//  LSYPhoto.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/7/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class LSYPhoto: NSObject {

    // 高清图URL
    var largeUrl: NSURL?

    // 缩略图URL
    var thumbUrl: NSURL?
    
    override init() {
        super.init()
    }
    
    convenience init(largeUrl: NSURL, thumbUrl: NSURL) {
        self.init()
        self.largeUrl = largeUrl
        self.thumbUrl = thumbUrl
    }
    
    class func photoImageUrl(largeUrl: NSURL, thumbUrl: NSURL) -> LSYPhoto {
        return LSYPhoto(largeUrl: largeUrl, thumbUrl: thumbUrl)
    }
}
