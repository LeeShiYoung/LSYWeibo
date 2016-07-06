//
//  NewfeatureCollectionViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/4.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NewfeatureCollectionViewCell"
private let pageCount = 4
class NewfeatureCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
}
// MARK: UICollectionViewDataSource
extension NewfeatureCollectionViewController
{
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NewfeatureCollectionViewCell
        cell.pageIndex = indexPath.item
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let path = collectionView.indexPathsForVisibleItems().last
        let cell = collectionView.cellForItemAtIndexPath(path!) as! NewfeatureCollectionViewCell
        cell.startAnimation()
        
    }
}

// MARK: UICollectionViewCell
class NewfeatureCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    var pageIndex:Int? {
        didSet{
            startButton.hidden = true
            imageView.image = UIImage(named: "new_feature_\(pageIndex! + 1)")
        }
    }
    
    // 进入主页面
    @IBAction func startButtonClick(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(AppdelegateNotifiKey, object: true)
        
         }
    
        //执行动画
        func startAnimation() {
            
            if pageIndex == 3 {
                startButton.hidden = false
                startButton.transform = CGAffineTransformMakeScale(0, 0)
                
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                    self.startButton.transform = CGAffineTransformIdentity
                    }, completion: { (_) in
                        
                })
            }
        }
    }
    
    // MARK: UICollectionViewFlowLayout
    class NewfeatureFlowLayout: UICollectionViewFlowLayout {
        
        override func prepareLayout() {
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            itemSize = UIScreen.mainScreen().bounds.size
        }
}

