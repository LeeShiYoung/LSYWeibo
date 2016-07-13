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
            
            pictures = statues?.statePic_URLs
            largePhoto()
            reloadData()
        }
    }
    var pictures: [NSURL]?
    
    private var pictureLayout = UICollectionViewFlowLayout()
    
    // 初始化方法
    init() {
        super.init(frame: CGRectZero, collectionViewLayout: pictureLayout)
        
        // 注册 cell
        registerNib(UINib(nibName: "PictureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: PictureReuseIdentifier)
        dataSource = self
        delegate = self
        backgroundColor = UIColor.whiteColor()
        pictureLayout.minimumLineSpacing = 10
        pictureLayout.minimumInteritemSpacing = 10
    }
    
    // 计算配图尺寸
    func calculationPicSize() -> CGSize {

        let count = statues?.statePic_URLs?.count
        
        let w: CGFloat = 100
        let margin: CGFloat = 10
        // 没有配图
        if count == 0 && count != nil {
            
            return CGSizeZero
        }
        
        // 只有 1 张配图
        if count == 1 && count != nil{
      
            let imageSize = statues?.cachePic_size
            let scale = (imageSize!.width) / (imageSize?.height)!
           
            if scale < 0.4 {//长图
                pictureLayout.itemSize = CGSize(width: 100, height: 130)
                return CGSize(width: 100, height: 130)
            } else {
                pictureLayout.itemSize = imageSize ?? CGSize(width: 100, height: 100)
                return imageSize!
            }
        }
        
        // 2张
        if count == 2 && count != nil {
            
            pictureLayout.itemSize = CGSize(width: w, height: w)
            return CGSize(width: w * 2 + margin, height: w)
        }
        
        // 4 张
        if count == 4 && count != nil {
            
            pictureLayout.itemSize = CGSize(width: w, height: w)
            return CGSize(width: 2 * w + margin, height: 2 * w + margin)
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
 
    @IBOutlet weak var tyoeIcon: UIImageView!
    @IBOutlet weak var picView: UIImageView!
    var p_url: NSURL? {
        didSet{
       
            picView.sd_setImageWithURL(p_url) {[weak self] (image, error, _, url) in
                if url.pathExtension == "gif" || url.pathExtension == "GIF" {
                    self!.tyoeIcon.image = UIImage(named: "timeline_image_gif")
                } else if image.size.width / image.size.height < 0.4 {
                    self!.tyoeIcon.image = UIImage(named: "timeline_image_longimage")
                } else {
                    self!.tyoeIcon.image = nil
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    } 
}

