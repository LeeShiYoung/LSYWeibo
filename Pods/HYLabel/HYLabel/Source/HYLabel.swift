//
//  HYLabel.swift
//  HYLabel
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 xiaomage. All rights reserved.
//

import UIKit

enum TapHandlerType : Int {
    case noneHandle = 0
    case userHandle = 1
    case topicHandle = 2
    case linkHandle = 3
}

//MARK: - 有BUG 父视图无法响应touch 增加协议传递响应
public protocol HYLabelDelegate: NSObjectProtocol {
    func hy_LabelTouchBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    func hy_LabelTouchEnd(touches: Set<UITouch>, withEvent event: UIEvent?)
}

public class HYLabel: UILabel {
  
    public weak var hy_Delegate: HYLabelDelegate?
    // MARK:- 属性
    // 重写系统的属性
    override public var text : String? {
        didSet {
            prepareText()
        }
    }
    
    override public var attributedText: NSAttributedString? {
        didSet {
            prepareText()
        }
    }
    
    override public var font: UIFont! {
        didSet {
            prepareText()
        }
    }
    
    override public var textColor: UIColor! {
        didSet {
            prepareText()
        }
    }
    
    public var matchTextColor : UIColor = UIColor(red: 44 / 255.0, green: 103 / 255.0, blue: 161 / 255.0, alpha: 1.0) {
        didSet {
            prepareText()
        }
    }
    
//    var rangeAndLink = [NSRange: String]()
    // 保存被替换的字符串
    var links = [String]()
    // 网页链接文本
    var linkAttriStr: NSMutableAttributedString?
    
    // 懒加载属性
    private lazy var textStorage : NSTextStorage = NSTextStorage() // NSMutableAttributeString的子类
    private lazy var layoutManager : NSLayoutManager = NSLayoutManager() // 布局管理者
    private lazy var textContainer : NSTextContainer = NSTextContainer() // 容器,需要设置容器的大小
    
    // 用于记录下标值
    private lazy var linkRanges : [NSRange] = [NSRange]()
    private lazy var userRanges : [NSRange] = [NSRange]()
    private lazy var topicRanges : [NSRange] = [NSRange]()
    
    // 用于记录用户选中的range
    var selectedRange : NSRange?
    
    // 用户记录点击还是松开
    private var isSelected : Bool = false
    
    // 闭包属性,用于回调
    private var tapHandlerType : TapHandlerType = TapHandlerType.noneHandle
    
    public typealias HYTapHandler = (HYLabel, String, NSRange) -> Void
    public var linkTapHandler : HYTapHandler?
    public var topicTapHandler : HYTapHandler?
    public var userTapHandler : HYTapHandler?
    
    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        linkAttributedStr()
        prepareTextSystem()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        linkAttributedStr()
        prepareTextSystem()
    }
    
    // MARK:- 布局子控件
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // 设置容器的大小为Label的尺寸
        textContainer.size = frame.size
    }
    
    private func linkAttributedStr() {
        let str = "&T网页链接&"
        let attributImage = NSTextAttachment()
        attributImage.image = UIImage(named: "insert_link")
        attributImage.bounds = CGRect(x: 0, y: -2, width: 17, height: 17)
        
        linkAttriStr = NSMutableAttributedString(string: str)
        
        linkAttriStr!.replaceCharactersInRange(NSRange(location: 1, length: 1), withAttributedString: NSAttributedString(attachment: attributImage))
        linkAttriStr?.addAttributes([NSForegroundColorAttributeName: matchTextColor, NSFontAttributeName: font], range: NSRange(location: 0, length: linkAttriStr!.length))
        linkAttriStr?.addAttributes([NSForegroundColorAttributeName: UIColor.clearColor(), NSFontAttributeName: font], range: NSRange(location: 0, length: 1))
        linkAttriStr?.addAttributes([NSForegroundColorAttributeName: UIColor.clearColor(), NSFontAttributeName: font], range: NSRange(location: linkAttriStr!.length-1, length: 1))
        
    }
    
    // MARK:- 重写drawTextInRect方法
    override public func drawTextInRect(rect: CGRect) {
        // 1.绘制背景
        if selectedRange != nil {
            // 2.0.确定颜色
            let selectedColor = isSelected ? UIColor(white: 0.7, alpha: 0.2) : UIColor.clearColor()
            
            // 2.1.设置颜色
            textStorage.addAttribute(NSBackgroundColorAttributeName, value: selectedColor, range: selectedRange!)
            
            // 2.2.绘制背景
            layoutManager.drawBackgroundForGlyphRange(selectedRange!, atPoint: CGPoint(x: 0, y: 0))
        }
        
        // 2.绘制字形
        // 需要绘制的范围
        let range = NSRange(location: 0, length: textStorage.length)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: CGPointZero)
    }
}

extension HYLabel {
    /// 准备文本系统
    private func prepareTextSystem() {
        // 0.准备文本
        prepareText()
        
        // 1.将布局添加到storeage中
        textStorage.addLayoutManager(layoutManager)
        
        // 2.将容器添加到布局中
        layoutManager.addTextContainer(textContainer)
        
        // 3.让label可以和用户交互
        userInteractionEnabled = true
        
        // 4.设置间距为0
        textContainer.lineFragmentPadding = 0
    }
    
    /// 准备文本
    private func prepareText() {
        // 1.准备字符串
        var attrString : NSAttributedString?
        if attributedText != nil {
            attrString = attributedText
        } else if text != nil {
            attrString = NSAttributedString(string: text!)
        } else {
            attrString = NSAttributedString(string: "")
        }
        
        selectedRange = nil
        
        // 2.设置换行模型
        let attrStringM = addLineBreak(attrString!)
        
        attrStringM.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: attrStringM.length))
        attrStringM.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSRange(location: 0, length: attrStringM.length))
        
        // 3.设置textStorage的内容
        textStorage.setAttributedString(attrStringM)
        
        // 4.匹配URL
         let regulaStr = String(format: "<a href='(((http[s]{1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?))'>((?!<\\/a>).)*<\\/a>|(((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%@^&*+?:_/=<>]*)?))", "%","%","%","%")
        if let linkRanges = getRanges(regulaStr) {
            
            /*for range in linkRanges {
             textStorage.addAttribute(NSForegroundColorAttributeName, value: matchTextColor, range: range)
             }*/
            
            //MARK: - 修改为从 字符串 末尾 开始替换 (网址 -> 网页链接)
            var count = linkRanges.count
            links.removeAll()
            while count > 0 {
                count -= 1
                let range = linkRanges[count]
                textStorage.addAttribute(NSForegroundColorAttributeName, value: matchTextColor, range: range)
                
                // 保存被替换的字符串
                let linkS = (textStorage.string as NSString).substringWithRange(range)
                links.insert(linkS, atIndex: 0)
                textStorage.replaceCharactersInRange(range, withAttributedString: linkAttriStr!)
            }
            
            //MARK: 获取 替换后的 网页链接 字符串
            if let replaceLickRanges = getRanges("&.*?&") {
                self.linkRanges = replaceLickRanges
            }

        }
        
        // 5.匹配@用户
        if let userRanges = getRanges("@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*") {
            self.userRanges = userRanges
            for range in userRanges {
                textStorage.addAttribute(NSForegroundColorAttributeName, value: matchTextColor, range: range)
            }
        }
        
        // 6.匹配话题##
        if let topicRanges = getRanges("#.*?#") {
            self.topicRanges = topicRanges
            for range in topicRanges {
                textStorage.addAttribute(NSForegroundColorAttributeName, value: matchTextColor, range: range)
            }
        }
        
        setNeedsDisplay()
    }
}


// MARK:- 字符串匹配封装
extension HYLabel {
    private func getRanges(pattern : String) -> [NSRange]? {
        // 创建正则表达式对象
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        return getRangesFromResult(regex)
    }
    
    private func getLinkRanges() -> [NSRange]? {
        // 创建正则表达式
        guard let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue) else {
            return nil
        }
        
        return getRangesFromResult(detector)
    }
    
    private func getRangesFromResult(regex : NSRegularExpression) -> [NSRange] {
        // 1.匹配结果
        let results = regex.matchesInString(textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        // 2.遍历结果
        var ranges = [NSRange]()
        for res in results {
            ranges.append(res.range)
        }
        return ranges
    }
}


// MARK:- 点击交互的封装
extension HYLabel {
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 0.记录点击
        isSelected = true
        
        // 1.获取用户点击的点
        let selectedPoint = touches.first!.locationInView(self)
        
        // 2.获取该点所在的字符串的range
        selectedRange = getSelectRange(selectedPoint)
        
        // 3.是否处理了事件
        if selectedRange == nil {
            super.touchesBegan(touches, withEvent: event)
            hy_Delegate?.hy_LabelTouchBegan(touches, withEvent: event)
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if selectedRange == nil {
            super.touchesBegan(touches, withEvent: event)
            hy_Delegate?.hy_LabelTouchEnd(touches, withEvent: event)
            return
        }
        
        // 0.记录松开
        isSelected = false
        
        // 2.重新绘制
        setNeedsDisplay()
        
        // 3.取出内容
        let contentText = (textStorage.string as NSString).substringWithRange(selectedRange!)
        
        // 3.回调
        switch tapHandlerType {
        case .linkHandle:
            if linkTapHandler != nil {
                
              let index = linkRanges.indexOf({ (range) -> Bool in

                return range.length == selectedRange!.length && range.location ==  selectedRange!.location
              })
       
            linkTapHandler!(self, links[index!], selectedRange!)
            }
        case .topicHandle:
            if topicTapHandler != nil {
                topicTapHandler!(self, contentText, selectedRange!)
            }
        case .userHandle:
            if userTapHandler != nil {
                userTapHandler!(self, contentText, selectedRange!)
            }
        default:
            break
        }
    }
    
    private func getSelectRange(selectedPoint : CGPoint) -> NSRange? {
        // 0.如果属性字符串为nil,则不需要判断
        if textStorage.length == 0 {
            return nil
        }
        
        // 1.获取选中点所在的下标值(index)
        let index = layoutManager.glyphIndexForPoint(selectedPoint, inTextContainer: textContainer)
        
        // 2.判断下标在什么内
        // 2.1.判断是否是一个链接
        for linkRange in linkRanges {
            if index > linkRange.location && index < linkRange.location + linkRange.length {
                setNeedsDisplay()
                tapHandlerType = .linkHandle
                return linkRange
            }
        }
        
        // 2.2.判断是否是一个@用户
        for userRange in userRanges {
            if index > userRange.location && index < userRange.location + userRange.length {
                setNeedsDisplay()
                tapHandlerType = .userHandle
                return userRange
            }
        }
        
        // 2.3.判断是否是一个#话题#
        for topicRange in topicRanges {
            if index > topicRange.location && index < topicRange.location + topicRange.length {
                setNeedsDisplay()
                tapHandlerType = .topicHandle
                return topicRange
            }
        }
        
        return nil
    }
}

// MARK:- 补充
extension HYLabel {
    /// 如果用户没有设置lineBreak,则所有内容会绘制到同一行中,因此需要主动设置
    private func addLineBreak(attrString: NSAttributedString) -> NSMutableAttributedString {
        let attrStringM = NSMutableAttributedString(attributedString: attrString)
        
        if attrStringM.length == 0 {
            return attrStringM
        }
        
        var range = NSRange(location: 0, length: 0)
        var attributes = attrStringM.attributesAtIndex(0, effectiveRange: &range)
        var paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle
        
        if paragraphStyle != nil {
            paragraphStyle!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        } else {
            paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            attributes[NSParagraphStyleAttributeName] = paragraphStyle
            
            attrStringM.setAttributes(attributes, range: range)
        }
        
        return attrStringM
    }
}

// MARK: - 修改 HYLabel 点击cell上无法触发响应
extension HYLabel {
    
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
      
        if let _ = getSelectRange(point) {
            return super.hitTest(point, withEvent: event)
        }

        if let sup = self.superview where self.superview is UIButton {
            let poiInlabel = sup.convertPoint(point, fromView: self)
            if sup.pointInside(poiInlabel, withEvent: event) {
                return sup
            }
        }
        return super.hitTest(point, withEvent: event)
    }
}

