//
//  Emoticons.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/23.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import MJExtension

class EmoticonPackage: NSObject {
    
    var id: String?
    var group_name_cn : String?
    var emoticons: [Emoticon]?
    
    // 单例
    static let emptionsPackageManger: [EmoticonPackage]  = EmoticonPackage.loadEmoticonsPackage()
    
    // 获取带表情的字符串
    class func emoticonAttributedString(str: String) -> NSAttributedString?
    {
        
        do {
            let attStr = NSMutableAttributedString(string: str)
            let pattern = "\\[.*?\\]"
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            
            let result = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSRange(0..<str.characters.count))
            var count = result.count
    
            while count > 0 {
            
                count -= 1
                let checkingResult = result[count]
                let tempStr = (str as NSString).substringWithRange(checkingResult.range)
                if let emtion = searchEmotions(tempStr) {
                    
                    let attributedStr = EmojiTextAttachment.emojiAttachment(emtion, font: UIFont.systemFontOfSize(17))
                    attStr.replaceCharactersInRange(checkingResult.range, withAttributedString: attributedStr)
                }
            }
            return attStr
        } catch {
            return nil
        }
    }
    
    // 根据表情chs 查找 Emoticon
    class func searchEmotions(str: String) -> Emoticon? {
        var emoti: Emoticon?
        
        for packge in EmoticonPackage.emptionsPackageManger
        {
           emoti = packge.emoticons?.filter({ (element) -> Bool in
                return element.chs == str
            }).last
            if emoti != nil{
                break
            }
        }
        return emoti
    }
    
    
    private class func loadEmoticonsPackage() -> [EmoticonPackage] {
  
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        let dictionary = NSDictionary(contentsOfFile: path)!
        let packages = dictionary["packages"] as! [[String: AnyObject]]
        
        // 所有表情文件放进一个数组
        var infos = [EmoticonPackage]()
        
        // 创建最近组
        let pk = EmoticonPackage(id: "")
        pk.group_name_cn = "最近"
        pk.emoticons = [Emoticon]()
        pk.appendEmtyEmoticons()
        infos.append(pk)
        
        // 正常的组(默认 emoji 浪小花...)
        for elem in packages {
            // 保存 id
            let package = EmoticonPackage(id: elem["id"] as! String)
            
            // 加载emoticons
            package.loadEmoticons()
            package.appendEmtyEmoticons()
            infos.append(package)
        }
        return infos
    }
    
    
    func loadEmoticons() {
        
        emoticons = [Emoticon]()
        let emtionDic = emoticonPath(id)
        group_name_cn = emtionDic["group_name_cn"] as? String
        let emtionsArr = emtionDic["emoticons"] as! [[String: String]]
        
        var index = 0
        for emticion in emtionsArr {
            
                if index == 20
                {
                    emoticons?.append(Emoticon(removeBtn: true))
                    index = 0
                }
            // 初始化 Emoticon
            emoticons?.append(Emoticon(dict: emticion, id: id!))
                index += 1
            }
    }
    
    func appendEmtyEmoticons()
    {
        let count = emoticons!.count % 21
        
        for _ in count..<20
        {
            emoticons?.append(Emoticon(removeBtn: false))
        }
       
        emoticons?.append(Emoticon(removeBtn: true))
    }
    
    // 最近使用表情
    func latelyUse(emoticon: Emoticon) {
        
        let contains = emoticons!.contains(emoticon)
        
        if emoticon.removeBtn {
            return
        }
        
        // 添加
        if !contains {
            
            // 移除删除按钮
            emoticons?.removeLast()
            emoticons?.append(emoticon)
        }
        
        // 排序
        var sortEms = emoticons?.sort{ $0.times > $1.times }
        
        if !contains {
            
            sortEms?.removeLast()
            // 添加删除
            sortEms?.append(Emoticon(removeBtn: true))
        }
        
        emoticons = sortEms
    }

    
    // bundle 根文件路径
    class func bundlePath() -> NSString {
        
        return (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("Emoticons.bundle")
    }
    
    // 表情文件夹路径
    func emoticonPath(id: String!) -> [String: AnyObject] {
        let path = ((EmoticonPackage.bundlePath() as NSString).stringByAppendingPathComponent(id) as NSString).stringByAppendingPathComponent("info.plist")
        
        let emoticonDic = NSDictionary(contentsOfFile: path)!
        return emoticonDic as! [String : AnyObject]
    }
    
    init(id: String) {
        self.id = id
    }
}


class Emoticon: NSObject {
   
    // 记录使用频率
    var times = 0
    
    // 系统emoji
    var code: String?{
        
        didSet{
            let sca = NSScanner(string: code!)
            var pointer: UInt32 = 0
            sca.scanHexInt(&pointer)
            emojiStr = "\(Character(UnicodeScalar(pointer)))"
            
        }
    }
    var type: String?
    
    // emoji 字符串
    var emojiStr: String?
    
    // 表情文件夹id
    var id: String?
    // 文字
    var chs: String?
    var png: String? {
        didSet{
            
           pngPath = (EmoticonPackage.bundlePath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(png!)
        }
    }
    
    // png表情路径
    var pngPath: String?
    
    // 删除按钮
    var removeBtn: Bool = false
    
    init(removeBtn: Bool) {
        super.init()
        self.removeBtn = removeBtn
    }
    
    init(dict: [String: AnyObject], id: String) {
        super.init()
        self.id = id
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}
