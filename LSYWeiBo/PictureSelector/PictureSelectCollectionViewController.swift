//
//  PictureSelectCollectionViewController.swift
//  PictureSelector
//
//  Created by 李世洋 on 16/5/30.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import ALCameraViewController
import Photos

private let PictureSelectorReuseIdentifier = "PictureSelectorReuseIdentifier"

protocol PictureSelectorDelegate: NSObjectProtocol {
    
    func disMiss()
    func updateEnabled(enabled: Bool)
}

class PictureSelectCollectionViewController: UICollectionViewController {
    
    // 照片模型
    var pictures: [Pictures]?{
        didSet{
            collectionView?.reloadData()
        }
    }
    
    weak var delegate: PictureSelectorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictures = [Pictures]()
        pictures?.append(Pictures.addBtn())
        
    }
}

// MARK: - PictureButtonCellDelegate
extension PictureSelectCollectionViewController: PictureButtonCellDelegate
{
    func showPictureSelector(cell: PictureButtonCollectionViewCell?) {
        
        if let cell = cell {
            
            let indexpath = collectionView?.indexPathForCell(cell)
            let picture = pictures![indexpath!.item]
            if picture.isRemove {
                return
            }
        }
        
        // 初始化 照片选择器
        let libraryViewController = CameraViewController.imagesPickerViewController(false) { (images, assets, openCamera) in
            
            self.pictures?.removeLast()
            self.pictures = Pictures.loadPictures(images) + self.pictures!
            self.pictures?.append(Pictures.addBtn())
            
            // 发送可用
            self.delegate?.updateEnabled(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    /*
    // 打开相机
    private func openCamera() {
        let cameraViewController = CameraViewController(croppingEnabled: false, allowsLibraryAccess: false) { [weak self] image, asset in
            self!.pictures?.removeLast()
            self!.pictures?.append(Pictures.sheetPicture(image!))
            self!.pictures?.append(Pictures.addBtn())
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    */
    // 移除已经选中的
    func removeBtnClick(tag: Int) {
        
        pictures?.removeAtIndex(pictures!.indexOf(pictures![tag])!)
        if pictures?.count == 1 {
            delegate?.disMiss()
            
            // 发送不可用
            delegate?.updateEnabled(false)
        }
    }
}

// MARK: - UICollectionViewDataSoure
extension PictureSelectCollectionViewController
{
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PictureSelectorReuseIdentifier, forIndexPath: indexPath) as! PictureButtonCollectionViewCell
        
        cell.delegate = self
        cell.picture = pictures![indexPath.item]
        cell.removeButton.tag = indexPath.item + 3000
        return cell
    }
}
