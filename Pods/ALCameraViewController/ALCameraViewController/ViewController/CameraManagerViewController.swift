//
//  CameraManagerViewController.swift
//  Pods
//
//  Created by 李世洋 on 16/6/12.
//
//

import UIKit
import CameraManager
import SnapKit

class CameraManagerViewController: UIViewController {
    
    var cameraOpenOrClose = false
    let cameraManager = CameraManager()

    var photoGraphCompletion: (image: UIImage) -> Void
    
    init(photoGraphComplete: (image: UIImage) -> Void) {
        self.photoGraphCompletion = photoGraphComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
   
        LSYStruct.delay(1) {
            
            self.cameraManager.showAccessPermissionPopupAutomatically = false
            let currentCameraState = self.cameraManager.currentCameraStatus()
            
            if currentCameraState == .NoDeviceFound {
                print("没有摄像头")
                
            } else if (currentCameraState == .Ready) {
                self.addCameraToView()
            }
            if !self.cameraManager.hasFlash {
                self.flashModeButton.enabled = false
                self.flashModeButton.setTitle("No flash", forState: UIControlState.Normal)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        if !cameraOpenOrClose {
    
            view.backgroundColor = UIColor.whiteColor()
            cameraManager.resumeCaptureSession()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }
    
    private func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.StillImage)
      
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
            
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // 布局
    private func setUpUI()
    {
        self.title = "拍照"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: .close)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
        
        view.addSubview(bottomView)
        view.addSubview(cameraView)
        bottomView.addSubview(recordButton)
        customView.addSubview(flashModeButton)
        customView.addSubview(changeButton)
        cameraView.addSubview(maskView)

        flashModeButton.snp_makeConstraints { (make) in
            make.left.equalTo(customView.snp_left)
            make.centerX.equalTo(customView.snp_centerX)
        }
        changeButton.snp_makeConstraints { (make) in
            make.right.equalTo(customView.snp_right)
            make.centerX.equalTo(customView.snp_centerX)
        }
        
        bottomView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(100.0)
        }
        
        recordButton.snp_makeConstraints { (make) in
            make.center.equalTo(bottomView.snp_center)
        }
        
        cameraView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(view)
            make.bottom.equalTo(bottomView.snp_top)
        }
    }

    @objc private func close() {
     
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func photograph() {
         switch (cameraManager.cameraOutputMode) {
         case .StillImage :
            cameraManager.capturePictureWithCompletition({[weak self] (image, error) -> Void in
                
               let confirmVC = ConfirmViewController(image: image, allowsCropping: false, mode: PhotosMode.graph)
                confirmVC.onComplete = {[weak self] image, asset in
                    
                    if let image = image {
                       
                        self!.cameraOpenOrClose = true
                        self!.navigationController?.popViewControllerAnimated(false)
                        self!.photoGraphCompletion(image: image)
                        
                    } else {
                        self!.navigationController?.popViewControllerAnimated(false)
                    }
                }
             
                self!.navigationController?.pushViewController(confirmVC, animated: true)
                
            })
         case .VideoWithMic, .VideoOnly: break
            
        }
    }

    private lazy var customView: UIView = {
       let cv = UIView()
        cv.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        return cv
    }()

    // 闪关灯
    private lazy var flashModeButton: UIButton = {
        let btn = UIButton()
    
        btn.setImage(UIImage(named: "flashAutoIcon",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                     forState: .Normal)
        return btn
    }()
    
    // 切换摄像头
    private lazy var changeButton: UIButton = {
        let btn = UIButton()
    
        btn.setImage(UIImage(named: "swapButton",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                     forState: .Normal)
        
        return btn
    }()
    
    // 拍照
    private lazy var recordButton: UIButton = {
        
       let path = NSBundle.mainBundle().pathForResource("cameraButton", ofType: nil)
        let btn = UIButton(type: UIButtonType.Custom)
        btn.setImage(UIImage(named: "cameraButton",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                     forState: .Normal)
        btn.setImage(UIImage(named: "cameraButtonHighlighted",
            inBundle: CameraGlobals.shared.bundle,
            compatibleWithTraitCollection: nil),
                     forState: .Highlighted)

        btn.addTarget(self, action: .photograph, forControlEvents: .TouchUpInside)
        return btn
    }()

    // 图像显示区域
    private lazy var cameraView: UIView = UIView()
    
    // 底部
    private lazy var bottomView: UIView = UIView()
    
    // 显示区域蒙版
    private lazy var maskView: UIView = {
        let mask = UIView()
        mask.backgroundColor = UIColor.redColor()
        return mask
    }()
 
    deinit
    {
        print("CameraManagerViewController 死")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Selector {
    static let photograph = #selector(CameraManagerViewController.photograph)
    static let close = #selector(CameraManagerViewController.close)
}
