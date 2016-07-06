//
//  ImageCell.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

private let w:CGFloat = 30.0

protocol ImageCellDelegate: NSObjectProtocol {
    
    func selectAsset(tag: Int)
    func removeAsset(tag: Int)
}
class ImageCell: UICollectionViewCell {
    
    weak var delegate: ImageCellDelegate?
    
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "placeholder",
                                  inBundle: CameraGlobals.shared.bundle,
                                  compatibleWithTraitCollection: nil)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(selectBtn)
        selectBtn.frame = CGRect(x: contentView.frame.width - w - 2, y: 2, width: w, height: w)
    }
    
    // MARK: - action
    @objc private func selectPicture(btn: UIButton)
    {
        
        btn.selected = !btn.selected
        
        btn.selected ? delegate?.selectAsset(btn.tag-2000) : delegate?.removeAsset(btn.tag-2000-1)
    }
    
    lazy var selectBtn: UIButton = {
       
        let btn = UIButton()
      
        btn.setImage(UIImage(named: "compose_guide_check_box_default"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "compose_photo_preview_right"), forState: UIControlState.Selected)
        btn.addTarget(self, action: #selector(ImageCell.selectPicture(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "placeholder",
                                  inBundle: CameraGlobals.shared.bundle,
                                  compatibleWithTraitCollection: nil)
    }
    
    func configureWithModel(model: PHAsset) {
        
        if tag != 0 {
            PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(tag))
        }
        
        tag = Int(PHImageManager.defaultManager().requestImageForAsset(model, targetSize: contentView.bounds.size, contentMode: .AspectFill, options: nil) { image, info in
            self.imageView.image = image

        })
    }
}
