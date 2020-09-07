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
    
    
    class func reSizeImage(sourceImage : UIImage) -> UIImage{
        let maxImageSize : CGFloat = 1024.0
        var newSize =  CGSize.init(width: sourceImage.size.width, height: sourceImage.size.height)
        var tempHeight = newSize.height / maxImageSize;
        var tempWidth = newSize.width / maxImageSize;
        if tempWidth == 0{
            tempWidth = 1
        }
        if tempHeight == 0{
            tempHeight = 1
        }
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            newSize = CGSize.init(width: sourceImage.size.width / tempWidth, height: sourceImage.size.height / tempWidth)
        }else if (tempHeight > 1.0 && tempWidth < tempHeight){
            newSize = CGSize.init(width:sourceImage.size.width / tempHeight, height:  sourceImage.size.height / tempHeight)
        }
        UIGraphicsBeginImageContext(newSize);
        sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
    }
    
    
    class func creatQRCodeImage(text:String) -> UIImage{
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        let ciImage = filter?.outputImage
        let bgImage = createNonInterpolatedUIImageFormCIImage(image: ciImage!, size: 300)
        return bgImage
    }
    
    
    static func createRect(size:CGSize,color:UIColor) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint(), size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    static func createEllipse(size:CGSize,color:UIColor) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    class func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context  = CIContext(options: nil)
        
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale)
        bitmapRef.draw(bitmapImage, in: extent)
        let scaledImage: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: scaledImage)
    }
    
    func cropImage(rect:CGRect) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
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
    
    func fixImageOrientation() -> UIImage {
        if self.imageOrientation == .up{
            return self
        }
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat( -Double.pi / 2))
        default:
            break
        }
        switch self.imageOrientation{
            case .upMirrored,.downMirrored:
                transform = transform.translatedBy(x: self.size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored,.rightMirrored:
                transform = transform.translatedBy(x: self.size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            default:
                break
        }
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        switch self.imageOrientation {
        case .leftMirrored,.left,.right,.rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
              ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        if let cgimg = ctx?.makeImage(){
            return UIImage(cgImage: cgimg)
        }
        return self
    }
    
    func saveToDocuments(imgName:String){
//        var path = (NSHomeDirectory() as NSString).appendingPathComponent("Document").appendingPathComponent(imgName)
//        UIImagePNGRepresentation(self).writeToFile(path, atomically: true)
        // Save to document
    }
    
    
    func addWatermark(text:String,point:CGPoint,repeatMark:Bool = true,attribute:[NSAttributedString.Key:Any]? = [NSAttributedString.Key.foregroundColor:UIColor.white]) -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let fontSize = self.size.width / 23
        var attr = attribute ?? [NSAttributedString.Key:Any]()
        attr[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: fontSize)
        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        (text as NSString).draw(at: point, withAttributes: attr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        print("self Size width: \(self.size.width) height: \(self.size.height)")
        //        print("newImage Size width: \(newImage!.size.width) height: \(newImage!.size.height)")
        return newImage ?? self
    }
    
    func addWatermark(maskImage:UIImage,point:CGPoint = CGPoint(x: 0, y: 0), repeatMark:Bool = true,  scale:CGFloat = 1) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        //        print("self.size")
        //        print(self.size)
        //        print("maskImage.size")
        //        print(maskImage.size)
        draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        var x:CGFloat = point.x
        var y:CGFloat = point.y
        // 效果还是不太好，scale还是要按照分辨率来
        let adjustScale = self.size.width / 1500
        let w = maskImage.size.width * scale * adjustScale
        let h = maskImage.size.height * scale * adjustScale
        if !repeatMark{
            maskImage.draw(in: CGRect(x: x, y: y, width: w, height: h))
        }
        else{
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
    
    
    func compressWithMaxLength(maxLength:UInt) -> Data? {
        var compression:CGFloat = 1
        guard var data = self.jpegData(compressionQuality: compression) else{
            return nil
        }
        var d = NSData(data: data)
        if d.length < maxLength{
            return data
        }
        var max:CGFloat = 1
        var min:CGFloat = 0
        for _ in 0..<6{
            compression = (max + min) / 2
            
            d = NSData(data: self.jpegData(compressionQuality: compression)!)
            if Double(d.length) < maxLength * 0.9{
                min = compression
            }
            else if d.length > maxLength{
                max = compression
            }
            else{
                break
            }
        }
        if d.length < maxLength{
            return d as Data
        }
        var resultImg = UIImage(data: d as Data)
        var lastDataLength = 0
        while d.length > maxLength && d.length != lastDataLength {
            lastDataLength = d.length
            let ratio = Float(maxLength) / Float(d.length)
            let size = CGSize(width: resultImg!.size.width * CGFloat(sqrtf(ratio)), height: resultImg!.size.height * CGFloat(sqrtf(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImg?.draw(in: CGRect(x: 0, y: 0, w: size.width, h: size.height))
            resultImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            data = resultImg!.jpegData(compressionQuality: compression)!
        }
        return data
    }
    
    static func LoadBigImage(url: URL, to pointSize: CGSize, scale: CGFloat) ->UIImage {
        
        let imageSourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(url as CFURL,imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width,pointSize.height) * scale;
        
        let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways:true,kCGImageSourceShouldCacheImmediately:true,kCGImageSourceThumbnailMaxPixelSize:maxDimensionInPixels] as CFDictionary;
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource,0,downsampleOptions)!

        return UIImage(cgImage:downsampledImage)
        
    }
    
    ///解码图片
    func decodeImage(scale:CGFloat) -> UIImage? {
        //获取当前图片数据源
        guard var imageRef = self.cgImage else{
            return nil
        }
        //设置大小改变压缩图片
        let width = imageRef.width * scale
        let height = imageRef.height * scale
        //创建颜色空间
        guard let colorSpace = imageRef.colorSpace else{
            return nil
        }
        let contextRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow:  Int(4 * width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        contextRef?.draw(imageRef, in: CGRect(x: 0, y: 0, w: width, h: height))
        imageRef = contextRef!.makeImage()!
           
        return UIImage(cgImage: imageRef, scale: self.scale, orientation: Orientation.up)
                
    }
}
