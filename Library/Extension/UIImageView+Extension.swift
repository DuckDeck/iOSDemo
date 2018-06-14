//
//  UIImageView+Extension.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/5/16.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import Foundation
import Kingfisher
extension UIImageView{
    func setImg(url:String?,completed:((_ img:UIImage)->Void)?,placeHolder:String="img_defect")  {
        if(url==nil||url!.count==0){
            self.image = UIImage(named: placeHolder)
            return
        }
        
        if url!.hasPrefix("http"){
            
            // use kf is not the same
            
//            sd_setImage(with: URL(string:url!)!, placeholderImage: UIImage(named: placeHolder), options: SDWebImageOptions.avoidAutoSetImage) { (img, err, _, _) in
//                if let i = img{
//                    self.image = i
//                    completed?(self.image!)
//                }
//            }
        }
        else{
            image = UIImage(named: url!)
        }
    }

    //    func setImageAnimation(url:String?)  {
    //        if(url==nil||url!.length==0){
    //            self.image = UIImage(named: "public_img_picture_not_exist")
    //            return
    //        }
    //        let httpUrl = url!
    //        var isCached = false //没有缓存
    //        if SDImageCache.shared().diskImageExists(withKey: httpUrl as String){
    //            isCached = true //已经缓存
    //        }
    //        if !isCached{
    //            for view in self.subviews{
    //                if view is UIImageView{
    //                    view.alpha = 0
    //                }
    //            }
    //        }
    //        sd_setImage(with: URL(string: httpUrl), placeholderImage: UIImage(named: "public_img_picture_not_exist"), options: [SDWebImageOptions.avoidAutoSetImage,SDWebImageOptions.delayPlaceholder], progress: { (a, b) -> Void in
    //            //   progress!.progress = Float(a) / Float(b) //这里根本就没有调用
    //        }, completed: { (img, error, cacheType, url) -> Void in
    //            if error != nil{
    //                self.image = UIImage(named: "public_img_picture_not_exist")
    //                for view in self.subviews{
    //                    view.alpha = 1
    //                }
    //                return
    //            }
    //            self.image = img
    //            if !isCached{
    //                self.alpha = 0
    //                for view in self.subviews{
    //                    view.alpha = 0
    //                }
    //                UIView.animate(withDuration: 1, animations: { () -> Void in
    //                    self.alpha = 1
    //                    for view in self.subviews{
    //                        view.alpha = 1
    //                    }
    //                })
    //            }
    //
    //        })
    //
    //    }
    
}

extension UIImageView{
    func addMask(img:UIImage?)  {
        for sub in self.subviews{
            if sub.tag == -100{
                return
            }
        }
        let imgMask = UIImageView(image: img)
        imgMask.tag = -100
        addSubview(imgMask)
        imgMask.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
    }
    
    func addMask(color:UIColor)  {
        for sub in self.subviews{
            if sub.tag == -100{
                return
            }
        }
        let vMask = UIView().bgColor(color: color)
        vMask.tag = -100
        addSubview(vMask)
        vMask.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
    }
    
    func removeMask() {
        for sub in self.subviews{
            if sub.tag == -100{
                sub.removeFromSuperview()
            }
        }
    }
}
