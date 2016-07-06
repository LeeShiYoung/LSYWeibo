//
//  Pictures.swift
//  PictureSelector
//
//  Created by 李世洋 on 16/5/30.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class Pictures: NSObject {
    
    // 照片
    var image: UIImage?
    
    // 是否是删除
    var isRemove = false
    
    // 照片tag
    var pictureTag = 0

    static var count = -1
    class func loadPictures(images: [UIImage]?) -> [Pictures] {
        
        var pics = [Pictures]()
        if images != nil {
            for img in images! {
                count += 1
                let pic = Pictures(image: img, isRemove: true)
                pics.append(pic)
            }
        }
        return pics
    }
    
    // 一张照片
    class func sheetPicture(image: UIImage) -> Pictures {
        return Pictures(image: image, isRemove: true)
    }
    
    // 加号按钮
    class func addBtn() -> Pictures {
        return Pictures(image: UIImage(named: "compose_pic_add")!, isRemove: false)
    }
    
    init(image: UIImage, isRemove: Bool) {
        super.init()
        self.image = image
        self.isRemove = isRemove
    }
}
