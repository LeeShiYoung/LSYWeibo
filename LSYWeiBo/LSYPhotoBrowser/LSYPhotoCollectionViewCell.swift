//
//  LSYPhotoCollectionViewCell.swift
//  LSYPhotoBrowser
//
//  Created by 李世洋 on 16/7/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage

protocol LSYCellDelegate: NSObjectProtocol {
    func disMissViewController()
}
class LSYPhotoCollectionViewCell: UICollectionViewCell {
    
    weak var cellDelegate: LSYCellDelegate?
    var photo: LSYPhoto? {
        didSet{
            reset()
            // 拿到小图
            var sImage = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(photo!.thumbUrl?.absoluteString)
            
            if sImage == nil {
                sImage = UIImage(named: "empty_picture")!
            }
            
            calculateImageFrame(sImage)
            
            // 显示大图
            downImages(photo?.largeUrl, placehodle:sImage)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.5
        scrollView.addSubview(imageView)
        scrollView.frame = contentView.bounds
        contentView.addSubview(progressView)
        progressView.backgroundColor = UIColor.clearColor()
        progressView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        progressView.center = CGPoint(x: contentView.bounds.width * 0.5 - 10, y: contentView.bounds.height * 0.5)
    }
   
    
    // 下载图片
    private func downImages(url: NSURL?, placehodle: UIImage) {
        
        guard let _ = url else {
            return
        }
        
        progressView.hidden = false
        imageView.sd_setImageWithURL(url, placeholderImage: placehodle, options: SDWebImageOptions(rawValue: 0), progress: {[weak self] (current, total) in
            dispatch_async(dispatch_get_main_queue(), {
                
                self!.progressView.progress = CGFloat(current)/CGFloat(total)
            })
        
            }) { (image, _, _, _) in
                if let image = image {
                self.calculateImageFrame(image)
                }
                self.imageView.image = image
                self.progressView.hidden = true
        }
    }
    
    lazy var imageView: LSYImageView = {

        let image = LSYImageView()
        image.lsyimageDelegate = self
        image.contentMode = .ScaleAspectFill
        return image
    }()
    
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        
        return scro
    }()

    private lazy var progressView: LSYProgressView = LSYProgressView()
    private func calculateImageFrame(image : UIImage) {
      
        let imageWidth = UIScreen.mainScreen().bounds.width
        let imageHeight = image.size.height / image.size.width * imageWidth
     
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
      
        scrollView.contentSize = CGSize(width: imageWidth, height: imageHeight)
       
        if imageHeight < UIScreen.mainScreen().bounds.height { // 短图
          
            let topInset = (UIScreen.mainScreen().bounds.height - imageHeight) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        } else { // 长图
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    // 复位
    private func reset()
    {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
        imageView.transform = CGAffineTransformIdentity
    }

    deinit {
        
        print("死")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LSYPhotoCollectionViewCell : UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        UIView.animateWithDuration(0.2) { 
            var offsetX = (UIScreen.mainScreen().bounds.width - view!.frame.width) * 0.5
            var offsetY = (UIScreen.mainScreen().bounds.height - view!.frame.height) * 0.5
            offsetX = offsetX < 0 ? 0 : offsetX
            offsetY = offsetY < 0 ? 0 : offsetY
            
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    }
}

extension LSYPhotoCollectionViewCell: LSYImageViewDelegate
{
    func handleImageDisMiss(ges: UITapGestureRecognizer) {
        cellDelegate?.disMissViewController()
    }
    
    func handleImageViewDoubleTap(ges: UITapGestureRecognizer) {
        let touchPoint = ges.locationInView(ges.view)
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            
            scrollView.zoomToRect(zoomRectForScrollViewWith(scrollView.maximumZoomScale, touchPoint: touchPoint), animated: true)
        }
    }
    
    func zoomRectForScrollViewWith(scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (w / 2.0)
        let y = touchPoint.y - (h / 2.0)
        
        return CGRect(x: x, y: y, width: w, height: h)
    }

}
