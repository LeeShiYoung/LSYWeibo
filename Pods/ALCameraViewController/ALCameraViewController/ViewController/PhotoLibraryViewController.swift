//
//  ALImagePickerViewController.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos


internal let ImageCellIdentifier = "ImageCell"
internal let CameraCellIdentifier = "CameraCell"

internal let defaultItemSpacing: CGFloat = 1

public typealias PhotoLibraryViewSelectionComplete = (asset: PHAsset?) -> Void

public typealias PhotoLibraryViewSelectionAssetsComplete = (assets: [PHAsset], photoGraph: UIImage?) -> Void

public typealias OpenCameraComplete = () -> Void

public class PhotoLibraryViewController: UIViewController {

    static let manger: PhotoLibraryViewController = {
        return PhotoLibraryViewController()
    }()
    
    class func photoManger() -> PhotoLibraryViewController
    {
        return manger
    }
    var selectAssets: [PHAsset]?
//    var selectTag: [Int]?
    
    
    private var assets: PHFetchResult? = nil
    
    public var onSelectionComplete: PhotoLibraryViewSelectionComplete?
    
    public var onSelectionAssetsComplete: PhotoLibraryViewSelectionAssetsComplete?
    
//    public var onOpenCameraComplete: OpenCameraComplete?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CameraGlobals.shared.photoLibraryThumbnailSize
        layout.minimumInteritemSpacing = defaultItemSpacing
        layout.minimumLineSpacing = defaultItemSpacing
        layout.sectionInset = UIEdgeInsetsZero
      
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.whiteColor()
        return collectionView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        selectAssets = [PHAsset]()
//        selectTag = [Int]()
        setNeedsStatusBarAppearanceUpdate()
        
//        let buttonImage = UIImage(named: "libraryCancel", inBundle: CameraGlobals.shared.bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PhotoLibraryViewController.close))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一步", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PhotoLibraryViewController.next))
      
        navigationItem.rightBarButtonItem?.enabled = false
        view.backgroundColor = UIColor(white: 0.2, alpha: 1)
        view.addSubview(collectionView)
        
        ImageFetcher()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }
    

    
    @objc private func close() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func next() {

        onSelectionAssetsComplete?(assets: selectAssets!, photoGraph: nil)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    public func present(inViewController: UIViewController, animated: Bool) {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.barTintColor = UIColor.redColor()
        navigationController.navigationBar.barStyle = UIBarStyle.Default
        inViewController.presentViewController(navigationController, animated: animated, completion: nil)
    }
    
    public func dismiss() {
        onSelectionComplete?(asset: nil)
    }
    
    private func onSuccess(photos: PHFetchResult) {
        assets = photos
        configureCollectionView()
    }
    
    private func onFailure(error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        permissionsView.titleLabel.text = localizedString("permissions.library.title")
        permissionsView.descriptionLabel.text = localizedString("permissions.library.description")
        
        view.addSubview(permissionsView)
    }
    
    private func configureCollectionView() {
        collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.registerClass(CameraCollectionViewCell.self, forCellWithReuseIdentifier: CameraCellIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
//    private func itemAtIndexPath(indexPath: NSIndexPath) -> PHAsset? {
//        return assets?[indexPath.row] as? PHAsset
//    }
    
    private func itemAtIndexPath(index: Int) -> PHAsset? {
        return assets?[index-1] as? PHAsset
        
    }
    
    private lazy var animatior: PopAnimatior = {
        let anitor = PopAnimatior(presentCompletion: { (toView, duration, context) in
            
            self.presentAnimation(toView, duration: duration, context: context)
            }, dismissCompletion: { (fromView, duration, context) in
              
                self.disMissAnimation(fromView, duration: duration, context: context)
        })
        return anitor
    }()
}

// MARK: - UICollectionViewDataSource -
extension PhotoLibraryViewController : UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return assets?.count ?? 1
    
        return assets?.count == nil ? 1 : assets!.count + 1
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if cell is CameraCollectionViewCell {
            
            (cell as! CameraCollectionViewCell).delegate = self
        }
        
        if cell is ImageCell {
//             if let model = itemAtIndexPath(indexPath) {
            if let model = itemAtIndexPath(indexPath.item) {
                (cell as! ImageCell).configureWithModel(model)
                (cell as! ImageCell).selectBtn.tag = indexPath.item+2000
                (cell as! ImageCell).delegate = self

            }
        }
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        return indexPath.item == 0 ? collectionView.dequeueReusableCellWithReuseIdentifier(CameraCellIdentifier, forIndexPath: indexPath) : collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellIdentifier, forIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegate -
extension PhotoLibraryViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        onSelectionComplete?(asset: itemAtIndexPath(indexPath.item))
//        onSelectionComplete?(asset: selectAssets)
    }
}


// MARK: - ImageCellDelegate
extension PhotoLibraryViewController: ImageCellDelegate, CameraCellDelegate
{
    // 当前选中
    func selectAsset(tag: Int) {

        let asset = itemAtIndexPath(tag)
        selectAssets!.append(asset!)
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    // 移除选中
    func removeAsset(tag: Int) {

        let asset = assets?[tag] as? PHAsset
        selectAssets!.removeAtIndex(selectAssets!.indexOf(asset!)!)
        selectAssets?.count == 0 ? (navigationItem.rightBarButtonItem?.enabled = false) : (navigationItem.rightBarButtonItem?.enabled = true)
    }
    
    // 打开相机
    func openCamera() {
        let cameraVC = CameraManagerViewController { (image) in
            self.dismissViewControllerAnimated(false, completion: nil)
            self.onSelectionAssetsComplete?(assets: [], photoGraph: image)
        }
        
        let naviVC = UINavigationController(rootViewController: cameraVC)
        
        naviVC.transitioningDelegate = animatior
        naviVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(naviVC, animated: true, completion: nil)
    }
    
    // 出现动画
    private func presentAnimation(toView: UIView?, duration: NSTimeInterval, context: UIViewControllerContextTransitioning)
    {
        let y = -UIScreen.mainScreen().bounds.size.height
        
        toView?.frame.origin.y = y
        UIView.animateWithDuration(duration, animations: {
            self.view.frame.origin.y = -y
            toView?.frame.origin.y = 0.0
        }) { (_) in
            context.completeTransition(true)
        }
    }
    
    // 消失动画
     private func disMissAnimation(fromView: UIView?, duration: NSTimeInterval, context: UIViewControllerContextTransitioning)
     {
        let y = -UIScreen.mainScreen().bounds.size.height
        
        UIView.animateWithDuration(duration, animations: {
            self.view.frame.origin.y = 0
            fromView?.frame.origin.y = y
        }) { (_) in
            context.completeTransition(true)
        }
    }
}


