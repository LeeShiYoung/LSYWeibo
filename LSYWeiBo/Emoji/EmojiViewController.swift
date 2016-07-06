//
//  EmojiViewController.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/21.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SVProgressHUD

class EmojiViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    // 发送按钮
    @IBOutlet weak var sendBtn: UIBarButtonItem!
    
    // 发送
    @IBAction func send(sender: UIBarButtonItem) {
        
        NetWorkTools.sendStatues(pictureSelector.pictures!, status: textView.emojiAttributedString(), success: {
            // 通知刷新
            NSNotificationCenter.defaultCenter().postNotificationName(UpdateStatuesNotiKey, object: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }) {
            SVProgressHUD.showError("发送失败")
        }
    }
    
    // 取消
    @IBAction func close(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 监听键盘
        addKeyBoardNotiCenter()
        
        // 获取用户名
        nameLabel.text = UserAccount.loadAccount()?.screen_name
        
        // 拖动时键盘消失
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        addChildViewController(emojiKeyBoard)
        addChildViewController(pictureSelector)
        
        // toolBar
        setUpToolBar()
        setupPictureSelector()
        
    }
    
    // 切换照片选择器
    @objc private func selectPicture() {
        
        if pictureSelector.view.frame.size.height != 0 {
            return
        }
        
        textView.resignFirstResponder()
        pictureSelector.showPictureSelector(nil)
        
        LSYStruct.delay(1.0) {
            self.pictureSelector.view.snp_remakeConstraints { (make) in
                make.left.right.bottom.equalTo(self.view)
                make.height.equalTo(self.view.snp_height).multipliedBy(0.7).priorityLow()
            }
        }
    }
    
    // 切换表情键盘
    @objc private func inputEmoticon(item: UIButton) {
        
        textView.resignFirstResponder()
        
        textView.inputView == nil ? item.setUpInfo("compose_keyboardbutton_background") : item.setUpInfo("compose_emoticonbutton_background")
        textView.inputView = textView.inputView == nil ? emojiKeyBoard.view : nil
        textView.becomeFirstResponder()
    }
    
    // 设置pictureSelector
    private func setupPictureSelector() {
        
        view.insertSubview(pictureSelector.view, belowSubview: tooBar)
        
        pictureSelector.view.snp_makeConstraints { (make) in
            
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(view.snp_height).multipliedBy(0.0).priorityLow()
        }
    }
    
    
    // 设置toolBar
    private func setUpToolBar() {
        
        // 布局toolBar
        view.addSubview(tooBar)
        tooBar.snp_makeConstraints { (make) in
            
            make.left.right.bottom.equalTo(view)
        }
        
        view.addSubview(tipLabel)
        tipLabel.snp_makeConstraints { (make) in
            
            make.right.equalTo(view).offset(-10)
            make.bottom.equalTo(tooBar.snp_top).offset(-10)
        }
    }
    
    
    // 初始化照片选择器
    private lazy var pictureSelector: PictureSelectCollectionViewController = {
        
        let pc = "PictureSelectCollectionViewController".storyBoard() as! PictureSelectCollectionViewController
        pc.delegate = self
        return pc
    }()
    
    // 初始化表情键盘
    private lazy var emojiKeyBoard: EmojiKeyBoardViewController = EmojiKeyBoardViewController {[weak self] (emoticon) in
        
        self!.textView.insterPngEmoji(emoticon)
    }
    
    // 初始化toolBar
    private lazy var tooBar: UIToolbar = {
        
        let tool = UIToolbar()
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
                            ["imageName": "compose_mentionbutton_background"],
                            ["imageName": "compose_trendbutton_background"],
                            ["imageName": "compose_emoticonbutton_background", "action": "inputEmoticon:"],
                            ["imageName": "compose_addbutton_background"]]
        
        var items = [UIBarButtonItem]()
        for setting in itemSettings {
            
            let item = UIBarButtonItem(imageName: setting["imageName"]!, targrt: self, action: setting["action"])
            items.append(item)
            let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            items.append(flexible)
        }
        items.removeLast()
        tool.items = items
        return tool
    }()
    
    // 初始化字数提醒
    private let Max_CharCount = 140
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
 
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 等待所有UI加载完毕 后 弹出键盘
        if pictureSelector.view.frame.size.height == 0.0 {
            textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension EmojiViewController: UITextViewDelegate
{
    func textViewDidChange(textView: UITextView) {
        
        placeHolderLabel.hidden = textView.hasText()
        sendBtn.enabled = textView.hasText()
        let c = textView.emojiAttributedString().characters.count
        let s = Max_CharCount-c
        tipLabel.text = s >= 0 ? "" : "\(s)"
        tipLabel.textColor = s < 0 ? UIColor.redColor() : UIColor.lightGrayColor()
    }
}

// MARK: - NotificationCenter
extension EmojiViewController
{
    func addKeyBoardNotiCenter() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .keyBoardChange, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyBoardChange(noti: NSNotification) {
        
        let value = noti.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let rect = value.CGRectValue()
        
        let timeValue = noti.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        let curve = noti.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        UIView.animateWithDuration(timeValue) {
            
            self.tooBar.snp_updateConstraints(closure: { (make) in
                
                UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.integerValue)!)
                make.bottom.equalTo(self.view).offset(-(LSYStruct.screen_h - rect.origin.y))
            })
            
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - PictureSelectorDelegate
extension EmojiViewController: PictureSelectorDelegate
{
    func disMiss() {
        
        textView.becomeFirstResponder()
        pictureSelector.view.snp_updateConstraints { (make) in
            make.height.equalTo(view.snp_height).multipliedBy(0.0)
        }
    }
    
    func updateEnabled(enabled: Bool) {
        
        sendBtn.enabled = enabled
    }
}

private extension Selector {
    static let keyBoardChange = #selector(EmojiViewController.keyBoardChange(_:))
}
