//
//  QRViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/2.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SwiftQRCode
import FDFullscreenPopGesture

class QRViewController: UIViewController {
    
    let scanner = QRCode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fd_prefersNavigationBarHidden = true
        scanner.prepareScan(view) {[weak self] (stringValue) -> () in
            
            print(stringValue)
            let webVC = WebViewController()
            webVC.hidesBottomBarWhenPushed = true
            webVC.loadString = stringValue
            self!.navigationController?.pushViewController(webVC, animated: true)
        }
        
        scanner.scanFrame = overlayView.getFrame()
        
        setUpOverlay()
        setUpUI()
    }
    
    @objc private func closeBtnClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func openAlbumClick() {
        print("打开相册")
    }
    
    @objc private func myCardBtnClick() {
        
    }
    
    // OverlayView
    private lazy var overlayView: OverlayView = OverlayView()
    
    // 我的名片
    private lazy var myCardBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("我的名片", forState: .Normal)
        btn.setTitleColor(UIColor.orangeColor(), forState: .Normal)
         btn.addTarget(self, action: .myCard, forControlEvents: .TouchUpInside)
        return btn
    }()
    
    // 自定义导航条
    private lazy var customBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0.5
        return view
    }()
    
    // 关闭
    private lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("关闭", forState: .Normal)
        btn.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        btn.addTarget(self, action: .close, forControlEvents: .TouchUpInside)
        return btn
    }()
    
    // 相册
    private lazy var albumBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("相册", forState: .Normal)
        btn.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        btn.addTarget(self, action: .openAlbum, forControlEvents: .TouchUpInside)
        return btn
    }()
    
    // 扫一扫
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "扫一扫"
        lab.textColor = UIColor.whiteColor()
        return lab
    }()
    
    private func setUpOverlay() {
        
        view.addSubview(overlayView)
        overlayView.snp_makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(view)
        }
    }

    private func setUpUI() {
        
        view.addSubview(myCardBtn)
        myCardBtn.snp_makeConstraints { (make) in
            make.bottom.equalTo(view.snp_bottom).offset(-20)
            make.centerX.equalTo(view.snp_centerX)
        }
       
        // 导航条
        view.addSubview(customBar)
        customBar.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(64)
        }
        
        customBar.addSubview(closeBtn)
        closeBtn.snp_makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(20)
        }
        
        customBar.addSubview(albumBtn)
        albumBtn.snp_makeConstraints { (make) in
            make.right.equalTo(view.snp_right).offset(-10)
            make.top.equalTo(closeBtn.snp_top)
        }
        
        customBar.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(customBar.snp_centerX)
            make.top.equalTo(closeBtn.snp_top).offset(5)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.whiteColor()
        scanner.startScan()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        scanner.stopScan()
    }
}

private extension Selector {
    static let close = #selector(QRViewController.closeBtnClick)
    static let openAlbum = #selector(QRViewController.openAlbumClick)
    static let myCard = #selector(QRViewController.myCardBtnClick)
}
