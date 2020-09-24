//
//  BaseBoard.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class BaseBoard: NSObject {
    func createPieces(pieces:[[Piece?]]) -> [Piece?]?{
        return nil
    }
    
    
    func create()->[[Piece?]]{
        // 创建FKPiece的二维数组
        var pieces = [[Piece?]()]
        pieces.remove(at: 0) //刚创建时多了一个，需要移除
        for _ in 0..<Constants.kXSize{
            var arr = [Piece?]()
            for _ in 0..<Constants.kYSize{
                arr.append(nil)
            }
            pieces.append(arr)
        }
        // 返回非空的FKPiece集合, 该集合由子类实现的方法负责创建
        let notNullPieces = self.createPieces(pieces: pieces)
        let playImages = ImageTool.getPlayImages(size: notNullPieces!.count)
        // 所有图片的宽、高都是相同的，随便取出一个方块的宽、高即可。
        let imageHeight = playImages[0].image.size.height
        let imageWidth = playImages[0].image.size.width
        // 遍历非空的Piece集合
        for i in 0..<notNullPieces!.count
        {
            // 依次获取每个Piece对象
            let piece = notNullPieces![i]
            piece?.pieceImage = playImages[i]
            // 计算每个方块左上角的X、Y坐标
            let x = CGFloat(piece!.indexX) * imageWidth + CGFloat(Constants.kBeginImageX)
            piece?.beginX = Int(x)
            let y =  CGFloat(piece!.indexY) * imageHeight + CGFloat(Constants.kBeginImageY)
            piece?.beginY = Int(y)
            // 将该方块对象放入方块数组的相应位置处
            pieces[piece!.indexX][piece!.indexY] = piece!
        }
        return pieces
    };
}

