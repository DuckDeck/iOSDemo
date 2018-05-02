//
//  ImageTool.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class ImageTool {
    // 获取连连看所有图片的ID（约定所有图片ID以p_开头）
    static func allImageIds() -> [String]
    {
        let paths = Bundle.main.paths(forResourcesOfType: "png", inDirectory: nil)
        var imgPaths = [String]()
        for  path  in paths {
            let imageName = NSURL(string: path)!.lastPathComponent
            if imageName!.hasPrefix("p_")
            {
                imgPaths.append(imageName!)
            }
        }
        return imgPaths
    }
    
    
    static func getRandomImageIds(source:[String],size:Int)->[String]
    {
        var imgPaths = [String]()
        for _ in 0..<size
        {
            // 随机获取一个数字，大于、小于source.count的数值
            let index  = Int(arc4random()) % (source.count)
            let imgPath = source[index]
            imgPaths.append(imgPath)
        }
        return imgPaths
    }
    
    static func getPlayImageIds( size:Int) -> [String]{
        // 如果该数除2有余数，将size加1
        var size = size
        if size % 2 != 0{
            size = size + 1
        }
        // 再从所有的图片值中随机获取size的一半数量
        var imgPaths = getRandomImageIds(source: allImageIds(), size: size/2)
        imgPaths.merge(newArray: imgPaths) //融合,这样 就有两倍了
        var i = imgPaths.count
        while(i > 0){
            let k = i+1
            let j = Int(arc4random()) % k
            imgPaths.exchangeObjectAdIndex(IndexA: i, atIndexB: j)  //随机交换图片
           i -= 1
        }
        return imgPaths
    }
    
    
    static func getPlayImages(size:Int)->[PieceImage]{
        let imgPaths = getPlayImageIds(size:size)
        var imgs = [PieceImage]()
        var img:PieceImage
        for imgPath in imgPaths{
            img = PieceImage(image: UIImage(named: imgPath)!, imageId: imgPath)
            imgs.append(img)
        }
        return imgs
    }

}
