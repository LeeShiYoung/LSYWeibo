//
//  Category.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/5/1.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import SDWebImage

extension NSDate {
    class func dateWithStr(time: String) ->NSDate {

        let formatter = NSDateFormatter()
    
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en")
        let createdDate = formatter.dateFromString(time)!

        return createdDate
    }
    
    var descDate:String{
        
        let calendar = NSCalendar.currentCalendar()
        
        if calendar.isDateInToday(self)
        {
            let since = Int(NSDate().timeIntervalSinceDate(self))
            // 是刚刚
            if since < 60
            {
                return "刚刚"
            }
            // 多少分钟以前
            if since < 60 * 60
            {
                return "\(since/60)分钟前"
            }
            
            // 多少小时以前
            return "\(since / (60 * 60))小时前"
        }
        
        // 昨天
        var formatterStr = "HH:mm"
        if calendar.isDateInYesterday(self)
        {
            // 昨天: HH:mm
            formatterStr =  "昨天:" +  formatterStr
        }else
        {
            // 处理一年以内
            formatterStr = "MM-dd " + formatterStr
            
            // 处理更早时间
            let comps = calendar.components(NSCalendarUnit.Year, fromDate: self, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
            if comps.year >= 1
            {
                formatterStr = "yyyy-" + formatterStr
            }
        }
        
        let formatter = NSDateFormatter()
        
        formatter.dateFormat = formatterStr
        formatter.locale = NSLocale(localeIdentifier: "en")
        
        return formatter.stringFromDate(self)
    }
}

extension String {
    
    // 创建控制器
    func storyBoard() -> UIViewController {
        let sb = UIStoryboard(name: self, bundle: nil)
        return sb.instantiateInitialViewController()!
    }
    
    // 获取storyBoard
    func stoBoard() -> UIStoryboard {
        return UIStoryboard(name: self, bundle: nil)
    }
    
    // 获取缓存路径
    func cacheDir() -> String{
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!  as NSString
        return path.stringByAppendingPathComponent((self as NSString).lastPathComponent)
    }
    
    // 获取沙河路径
    func docDir() -> String
    {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!  as NSString
        return path.stringByAppendingPathComponent((self as NSString).lastPathComponent)
    }
    
    // 临时文件路径
    func tmpDir() -> String
    {
        let path = NSTemporaryDirectory() as NSString
        return path.stringByAppendingPathComponent((self as NSString).lastPathComponent)
    }
    
    // 加载 xib 文件
    func loadNib(owner: AnyObject!) -> AnyObject! {
        return NSBundle.mainBundle().loadNibNamed(self, owner: owner, options: nil).last
    }
}

extension UIImage {
    
    func imageWithScale(width: CGFloat) -> UIImage
    {
        
        let height = width *  size.height / size.width
        
        let currentSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        drawInRect(CGRect(origin: CGPointZero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}


// UIBarButtonItem 的 扩展
extension UIBarButtonItem {
    class func createBarButtonItem(imageName: String, targrt: AnyObject?, action: Selector) -> UIBarButtonItem {
        let btn = UIButton()
        btn.setUpInfo(imageName)
        btn.addTarget(targrt, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        btn.sizeToFit()
        return UIBarButtonItem(customView: btn)
    }
    
    // 便利构造器
    convenience init(imageName: String, targrt: AnyObject?, action: String?) {
        
        let btn = UIButton()
        btn.setUpInfo(imageName)
        
        if let ac = action {
            btn.addTarget(targrt, action: Selector(ac), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        btn.sizeToFit()
        self.init(customView: btn)
    }
    
    convenience init(imageName: String?, title: String?, targrt: AnyObject?, selector: Selector) {
        let btn = CustomBtn()
        if let imageName = imageName {
            btn.setUpInfo(imageName)
        }
        if let title = title {
            btn.setTitle(title, forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            btn.setTitleColor(UIColor.orangeColor(), forState: .Highlighted)
        }
        
        btn.addTarget(targrt, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        btn.sizeToFit()
        
        self.init(customView: btn)
    }
}

extension UIButton
{
    func setUpInfo(imageName: String) {
        
        setImage(UIImage(named:
            imageName), forState: .Normal)
        setImage(UIImage(named:
            imageName + "_highlighted"), forState: .Highlighted)
    }
    
    func setUpBackGroundInfo(imageName: String) {
        setBackgroundImage(UIImage(named:
            imageName), forState: .Normal)
        setBackgroundImage(UIImage(named:
            imageName + "_highlighted"), forState: .Highlighted)
    }
}

class CustomBtn: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.frame.origin.x = -10
        titleLabel?.frame.origin.x = -15
    }
}

// 生成高清图片
extension UIImageView {
    
    func highDefinitionImage(image: UIImage?){

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
       
        if let image = image {
            let ciImage = CIImage(CGImage: image.CGImage!)
            
            let extent: CGRect = CGRectIntegral(ciImage.extent)
            let scale: CGFloat = min(image.size.width/CGRectGetWidth(extent), image.size.height/CGRectGetHeight(extent))
            // 1.创建bitmap;
            let width = CGRectGetWidth(extent) * scale
            let height = CGRectGetHeight(extent) * scale
            let cs: CGColorSpaceRef = CGColorSpaceCreateDeviceCMYK()!
            let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, 0)!
            
            let context = CIContext(options: nil)
            let bitmapImage: CGImageRef = context.createCGImage(ciImage, fromRect: extent)
            
            CGContextSetInterpolationQuality(bitmapRef,  CGInterpolationQuality.None)
            CGContextScaleCTM(bitmapRef, scale, scale);
            CGContextDrawImage(bitmapRef, extent, bitmapImage);
            
            // 2.保存bitmap到图片
            let scaledImage: CGImageRef = CGBitmapContextCreateImage(bitmapRef)!
            dispatch_async(dispatch_get_main_queue(), { 
               self.image = UIImage(CGImage: scaledImage)
                
               
            })
            }
        }
    }
}

extension UIImageView {
    func LSY_CircleImage(url url: NSURL?) {
        
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, error, _, _, url) in
            
            autoreleasepool({
      
                if error != nil {
                    return
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // 开启上下文
                    UIGraphicsBeginImageContext(self.frame.size)
                    
                    // 获取当前上下文
                    let context = UIGraphicsGetCurrentContext()
                    
                    // 开启上下文栈
                    CGContextSaveGState(context)
                    
                    let lineWidth:CGFloat = 1.0
                    
                    // 绘制一条圆的线
                    CGContextAddArc(context, self.frame.width / 2.0, self.frame.height / 2.0, (self.frame.width - lineWidth) / 2.0, 0.0, CGFloat(M_PI) * 2, 0)
                    
                    // 设置线宽
                    CGContextSetLineWidth(context, lineWidth)
                    
                    // 设置线的颜色
                    CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
                    
                    // 关闭上下文
                    CGContextStrokePath(context)
                    
                    // 从下文栈中取出上下文
                    CGContextRestoreGState(context)
                    
                    let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                    
                    // 绘制个圆
                    CGContextAddEllipseInRect(context, rect)
                    
                    // 剪裁多余部分
                    CGContextClip(context)
                    
                    // 将 iamge 绘制在当前上下文中
                    image.drawInRect(rect)
                    
                    // 得到新绘制到的 image
                    let newImage = UIGraphicsGetImageFromCurrentImageContext()
                    
                    // 关闭上下文
                    UIGraphicsEndImageContext()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // 回到主线程显示
                        self.image = newImage
                    }
                }
            })
        }
    }
}

