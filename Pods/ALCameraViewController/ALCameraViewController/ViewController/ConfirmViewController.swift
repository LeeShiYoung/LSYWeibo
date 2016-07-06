//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public enum PhotosMode: Int {
    case preview = 0 // 默认预览
    case graph // 拍照预览
}
public class ConfirmViewController: UIViewController, UIScrollViewDelegate {
    
    lazy var imageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cropOverlay: CropOverlay!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var centeringView: UIView!
    var graphImage: UIImage?
    
    var allowsCropping: Bool = false
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    var modeType: PhotosMode?
    
    public var onComplete: CameraViewCompletion?
    
    var asset: PHAsset!
    
    public init(asset: PHAsset, allowsCropping: Bool, mode: PhotosMode) {
        self.allowsCropping = allowsCropping
        self.asset = asset
        self.modeType = mode
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
    }
    
    
    //MARK: - 增加初始化方法
    public init(image: UIImage?, allowsCropping: Bool, mode: PhotosMode) {
        self.allowsCropping = allowsCropping
        self.graphImage = image
        self.modeType = mode
        
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        switch modeType! {
        case .graph:
            return false
        case .preview:
            return true
        }
        return true
    }
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        switch modeType! {
        case .graph:
            print("拍照初始化")
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一步", style: UIBarButtonItemStyle.Plain, target: self, action: .next)
            view.backgroundColor = UIColor.whiteColor()
            
            configureWithImage(graphImage!)
            
        case .preview:
            view.backgroundColor = UIColor.blackColor()
 
            imageView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(ConfirmViewController.cancel))
            imageView.addGestureRecognizer(tap)
            
        }
        cancelButton.hidden = true
        cancelButton.enabled = false
        confirmButton.hidden = true
        confirmButton.enabled = false
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        cropOverlay.hidden = true
        
        guard let asset = asset else {
            return
        }

        switch modeType! {
        case .graph:
            return
        case .preview:
            let spinner = showSpinner()
            disable()
            SingleImageFetcher()
                .setAsset(asset)
                .setTargetSize(largestPhotoSize())
                .onSuccess { image in
                    self.configureWithImage(image)
                    self.hideSpinner(spinner)
                    self.enable()
                }
                .onFailure { error in
                    self.hideSpinner(spinner)
                }
                .fetch()
        }
    }
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let scale = calculateMinimumScale(view.frame.size)
        let frame = allowsCropping ? cropOverlay.frame : view.bounds
        
        scrollView.contentInset = calculateScrollViewInsets(frame)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        centerScrollViewContents()
        centerImageViewOnRotate()
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let scale = calculateMinimumScale(size)
        var frame = view.bounds
        
        if allowsCropping {
            frame = cropOverlay.frame
            let centeringFrame = centeringView.frame
            var origin: CGPoint
            
            if size.width > size.height { // landscape
                let offset = (size.width - centeringFrame.height)
                let expectedX = (centeringFrame.height/2 - frame.height/2) + offset
                origin = CGPoint(x: expectedX, y: frame.origin.x)
            } else {
                let expectedY = (centeringFrame.width/2 - frame.width/2)
                origin = CGPoint(x: frame.origin.y, y: expectedY)
            }
            
            frame.origin = origin
        } else {
            frame.size = size
        }
        
        coordinator.animateAlongsideTransition({ context in
            self.scrollView.contentInset = self.calculateScrollViewInsets(frame)
            self.scrollView.minimumZoomScale = scale
            self.scrollView.zoomScale = scale
            self.centerScrollViewContents()
            self.centerImageViewOnRotate()
            }, completion: nil)
    }
    
    private func configureWithImage(image: UIImage) {
        if allowsCropping {
            cropOverlay.hidden = false
        } else {
            cropOverlay.hidden = true
        }
        
        buttonActions()
        
        imageView.image = image
        imageView.sizeToFit()
        view.setNeedsLayout()
    }
    
    private func calculateMinimumScale(size: CGSize) -> CGFloat {
        var _size = size
        
        if allowsCropping {
            _size = cropOverlay.frame.size
        }
        
        guard let image = imageView.image else {
            return 1
        }
        
        let scaleWidth = _size.width / image.size.width
        let scaleHeight = _size.height / image.size.height
        
        var scale: CGFloat
        
        if allowsCropping {
            scale = max(scaleWidth, scaleHeight)
        } else {
            scale = min(scaleWidth, scaleHeight)
        }
        
        return scale
    }
    
    private func calculateScrollViewInsets(frame: CGRect) -> UIEdgeInsets {
        let bottom = view.frame.height - (frame.origin.y + frame.height)
        let right = view.frame.width - (frame.origin.x + frame.width)
        let insets = UIEdgeInsets(top: frame.origin.y, left: frame.origin.x, bottom: bottom, right: right)
        return insets
    }
    
    private func centerImageViewOnRotate() {
        if allowsCropping {
            let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
            let scrollInsets = scrollView.contentInset
            let imageSize = imageView.frame.size
            var contentOffset = CGPoint(x: -scrollInsets.left, y: -scrollInsets.top)
            contentOffset.x -= (size.width - imageSize.width) / 2
            contentOffset.y -= (size.height - imageSize.height) / 2
            scrollView.contentOffset = contentOffset
        }
    }
    
    private func centerScrollViewContents() {
        let size = allowsCropping ? cropOverlay.frame.size : scrollView.frame.size
        let imageSize = imageView.frame.size
        var imageOrigin = CGPoint.zero
        
        if imageSize.width < size.width {
            imageOrigin.x = (size.width - imageSize.width) / 2
        }
        
        if imageSize.height < size.height {
            imageOrigin.y = (size.height - imageSize.height) / 2
        }
        
        imageView.frame.origin = imageOrigin
    }
    
    private func buttonActions() {
        confirmButton.action = { [weak self] in self?.confirmPhoto() }
        cancelButton.action = { [weak self] in self?.cancel() }
    }
    
    internal func cancel() {
        onComplete?(nil, nil)
    }
    
    internal func confirmPhoto() {
        
        disable()
        
        imageView.hidden = true
        
        if graphImage != nil {
            self.onComplete?(graphImage, nil)
            return
        }
        
        let spinner = showSpinner()
        
        let fetcher = SingleImageFetcher()
            .onSuccess { image in
                
                switch self.modeType! {
                case .preview:
                    print("默认")
                    
                case .graph:
                    print("拍照")
                    self.onComplete?(self.graphImage, self.asset)
                }
                
                self.hideSpinner(spinner)
                self.enable()
            }
            .onFailure { error in
                self.hideSpinner(spinner)
                self.showNoImageScreen(error)
            }
            .setAsset(asset)
        
        if allowsCropping {
            
            var cropRect = cropOverlay.frame
            cropRect.origin.x += scrollView.contentOffset.x
            cropRect.origin.y += scrollView.contentOffset.y
            
            let normalizedX = cropRect.origin.x / imageView.frame.width
            let normalizedY = cropRect.origin.y / imageView.frame.height
            
            let normalizedWidth = cropRect.width / imageView.frame.width
            let normalizedHeight = cropRect.height / imageView.frame.height
            
            let rect = normalizedRect(CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight), orientation: imageView.image!.imageOrientation)
            
            fetcher.setCropRect(rect)
        }
        
        fetcher.fetch()
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .White
        spinner.center = view.center
        spinner.startAnimating()
        
        view.addSubview(spinner)
        view.bringSubviewToFront(spinner)
        
        return spinner
    }
    
    func hideSpinner(spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    func disable() {
        confirmButton.enabled = false
    }
    
    func enable() {
        confirmButton.enabled = true
    }
    
    func showNoImageScreen(error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        
        let desc = localizedString("error.cant-fetch-photo.description")
    
        permissionsView.configureInView(view, title: error.localizedDescription, descriptiom: desc, completion: cancel)
    }
    
    deinit
    {
        print("ConfirmViewController 死")
    }
}

private extension Selector
{
    static let next = #selector(ConfirmViewController.confirmPhoto)
}