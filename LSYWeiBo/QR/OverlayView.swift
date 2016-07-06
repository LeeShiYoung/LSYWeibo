//
//  OverlayView.swift
//  LSYWeiBo
//
//  Created by 李世洋 on 16/6/30.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

private var w: CGFloat {
get {
    let max = screenw < screenh ? screenw : screenh
    let margin: CGFloat = 60
    return max - margin * 2
}
}
private let h: CGFloat = w
private let screenw: CGFloat = UIScreen.mainScreen().bounds.size.width
private let screenh: CGFloat = UIScreen.mainScreen().bounds.size.height
private let moveSpeed: CGFloat = 1.0

class OverlayView: UIView {

   private var scanRect: CGRect {
        get {
            return CGRectMake((screenw - w) / 2, (screenw - h) / 2, w, h)
        }
    }
    private var lineView: UIView?
    
    init() {
        super.init(frame: CGRectZero)
        self.setupView()
        self.startMoving()
        self.backgroundColor = UIColor.clearColor()
    }
    
    func getFrame() -> CGRect {

        return CGRect(x: (screenw - w) * 0.5, y: screenh / 3.5, width: w, height: w)
    }
    
    private func setupView() {
        
        self.lineView = UIView(frame: CGRectMake((screenw - w) * 0.5, screenh / 3.5, w, 2))
        self.addSubview(self.lineView!)
        
        self.lineView!.clipsToBounds = true
        
        // reset height
        var frame = self.lineView!.frame
        frame.size.height = h
        self.lineView!.frame = frame
        
        let imageView = UIImageView(image: UIImage(named: "qrcode_scanline_barcode"))
        imageView.frame = CGRectMake(0, -h, self.lineView!.frame.size.width, self.lineView!.frame.size.height)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.lineView!.addSubview(imageView)
    }
    
    func startMoving() {
        let imageView = self.lineView?.subviews.first as? UIImageView
        if let imageView = imageView {
            
            UIView.animateWithDuration(1.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                
                imageView.transform = CGAffineTransformTranslate(imageView.transform, 0, h+10)
                
                }, completion: { (finished) in
                    
                    imageView.frame = CGRectMake(0, -h, self.lineView!.frame.size.width, self.lineView!.frame.size.height)
                    self.startMoving()
            })
        }
    }

    override func drawRect(rect: CGRect) {
        
        let originx: CGFloat = (rect.size.width - w ) / 2
        let originy: CGFloat = rect.size.height / 3.5
        let maggin: CGFloat = 15
        //        UIColor(red: 0/255.0, green: 153/255.0, blue: 204/255.0, alpha: 1.0)
        let cornerColor: UIColor = UIColor.orangeColor()
        let frameColor: UIColor = UIColor.whiteColor()
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetRGBFillColor(ctx, 40/255.0, 40/255.0, 40/255.0, 0.5);
        CGContextFillRect(ctx, rect);
        
        // framePath
        let framePath: UIBezierPath = UIBezierPath(rect: CGRectMake(originx, originy, w, h))
        CGContextAddPath(ctx, framePath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, frameColor.CGColor)
        CGContextSetLineWidth(ctx, 0.6)
        CGContextStrokePath(ctx)
        
        // set scan rect
        CGContextClearRect(ctx, CGRectMake(originx, originy, w, h))

        // left top corner
        let leftTopPath = UIBezierPath()
        leftTopPath.moveToPoint(CGPointMake(originx, originy + maggin))
        leftTopPath.addLineToPoint(CGPointMake(originx, originy))
        leftTopPath.addLineToPoint(CGPointMake(originx + maggin, originy))
        CGContextAddPath(ctx, leftTopPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // right top corner
        let rightTopPath = UIBezierPath()
        rightTopPath.moveToPoint(CGPointMake(originx + w - maggin, originy))
        rightTopPath.addLineToPoint(CGPointMake(originx + w, originy))
        rightTopPath.addLineToPoint(CGPointMake(originx + w, originy + maggin))
        CGContextAddPath(ctx, rightTopPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // left bottom corner
        let leftBottomPath = UIBezierPath()
        leftBottomPath.moveToPoint(CGPointMake(originx, originy + h - maggin))
        leftBottomPath.addLineToPoint(CGPointMake(originx , originy + h))
        leftBottomPath.addLineToPoint(CGPointMake(originx + maggin, originy + h))
        CGContextAddPath(ctx, leftBottomPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // right bottom corner
        let rightBottomPath = UIBezierPath()
        rightBottomPath.moveToPoint(CGPointMake(originx + w , originy + h - maggin))
        rightBottomPath.addLineToPoint(CGPointMake(originx + w, originy + h))
        rightBottomPath.addLineToPoint(CGPointMake(originx + w - maggin, originy + h))
        CGContextAddPath(ctx, rightBottomPath.CGPath)
        CGContextSetStrokeColorWithColor(ctx, cornerColor.CGColor)
        CGContextSetLineWidth(ctx, 1.6)
        CGContextStrokePath(ctx)
        
        // draw title
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let attr = [NSParagraphStyleAttributeName: paragraphStyle ,
                    NSFontAttributeName: UIFont.systemFontOfSize(12.0) ,
                    NSForegroundColorAttributeName: UIColor.whiteColor()]
        let title = "将二维码/条码放入框内, 即可自动扫描"
        
        let size = (title as NSString).sizeWithAttributes(attr)
        
        let r = CGRectMake(0, originy + h + 15, rect.size.width, size.height)
        (title as NSString).drawInRect(r, withAttributes: attr)
        
        
        
    }

    deinit{
        print("OverlayView si")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
