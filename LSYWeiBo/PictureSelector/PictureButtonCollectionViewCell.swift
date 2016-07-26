//
//  PictureButtonCollectionViewCell.swift
//  PictureSelector
//
//  Created by 李世洋 on 16/5/30.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

protocol PictureButtonCellDelegate: NSObjectProtocol {
    
    func showPictureSelector(cell: PictureButtonCollectionViewCell?)
    func removeBtnClick(tag: Int)
}
class PictureButtonCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PictureButtonCellDelegate?
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var removeButton: UIButton!
    
    var picture: Pictures? {
        didSet{
           selectedImage.image = picture?.image
            picture?.isRemove == false ? isRemoveBtn() : unRemoveBtn()
            
        }
    }
    
    func isRemoveBtn() {
        removeButton.hidden = true
        removeButton.enabled = false
    }
    
    func unRemoveBtn() {
        removeButton.hidden = false
        removeButton.enabled = true
    }
    
    @IBAction func removeBtnClick(sender: UIButton) {
        delegate?.removeBtnClick(sender.tag - 3000)
    }
    
    @objc private func selectedBtnClick(sender: UIButton) {

        delegate?.showPictureSelector(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        selectedImage.userInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: .selectedBtnClick)
        selectedImage.addGestureRecognizer(tapGes)
    }
}

class PictureSelectorFlowLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        let margin:CGFloat = 5
        let screenMargin:CGFloat = 20
         sectionInset = UIEdgeInsets(top: 10, left: screenMargin, bottom: 10, right: screenMargin)
        
        let w = collectionView?.frame.size.width
        let size = (w! - (margin*2 + screenMargin*2)) / 3
        itemSize = CGSize(width: size, height: size)
        
        minimumLineSpacing = margin
        minimumInteritemSpacing = margin
    }
}

private extension Selector {
    static let selectedBtnClick = #selector(PictureButtonCollectionViewCell.selectedBtnClick(_:))
}