//
//  HomeNormalTableViewCell.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/10.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import HYLabel

enum CellReuseIdentifier: String {
    case original = "originalIdentifier"
    case forward = "forwardIdentifier"
    case line = "recordLine"
    
    case originalBody = "originalBodyIdentifier"
    case forwardBody = "forwardBodyIdentifier"
    
    // 获取 cell 重用标示
    static func cellID(statues: Statuses) -> String {
       
       return statues.retweeted_status != nil ? CellReuseIdentifier.forward.rawValue : CellReuseIdentifier.original.rawValue
    }
    
    static func bodyCellID(statues: Statuses) -> String {
        
        return statues.retweeted_status != nil ? CellReuseIdentifier.forwardBody.rawValue : CellReuseIdentifier.originalBody.rawValue
    }
}

protocol HomeTableViewCellDelegate: NSObjectProtocol {
    func downBtnDidSelected(btn: UIButton)
    func linkTap(link: String)
    func forwardBtnClick(cell: HomeTableViewCell)
}

class HomeTableViewCell: UITableViewCell {

    weak var delegate: HomeTableViewCellDelegate?
    
    var statues: Statuses?
    {
        didSet{
            
            topView.statues = statues
            pictureView.statues = statues
            pic_size = pictureView.calculationPicSize()
            
            pictureView.snp_updateConstraints { (make) in
                make.height.equalTo(pic_size!.height).priorityHigh()
                make.width.equalTo(pic_size!.width).priorityHigh()
                
                pic_size!.height == 0 ? make.bottom.equalTo(bottomView.snp_top).priorityHigh() : make.bottom.equalTo(bottomView.snp_top).offset(-10).priorityHigh()
            }
            
            bottomView.status = statues
            
            // 微博正文 重新布局
            if statues!.statusBody {

                bottomView.subviews.forEach({ (subview) in
                    subview.removeFromSuperview()
                    subview.snp_removeConstraints()
                })
                
                bottomView.snp_updateConstraints(closure: { (make) in
                    make.height.equalTo(0)
                })
            }
        }
    }
    
    var pic_size: CGSize?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUI()
        
        // MARK: - downBtnWillClick
        topView.downComplete = {[weak self] btn in
            
            self!.delegate?.downBtnDidSelected(btn)
        }
        
        // MARK: - 网页链接
        topView.linkComplete = {[weak self] link in
            
            self!.delegate?.linkTap(link)
        }
        
        // MARK: - 转发
        forwardView.touchHandler = {[weak self] in
            self!.delegate?.forwardBtnClick(self!)
        }
    }

    // 布局
    func setUI() {
    
        contentView.addSubview(topView)
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)
        
        topView.snp_makeConstraints { (make) in
            make.top.equalTo(contentView.snp_top)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
        }
    }

    // 顶部
    lazy var topView: TopView = "TopView".loadNib(self) as! TopView
    
    // 配图
    lazy var pictureView: PictureView = PictureView()
    
    // 底部
    lazy var bottomView: BottomView = "BottomView".loadNib(self) as! BottomView
    
    // 转发背景
    lazy var forwardView = ForwardView()
    
    // 转发内容
    lazy var forwardContent: HYLabel = {
        let label = HYLabel()
        label.numberOfLines = 0
        label.textColor = UIColor.darkGrayColor()
        label.opaque = true
        label.backgroundColor = color
        return label
    }()
}

let color: UIColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
let hightColor: UIColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1)

class ForwardView: UIView {
   
    private typealias touchEndHandler = () -> Void
    private var touchHandler: touchEndHandler?
    
    init() {
        super.init(frame: CGRectZero)
        self.backgroundColor = color
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = hightColor
   
        self.subviews.forEach { (view) in
            view.backgroundColor = hightColor
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = color
        self.subviews.forEach { (view) in
            view.backgroundColor = color
        }
        touchHandler!()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.backgroundColor = color
        self.subviews.forEach { (view) in
            view.backgroundColor = color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
