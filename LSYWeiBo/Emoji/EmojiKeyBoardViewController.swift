//
//  EmojiKeyBoardViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/21.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

private let EmojiReuseIdentifier = "EmojiReuseIdentifier"
//MARK: - 表情键盘控制器
class EmojiKeyBoardViewController: UIViewController {
    
    // 监听表情键盘点击回调
    var selectEmojiCallback: (emoticon: Emoticon) -> ()
    
    init(callBack: (emoticon: Emoticon) -> ()) {
        
        self.selectEmojiCallback = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        // 注册 
        collectionView.registerClass(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiReuseIdentifier)
        
        // 添加约束
        collectionView.snp_makeConstraints { (make) in
            
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(toolBar.snp_top)
        }
        
        toolBar.snp_makeConstraints { (make) in
            
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(44)
            make.bottom.equalTo(view.snp_bottom)
        }
    }
    
    // 滚动到指定组
    var tempItem: UIBarButtonItem?
    @objc private func turnSelectGroup(item: UIBarButtonItem) {
        
        if let temp = tempItem {
 
            temp.tintColor = UIColor.darkGrayColor()
        }
        
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0 ,inSection: item.tag), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
        item.tintColor = UIColor.orangeColor()
        
        tempItem = item
    }
    
    // 初始化 collectionView
    private lazy var collectionView: UICollectionView = {
        let cl = UICollectionView(frame: CGRectZero, collectionViewLayout: FlowLayout())
        cl.backgroundColor = UIColor.whiteColor()
        cl.dataSource = self
        cl.delegate = self
        return cl
    }()
    
    // 初始化 toolBar
    private lazy var toolBar: UIToolbar = {
        
        let tool = "EmojiToolBar".loadNib(self) as! UIToolbar
        for item in tool.items! {
            // 绑定点击事件
            item.action = #selector(EmojiKeyBoardViewController.turnSelectGroup(_:))
            item.target = self
        }
        return tool
    }()
    
    // 表情模型
    private lazy var emPackage: [EmoticonPackage] = EmoticonPackage.emptionsPackageManger
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EmojiKeyBoardViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let emtions = emPackage[section];
        return emtions.emoticons?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EmojiReuseIdentifier, forIndexPath: indexPath) as! EmojiCollectionViewCell
        let emoticion = emPackage[indexPath.section]
        cell.emoticon = emoticion.emoticons![indexPath.item];
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return emPackage.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let emoticon = emPackage[indexPath.section].emoticons![indexPath.item];
        emoticon.times += 1
        emPackage[0].latelyUse(emoticon)
        selectEmojiCallback(emoticon: emoticon)
    }
}

// MARK - UICollectionViewFlowLayout
private class FlowLayout: UICollectionViewFlowLayout {
    
    private override func prepareLayout() {
        super.prepareLayout()
        
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        let w = collectionView!.bounds.size.width / CGFloat(7)
        itemSize = CGSize(width: w, height: w)
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}

// MARK - 自定义cell
private class EmojiCollectionViewCell: UICollectionViewCell
{
    var emoticon: Emoticon? {
        
        didSet{
            
            // png表情
            if emoticon?.chs != nil {
                
                emojiBtn.setImage(UIImage(contentsOfFile: emoticon!.pngPath!), forState: UIControlState.Normal)
            } else {
                
                emojiBtn.setImage(nil, forState: UIControlState.Normal)
            }
            
            // emoji表情
            emojiBtn.setTitle(emoticon?.emojiStr ?? "", forState: UIControlState.Normal)
         
            // 删除按钮
            if emoticon!.removeBtn
            {
                emojiBtn.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                emojiBtn.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    private func setUI() {
        
        contentView.addSubview(emojiBtn)
        emojiBtn.frame = contentView.bounds
        emojiBtn.backgroundColor = UIColor.whiteColor()
        emojiBtn.frame = CGRectInset(contentView.bounds, 4, 4)
       
    }
    
    private lazy var emojiBtn: UIButton = {
        let b = UIButton(type: UIButtonType.Custom)
        b.titleLabel?.font = UIFont.systemFontOfSize(32)
        b.userInteractionEnabled = false
        return b
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

