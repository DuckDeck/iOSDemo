//
//  UIImage+Base.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit
import Photos
extension UIImage{
    static func captureView(view:UIView)->UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func captureScreen()->UIImage{
        //        var view = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(true); //snapshotViewAfterScreenUpdates这个方法有问题，实际上是返回正在显示的View的了，但是就是转化不了图片
        //        return captureView(view)
        //获取APP的RootViewController
        var vc = UIApplication.shared.keyWindow?.rootViewController
        //依次获取RootViewController 的上层ViewController
        while vc?.presentationController == nil {
            vc = vc?.presentedViewController
        }
        //如果最上层ViewContoller是导航ViewController，就得到它的topViewController
        while (vc is UINavigationController && (vc as! UINavigationController).topViewController != nil)
        {
            vc = (vc as! UINavigationController).topViewController
        }
        if let view = vc?.view
        {
            //如果可以获取到View，就调用将View显示为图片的方法
            return captureView(view: view)
        }
        return UIImage()
    }
    
    func imageAtRect(rect:CGRect)->UIImage{
        let imgCg = self.cgImage
        // 从imgCg中“挖取”rect区域
       
        let newImgCg  = imgCg?.cropping(to: rect)
        // 将“挖取”出来的CGImageRef转换为UIImage对象
        let img = UIImage(cgImage: newImgCg!)

        return img
    }
    
    
    
    
    
    func imageByScalingAspectToMinSize(targetSize:CGSize)->UIImage{
        // 获取源图片的宽和高
        let imgSize  = self.size
        let width = imgSize.width
        let height = imgSize.height
        // 获取图片缩放目标大小的宽和高
        let targetHeight = targetSize.height
        let targetWidth = targetSize.width
        // 定义图片缩放后的宽度
        var scaledWIdth = targetWidth
        // 定义图片缩放后的高度
        var scaledHeight = targetHeight
        var anchorPoint = CGPoint()
        // 如果源图片的大小与缩放的目标大小不相等
        
        if !imgSize.equalTo(targetSize){
            // 计算水平方向上的缩放因子
            let xFactor = targetWidth / width
            // 计算垂直方向上的缩放因子
            let yFactor = targetHeight / height
            // 定义缩放因子scaleFactor，为两个缩放因子中较大的一个
            let scaleFactor = xFactor > yFactor ? xFactor:yFactor
            // 根据缩放因子计算图片缩放后的宽度和高度
            scaledWIdth = width * scaleFactor
            scaledHeight = height * scaleFactor
            // 如果横向上的缩放因子大于纵向上的缩放因子，那么图片在纵向上需要裁切
            if xFactor > yFactor{
                anchorPoint.y = (targetHeight - scaledHeight) * 0.5
            }
                // 如果横向上的缩放因子小于纵向上的缩放因子，那么图片在横向上需要裁切
            else if xFactor < yFactor{
                anchorPoint.x = (targetWidth - scaledWIdth) * 0.5
            }
        }
        
        
        UIGraphicsBeginImageContext(targetSize)
        // 定义图片缩放后的区域
        var anchorRect = CGRect()
        anchorRect.origin = anchorPoint
        anchorRect.size.width = scaledWIdth
        anchorRect.size.height = scaledHeight
        // 将图片本身绘制到auchorRect区域中
        self.draw(in: anchorRect)
        // 获取绘制后生成的新图片
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg!
    }
    
    
    func imageByScalingAspectToMaxSize(targetSize:CGSize) -> UIImage
    {
        // 获取源图片的宽和高
        let imgSize  = self.size
        let width = imgSize.width
        let height = imgSize.height
        // 获取图片缩放目标大小的宽和高
        let targetHeight = targetSize.height
        let targetWidth = targetSize.width
        // 定义图片缩放后的宽度
        var scaledWIdth = targetWidth
        // 定义图片缩放后的高度
        var scaledHeight = targetHeight
        var anchorPoint = CGPoint()
        // 如果源图片的大小与缩放的目标大小不相等
        if !imgSize.equalTo(targetSize){
            // 计算水平方向上的缩放因子
            let xFactor = targetWidth / width
            // 计算垂直方向上的缩放因子
            let yFactor = targetHeight / height
            // 定义缩放因子scaleFactor，为两个缩放因子中较小的一个
            let scaleFactor = xFactor < yFactor ? xFactor:yFactor
            // 根据缩放因子计算图片缩放后的宽度和高度
            scaledWIdth = width * scaleFactor
            scaledHeight = height * scaleFactor
            // 如果横向上的缩放因子大于纵向上的缩放因子，那么图片在纵向上需要裁切
            if xFactor < yFactor{
                anchorPoint.y = (targetHeight - scaledHeight) * 0.5
            }
                // 如果横向上的缩放因子小于纵向上的缩放因子，那么图片在横向上需要裁切
            else if xFactor > yFactor{
                anchorPoint.x = (targetWidth - scaledWIdth) * 0.5
            }
        }
        
        
        UIGraphicsBeginImageContext(targetSize)
        // 定义图片缩放后的区域
        var anchorRect = CGRect()
        anchorRect.origin = anchorPoint
        anchorRect.size.width = scaledWIdth
        anchorRect.size.height = scaledHeight
        // 将图片本身绘制到auchorRect区域中
        self.draw(in: anchorRect)
        // 获取绘制后生成的新图片
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg!
    }
    
    
    func imageByScalingToSize(targetSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(targetSize)
        var anchorRect = CGRect()
        anchorRect.origin = CGPoint()
        anchorRect.size = targetSize
        self.draw(in: anchorRect)
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg!
    }
    
    func imageRotatedByRadians(radians:CGFloat) -> UIImage{
        let t = CGAffineTransform(rotationAngle: radians)
        let rotatedRect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height).applying(t)
        let rotatedSize = rotatedRect.size
        UIGraphicsBeginImageContext(rotatedSize)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        ctx?.rotate(by: radians)
        ctx?.scaleBy(x: 1.0, y: -1.0)
        ctx?.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg!
    }
    
    func imageRotatedByDegrees(degrees:CGFloat) -> UIImage{
        return imageRotatedByRadians(radians: degrees * CGFloat(Double.pi) / 180)
    }
    
    func saveToDocuments(imgName:String){
//        var path = (NSHomeDirectory() as NSString).appendingPathComponent("Document").appendingPathComponent(imgName)
//        UIImagePNGRepresentation(self).writeToFile(path, atomically: true)
        // Save to document
    }
    
    
    func addWatermark(text:String,point:CGPoint,attribute:[NSAttributedStringKey:Any]? = [NSAttributedStringKey.foregroundColor:UIColor.white]) -> UIImage {
        //UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        UIGraphicsBeginImageContext(self.size)
        let fontSize = self.size.width / 30
        var attr = attribute ?? [NSAttributedStringKey:Any]()
        attr[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: fontSize)
        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        (text as NSString).draw(at: point, withAttributes: attr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("self Size width: \(self.size.width) height: \(self.size.height)")
        print("newImage Size width: \(newImage!.size.width) height: \(newImage!.size.height)")
        return newImage ?? self
    }
    
    func addWatermark(maskImage:UIImage,scale:CGFloat = 1) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
//        print("self.size")
//        print(self.size)
//        print("maskImage.size")
//        print(maskImage.size)
        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        var x:CGFloat = 0
        var y:CGFloat = 0
        // 效果还是不太好，scale还是要按照分辨率来
        let adjustScale = self.size.width / 1500
        let w = maskImage.size.width * scale * adjustScale
        let h = maskImage.size.height * scale * adjustScale
        if w < self.size.width &&  h < self.size.height{
            while x < self.size.width && y < self.size.height{
                maskImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
                x += w
                if x > self.size.width{
                    x = 0
                    y = y + h
                }
            }
        }
        else if w < self.size.width &&  h > self.size.height{
            while x < self.size.width {
                maskImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
                x += w
            }
        }
        else if w > self.size.width &&  h < self.size.height{
            while y < self.size.height {
                maskImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
                y = y + h
            }
        }
        else{
            maskImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
        }
        
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
//        print("newImage.size")
//        print(newImage!.size)
        return newImage ?? self
    }
    
    
    func saveToAlbum() {
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: self)
        }
    }
}
