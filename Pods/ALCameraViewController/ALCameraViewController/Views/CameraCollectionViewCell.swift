//
//  CameraCollectionViewCell.swift
//  Pods
//
//  Created by 李世洋 on 16/6/2.
//
//

import UIKit

protocol CameraCellDelegate: NSObjectProtocol {
   func openCamera()
    
}
class CameraCollectionViewCell: UICollectionViewCell {
    

    weak var delegate: CameraCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cameraBtn)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cameraBtn.frame = contentView.bounds
    }
    
    private lazy var cameraBtn: UIButton = {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: "compose_camerabutton_background"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "compose_camerabutton_background_highlighted"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action: #selector(CameraCollectionViewCell.openCamera), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    
    @objc private func openCamera()
    {
        delegate?.openCamera()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
