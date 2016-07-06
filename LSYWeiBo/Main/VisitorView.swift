//
//  VisitorView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

protocol VisitorViewDelegate: NSObjectProtocol {
    
    func registerClick()
    func loginClick()
}
class VisitorView: UIView {
    
    weak var delegate: VisitorViewDelegate?
    //背景
    @IBOutlet weak var bckImage: UIImageView!
    //中间图标 (房子)
    @IBOutlet weak var iconImage: UIImageView!
    //文本
    @IBOutlet weak var textLabel: UILabel!
    //注册
    @IBAction func registerBthClick(sender: UIButton) {
       
       delegate?.registerClick()
    }
    
    //登录
    @IBAction func loginBtnClick(sender: UIButton) {
        
        delegate?.loginClick()
    }
    
    override func awakeFromNib() {
        
        startAnimation()
    }
    
    func setupVisitorInfo(isHome: Bool, iconStr: String, text: String) {
//        bckImage.image = UIImage(named: bckStr)
        iconImage.image = UIImage(named: iconStr)
        textLabel.text = text
        if !isHome {
           bckImage.hidden = true
        }
        
    }
    
    // 转盘旋转动画
    private func startAnimation() {
    
        let ani = CABasicAnimation(keyPath: "transform.rotation")
        ani.toValue = 2 * M_PI
        ani.duration = 20
        ani.repeatCount = MAXFLOAT
        ani.removedOnCompletion = false
        bckImage.layer.addAnimation(ani, forKey: nil)
    }

}
