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
                self.calculateImageFrame(image)
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
        scro.delegate = self
        scro.minimumZoomScale = 1.0
        scro.maximumZoomScale = 1.5
        return scro
    }()

    private lazy var progressView: LSYProgressView = LSYProgressView()
    private func calculateImageFrame(image : UIImage) {
        
       
        // 1.计算位置
        let imageWidth = UIScreen.mainScreen().bounds.width
        let imageHeight = image.size.height / image.size.width * imageWidth
        
        // 2.设置frame
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        // 3.设置contentSize
        scrollView.contentSize = CGSize(width: imageWidth, height: imageHeight)
        
        // 4.判断是长图还是短图
        if imageHeight < UIScreen.mainScreen().bounds.height { // 短图
            // 设置偏移量
            let topInset = (UIScreen.mainScreen().bounds.height - imageHeight) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        } else { // 长图
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
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
        var topInset = (scrollView.bounds.height - view!.frame.size.height) * 0.5
        topInset = topInset < 0 ? 0 : topInset
        
        var leftInset = (scrollView.bounds.width - view!.frame.size.width) * 0.5
        leftInset = leftInset < 0 ? 0 : leftInset
        
        scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: 0, right: 0)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
       
        
    }
}

extension LSYPhotoCollectionViewCell: LSYImageViewDelegate
{
    func tapDisMiss() {
        cellDelegate?.disMissViewController()
    }
    
    func handleImageViewDoubleTap(view: UIImageView, touch: UITouch) {
      let touchPoint = touch.locationInView(view)
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // zoom out
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
