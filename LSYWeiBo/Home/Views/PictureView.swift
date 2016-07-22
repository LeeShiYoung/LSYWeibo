//
//  PictureView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/10.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage

class PictureView: UICollectionView {
    
    let PictureReuseIdentifier = "PictureReuseIdentifier"
    var statues: Statuses?
        {
        didSet{
            pictures = statues!.statusBody ? statues!.stateOriginal_URLs : statues?.statePic_URLs
       
            largePhoto()
            reloadData()
        }
    }
    var pictures: [NSURL]?
    
    private var pictureLayout = UICollectionViewFlowLayout()
    
    // 初始化方法
    init() {
        super.init(frame: CGRectZero, collectionViewLayout: pictureLayout)
        self.scrollEnabled = false
        // 注册 cell
//        registerNib(UINib(nibName: "PictureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: PictureReuseIdentifier)
        registerClass(PictureCollectionViewCell.self, forCellWithReuseIdentifier: PictureReuseIdentifier)
        dataSource = self
        delegate = self
        backgroundColor = UIColor.whiteColor()
        pictureLayout.minimumLineSpacing = 10
        pictureLayout.minimumInteritemSpacing = 10
    }
    
    // 计算配图尺寸
    func calculationPicSize() -> CGSize {

        let count = statues?.statePic_URLs?.count
        let size_w = UIScreen.mainScreen().bounds.size.width - 20
        
        let w: CGFloat = 100
        let margin: CGFloat = 10
        
        // 没有配图
        if count == 0 && count != nil {
            
            return CGSizeZero
        }
        
        // 只有 1 张配图
        if count == 1 && count != nil{
            
            let imageSize = statues?.cachePic_size
            
            let statusClosure = {
                (size: CGSize?) -> CGSize in
                let scale = (imageSize!.width) / (imageSize?.height)!
                
                if scale < 0.4 {//长图
                    self.pictureLayout.itemSize = CGSize(width: 100, height: 130)
                    return CGSize(width: 100, height: 130)
                } else {
                    self.pictureLayout.itemSize = imageSize ?? CGSize(width: 100, height: 100)
                    return imageSize!
                }
            }
            
            let statusBodyClosure = {
                (size: CGSize?) -> CGSize in
                
                let size_h = size!.height * size_w / size!.width
                let itemSize = CGSize(width: size_w, height: size_h)
                self.pictureLayout.itemSize = itemSize
                return itemSize
            }
            
            return statues?.statusBody == false ? statusClosure(imageSize) : statusBodyClosure(imageSize)
        }
        
        // 2张
        if count == 2 && count != nil {
            
            let statusClosure = {
                () -> CGSize in
                self.pictureLayout.itemSize = CGSize(width: w, height: w)
                return CGSize(width: w * 2 + margin, height: w)
            }
            
            let statusBodyClosure = {
                () -> CGSize in
                self.pictureLayout.itemSize = CGSize(width: (size_w - margin) / 2, height: size_w / 2 )
                return CGSize(width: size_w, height: size_w / 2)
            }
            return statues?.statusBody == false ? statusClosure() : statusBodyClosure()
        }
        
        // 4 张
        if count == 4 && count != nil {
            let statusClosure = {
                () -> CGSize in
                self.pictureLayout.itemSize = CGSize(width: w, height: w)
                return CGSize(width: 2 * w + margin, height: 2 * w + margin)
            }
            
            let statusBodyClosure = {
                () -> CGSize in
                self.pictureLayout.itemSize = CGSize(width: (size_w - margin) / 2, height: (size_w - margin) / 2)
                return CGSize(width: size_w, height: size_w)
            }
            return statues?.statusBody == false ? statusClosure() : statusBodyClosure()
        }
        
        // 其他
        let columnNumber: CGFloat = 3
        let rowNumber = CGFloat((count! - 1) / 3 + 1)
        let w2 = ((LSYStruct.screen_w - 20) - 2 * margin) / 3
        let width = columnNumber * w2 + (columnNumber - 1) * margin
        let height = rowNumber * w2 + (rowNumber - 1) * margin
        pictureLayout.itemSize = CGSize(width: w2, height: w2)
        return CGSize(width: width, height: height)
    }
    
    
    // 图片浏览器显示的 大图
    var photos: [LSYPhoto]?
    
    private func largePhoto() {
        
        photos = [LSYPhoto]()
        let ps = statues?.stateOriginal_URLs
        
        for i in 0..<ps!.count {

            let largeUrl = ps![i]
            let thumbUrl = pictures![i]

            let bigUrl = LSYPhoto.photoImageUrl(largeUrl, thumbUrl: thumbUrl)
            
            photos?.append(bigUrl)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate
extension PictureView: UICollectionViewDataSource, UICollectionViewDelegate
{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pictures?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PictureReuseIdentifier, forIndexPath: indexPath) as! PictureCollectionViewCell
        
        cell.p_url = pictures![indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PictureCollectionViewCell else {
            return
        }

        let browser = LSYPhotoBrowserViewController(photos: photos!, indexPath: indexPath, animationedFromView: cell)
        NSNotificationCenter.defaultCenter().postNotificationName(HomePhotoBrowerNotiKey, object: nil, userInfo: ["browser": browser])
    }
}

// MARK: - UICollectionViewCell
class PictureCollectionViewCell: UICollectionViewCell {
 
    var p_url: NSURL? {
        didSet{
  
            SDWebImageManager.sharedManager().downloadImageWithURL(p_url, options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, error, _, _, url) in
                
                self.picView.layer.contents = image.CGImage
                if url.absoluteString.rangeOfString("large") != nil {
                    self.layer.contents = nil
                    return
                }
                if url.pathExtension == "gif" || url.pathExtension == "GIF" {
                    self.typeIcon.layer.contents = UIImage(named: "timeline_image_gif")!.CGImage
                } else if image.size.width / image.size.height < 0.4 {
                    self.typeIcon.layer.contents = UIImage(named: "timeline_image_longimage")!.CGImage
                } else {
                    self.typeIcon.layer.contents = nil
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(picView)
        picView.addSubview(typeIcon)
        picView.contentMode = UIViewContentMode.ScaleAspectFill
        picView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        picView.frame = contentView.bounds
        typeIcon.frame = CGRect(x: picView.frame.size.width-28, y: picView.frame.size.height-18, width: 28, height: 18)
    }

    private lazy var picView = UIView()
    private lazy var typeIcon = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

