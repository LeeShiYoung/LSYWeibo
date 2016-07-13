//
//  LSYPhotoBrowserViewController2.swift
//  LSYPhotoBrowser
//
//  Created by 李世洋 on 16/7/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "LSYCell"

class LSYPhotoBrowserViewController: UICollectionViewController {

    // 图片模型
    var photos: [LSYPhoto]?
    // 当前页
    var indexPath: NSIndexPath?
    
    var fromViewE: UIView?
  
    // flowLayout
    private var layout = LSYFlowLayout()
    
    init(photos: [LSYPhoto], indexPath: NSIndexPath, animationedFromView: UIView) {
        super.init(collectionViewLayout: layout)
        
        self.photos = photos
        self.indexPath = indexPath
        self.transitioningDelegate = transitior
        self.fromViewE = animationedFromView
        UIApplication.sharedApplication().statusBarHidden = true
        transitior.setInfo(self, indexPath: self.indexPath)
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.registerClass(LSYPhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // 滚到选中位置
       
        collectionView?.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .CenteredHorizontally, animated: false)
    }
    
    // 转场动画的代理
    private lazy var transitior: LSYTransitionAnimator = LSYTransitionAnimator()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SDWebImageManager.sharedManager().cancelAll()
    }
    
    deinit {
     
        print("photobrowser 死")
    }
}

// MARK: UICollectionViewDataSource
extension LSYPhotoBrowserViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LSYPhotoCollectionViewCell
        cell.photo = photos![indexPath.item]
        cell.cellDelegate = self
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
     
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }   
}

extension LSYPhotoBrowserViewController: LSYTransitionAnimatorDelegate
{
    func imageViewForPresent(indexPath: NSIndexPath?) -> UIImageView {
    
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.sd_setImageWithURL(photos![indexPath!.item].thumbUrl, placeholderImage: UIImage(named: "empty_picture"))
        return imageView
    }
    
    func startAnimationFrame(indexPath: NSIndexPath?) -> CGRect {

        let rectFromCollection = {
            (fv: UICollectionView?) -> CGRect in
            guard let cell = fv!.cellForItemAtIndexPath(indexPath!) else {
                return CGRect(x: fv!.bounds.width * 0.5, y: UIScreen.mainScreen().bounds.height + 50, width: 0, height: 0)
            }
            return fv!.convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        }
        
        let rectFromTable = {
            (fv: UITableView?) -> CGRect in
            guard let cell = fv!.cellForRowAtIndexPath(indexPath!) else {
                return CGRect(x: fv!.bounds.width * 0.5, y: UIScreen.mainScreen().bounds.height + 50, width: 0, height: 0)
            }
            return fv!.convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        }
        return fromViewE != nil ? rectFromCollection(fromViewE?.superview as? UICollectionView) : rectFromTable(fromViewE?.superview as? UITableView)
    }
    
    func endAnimationFrame(indexPath: NSIndexPath?) -> CGRect {

        let url = photos![indexPath!.item].thumbUrl
        var image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(url!.absoluteString)
        
        if image == nil {
            image = UIImage(named: "empty_picture")
        }
        
        let screenW = UIScreen.mainScreen().bounds.width
        let screenH = UIScreen.mainScreen().bounds.height
        let imageH = screenW / image.size.width * image.size.height
        var y : CGFloat = 0
        if imageH < screenH {
            y = (screenH - imageH) * 0.5
        } else {
            y = 0
        }
        return CGRect(x: 0, y: y, width: screenW, height: imageH)
    }
    
    func imageViewForDismiss() -> UIImageView {
        let dismissImage = UIImageView()
        dismissImage.contentMode = .ScaleAspectFill
        dismissImage.clipsToBounds = true
    
        let cell = collectionView!.visibleCells()[0] as! LSYPhotoCollectionViewCell
        dismissImage.image = cell.imageView.image
        dismissImage.frame = cell.scrollView.convertRect(cell.imageView.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        return dismissImage
    }
    
    func indexForDisMiss() -> NSIndexPath {
        return collectionView!.indexPathsForVisibleItems().first!
    }
}

extension LSYPhotoBrowserViewController: LSYCellDelegate
{
    func disMissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

private class LSYFlowLayout: UICollectionViewFlowLayout {
    
    private override func prepareLayout() {
        itemSize = UIScreen.mainScreen().bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal

        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.pagingEnabled = true
    }
}
