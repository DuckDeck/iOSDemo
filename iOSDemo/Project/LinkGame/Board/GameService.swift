//
//  GameService.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class GameService {
    var pieces:[[Piece?]]?
    func start(){
        var baseBoard:BaseBoard? = nil
        let index = arc4random() % 4
        switch index{
        case 0: baseBoard = FullBoard()
        default: baseBoard = FullBoard()
        }
        pieces = baseBoard?.create()
    }
    
    func hasPieces() -> Bool{
        for i in 0..<pieces!.count{
            for j in 0..<pieces![i].count{
                let a = pieces![i]
                let b = a[j]
                if b != nil{
                    return true
                }
            }
        }
        return false
    }
    // 根据触碰点的位置查找相应的方块
    func findPieceAtTouchX(touchX:CGFloat,touchY:CGFloat)->Piece?{
        // 由于在创建Piece对象的时候, 将每个Piece的开始坐标加了
        // beginImageX/beginImageY常量值, 因此这里要减去这个值
        let relativeX = touchX - CGFloat(Constants.kBeginImageX)
        let relativeY = touchY - CGFloat(Constants.kBeginImageY)
        if relativeX < 0 || relativeY < 0{
            return nil
        }
        let indexX = self.getIndexWithRelative(relative: Int(relativeX), size: Constants.kPieceWidth)
        let indexY = self.getIndexWithRelative(relative: Int(relativeY), size: Constants.kPieceHeight)
        if indexX<0 || indexY<0{
            return nil
        }
        if indexX >= Constants.kXSize || indexY >= Constants.kYSize{
            return nil
        }
        
        let piece = pieces == nil ? nil : pieces![indexX][indexY]
        return piece
    }
    
    func getIndexWithRelative(relative:Int,size:Int) -> Int{
        var index = -1
        if relative % size == 0{
            index = relative / size - 1
        }
        else{
            index = relative / size
        }
        return index
    }
    //判断两个Piece是否可以相连, 可以连接, 返回LinkLine对象
    func linkWithPiece(p1:Piece,p2:Piece) -> LinkLine?{
        if p1 == p2{
            return nil
        }
        if !p1.isTheSameImgae(object: p2){
            return nil
        }
        if p2.indexX < p2.indexX{
            return self.linkWithPiece(p1: p2,p2: p1)
        }
        let p1Point = p1.getCenter()
        print("p1点\(p1Point)")
        let p2Point = p2.getCenter()
        print("p2点\(p2Point)")
        // 如果两个Piece在同一行
        if p1.indexY == p2.indexY{
            if !self.isXBlock(p1: p1Point, p2: p2Point, pieceWidth: CGFloat(Constants.kPieceWidth)){
                return LinkLine(p1: p1Point, p2: p2Point)
            }
        }
        // 如果两个FKPiece在同一列
        if p1.indexX == p2.indexX{
            if !self.isYBlock(p1: p1Point, p2: p2Point, pieceHeight: CGFloat(Constants.kPieceHeight)){
                return LinkLine(p1: p1Point, p2: p2Point)
            }
        }
        // 有一个转折点的情况
        // 获取两个点的直角相连的点, 即只有一个转折点
        let cornerPoint = self.getConerPoint(p1: p1Point, p2: p2Point, width: Constants.kPieceWidth, height: Constants.kPieceHeight)
        if cornerPoint != nil{
            return LinkLine(p1: p1Point, p2: cornerPoint!, p3: p2Point)
        }
        // 该NSDictionaryp的key存放第一个转折点, value存放第二个转折点,
        // NSDictionary的count说明有多少种可以连的方式
        let turns = self.getLinkPoints(p1: p1Point, p2: p2Point, width: Constants.kPieceWidth, height: Constants.kPieceHeight)
        if turns.count >= 0 {
            return self.getShortcutFromPoints(p1: p1Point, p2: p2Point, turns: turns, shortDistance: Int(self.getDistance(p1: p1Point, p2: p2Point)))
        }
        return nil
    }
    
    //判断两个y坐标相同的点对象之间是否有障碍, 以p1为中心向右遍历
    func isXBlock(p1:LinkPoint,p2:LinkPoint,pieceWidth:CGFloat) -> Bool{
        if p2.x < p1.x{
            return self.isXBlock(p1: p2, p2: p1, pieceWidth: pieceWidth)
        }
       var i = CGFloat(p1.x) + pieceWidth
        while i <  CGFloat(p2.x){
            if self.hasPiece(x: Int(i), y: p1.y){
                return true
            }
            i = i + pieceWidth
        }
        return false
    }
    // 判断两个x坐标相同的点对象之间是否有障碍, 以p1为中心向下遍历
    func isYBlock(p1:LinkPoint,p2:LinkPoint,pieceHeight:CGFloat) -> Bool{
        if p2.y < p1.y{
            return self.isYBlock(p1: p2, p2: p1, pieceHeight: pieceHeight)
        }
        
        var i = CGFloat(p1.y) + pieceHeight
        while  i < CGFloat(p2.y) {
            if self.hasPiece(x:p1.x , y: Int(i)){
                return true
            }
            i = i + pieceHeight
        }
        
//        for var i = CGFloat(p1.y) + pieceHeight; i < CGFloat(p2.y); i = i + pieceHeight   {
//            if self.hasPiece(x:p1.x , y: Int(i)){
//                return true
//            }
//        }
        return false
    }
    
    //判断界面上的x, y坐标中是否有Piece对象
    func hasPiece(x:Int,y:Int) -> Bool{
        return self.findPieceAtTouchX(touchX: CGFloat(x), touchY: CGFloat(y)) != nil
    }
    //返回指定Point对象的上边通道
    func getUpChanel(p:LinkPoint,min:Int,height:Int) -> [LinkPoint]{
        var result:[LinkPoint] = [LinkPoint]()
        var i = p.y - height
        while  i >= min {
            if self.hasPiece(x: p.x, y: i){
                return result
            }
            result.append(LinkPoint(x: p.x, y: i))
          i = i - height
        }
//        for var i = p.y - height; i >= min; i = i - height{
//            if self.hasPiece(x: p.x, y: i){
//                return result
//            }
//            result.append(LinkPoint(x: p.x, y: i))
//        }
        return result
    }
    //返回指定Point对象的下边通道
    func getDownChanel(p:LinkPoint,max:Int,height:Int) -> [LinkPoint]{
        var result:[LinkPoint] = [LinkPoint]()
        var i = p.y + height
        while  i <= max {
            if self.hasPiece(x: p.x, y: i){
                return result
            }
            result.append(LinkPoint(x: p.x, y: i))
            i = i + height
        }
        return result
    }
    //返回指定Point对象的右边通道
    func getRightChanel(p:LinkPoint,max:Int,width:Int) -> [LinkPoint]{
        var result:[LinkPoint] = [LinkPoint]()
        var i = p.x + width
        while  i <= max {
            if self.hasPiece(x: i, y: p.y){
                return result
            }
            result.append(LinkPoint(x: i, y: p.y))
            i = i + width
        }
//        for var i = p.x + width; i <= max; i = i + width{
//            if self.hasPiece(x: i, y: p.y){
//                return result
//            }
//            result.append(LinkPoint(x: i, y: p.y))
//        }
        return result
    }
    
    //返回指定Point对象的左边通道
    func getLeftChanel(p:LinkPoint,min:Int,width:Int) -> [LinkPoint]{
        var result:[LinkPoint] = [LinkPoint]()
        var i = p.x - width
        while  i >= min {
            if self.hasPiece(x: i, y: p.y){
                return result
            }
            result.append(LinkPoint(x:i, y:p.y))
             i = i - width
        }
//        for var i = p.x - width; i >= min; i = i - width{
//            if self.hasPiece(x: i, y: p.y){
//                return result
//            }
//            result.append(LinkPoint(x:i, y:p.y))
//        }
        return result
    }
    
    
    //遍历两个通道, 获取它们的交点
    func getWrapPoint(p1Chanel:[LinkPoint],p2Chanel:[LinkPoint]) -> LinkPoint?{
        for p1 in p1Chanel{
            for p2 in p2Chanel{
                if p1.isEqual(p2){
                    return p1
                }
            }
        }
        return nil
    }
    //获取两个不在同一行或者同一列的坐标点的直角连接点, 即只有一个转折点
    func getConerPoint(p1:LinkPoint,p2:LinkPoint,width:Int,height:Int) -> LinkPoint?{
        if self.isLeftUp(p1: p1, p2: p2) || self.isLeftDown(p1: p1, p2: p2)
        {
            return self.getConerPoint(p1: p2, p2: p1, width: width, height: height)
        }
        let p1RightChanel = self.getRightChanel(p: p1, max: p2.x, width: width)
        let p1UpChanel = self.getUpChanel(p: p1, min: p2.y, height: height)
        let p1DownChanel = self.getDownChanel(p: p1, max: p2.y, height: height)
        let p2DownChanel = self.getDownChanel(p: p2, max: p1.y, height: height)
        let p2LeftChanel = self.getLeftChanel(p: p2, min: p1.x, width: width)
        let p2UpChanel = self.getUpChanel(p: p2, min: p1.y, height: height)
        if self.isRightUp(p1: p1, p2: p2){
            let linkPoint1 = self.getWrapPoint(p1Chanel: p1RightChanel, p2Chanel: p2DownChanel)
            let linkPoint2 = self.getWrapPoint(p1Chanel: p1UpChanel, p2Chanel: p2LeftChanel)
            return linkPoint1 == nil ?  linkPoint2 : linkPoint1
        }
        if self.isRightDown(p1: p1, p2: p2){
            let linkPoint1 = self.getWrapPoint(p1Chanel: p1DownChanel, p2Chanel: p2LeftChanel)
            let linkPoint2 = self.getWrapPoint(p1Chanel: p1RightChanel, p2Chanel: p2UpChanel)
            return linkPoint1 == nil ?  linkPoint2 : linkPoint1
            
        }
        return nil
    }
    //判断point2是否在point1的左上角
    func isLeftUp(p1:LinkPoint,p2:LinkPoint)->Bool{
        return p2.x < p1.x && p2.y < p1.y
    }
    //判断point2是否在point1的左下角
    func isLeftDown(p1:LinkPoint,p2:LinkPoint)->Bool{
        return p2.x < p1.x && p2.y > p1.y
    }
    //判断point2是否在point1的右上角
    func isRightUp(p1:LinkPoint,p2:LinkPoint)->Bool{
        return p2.x > p1.x && p2.y < p1.y
    }
    //判断point2是否在point1的右下角
    func isRightDown(p1:LinkPoint,p2:LinkPoint)->Bool{
        return p2.x > p1.x && p2.y > p1.y
    }
    
    //遍历两个集合, 先判断第一个集合的元素的y坐标与另一个集合中的元素y坐标相同(横向), 如果相同, 即在同一行, 再判断是否有障碍, 没有则加到Dictionary中去
    func getXLinkPoints(p1Chanel:[LinkPoint],p2Chanel:[LinkPoint],width:Int) -> Dictionary<LinkPoint,LinkPoint>{
        var result = Dictionary<LinkPoint,LinkPoint>()
        for p1 in p1Chanel{
            for p2 in p2Chanel
            {
                if p1.y == p2.y{
                    if !self.isXBlock(p1: p1, p2: p2, pieceWidth: CGFloat(width))
                    {
                        result[p1] = p2
                    }
                }
            }
        }
        return result
    }
    
    // 遍历两个集合, 先判断第一个集合的元素的x坐标与另一个集合中的元素x坐标相同(纵向),
    //如果相同, 即在同一列, 再判断是否有障碍, 没有则加到Dictionary中去
    func getYLinkPoints(p1Chanel:[LinkPoint],p2Chanel:[LinkPoint],height:Int) -> Dictionary<LinkPoint,LinkPoint>{
        var result = Dictionary<LinkPoint,LinkPoint>()
        for p1 in p1Chanel{
            for p2 in p2Chanel
            {
                if p1.x == p2.x{
                    if !self.isYBlock(p1: p1, p2: p2, pieceHeight: CGFloat(height))
                    {
                        result[p1] = p2
                    }
                }
            }
        }
        return result
    }
    
    //获取两个点之间的最短距离
    func getDistance(p1:LinkPoint,p2:LinkPoint) -> CGFloat{
        let xDistance = abs(p1.x - p2.x)
        let yDistance = abs(p1.y - p2.y)
        return CGFloat(xDistance + yDistance)
    }
    //计算Array中所有点的距离总和
    func countAll(points:[LinkPoint]) -> Int{
        var result = 0
        for i in 0...points.count-2
        {
            let p1 = points[i]
            let p2 = points[i+1]
            result = Int(self.getDistance(p1: p1, p2: p2))
        }
        return result
    }
    //从infos中获取连接线最短的那个LinkLine对象
    func getShortcutFromInfos(infos:[LinkLine], shortDistance:Int) -> LinkLine?{
        var temp1 = 0
        var result:LinkLine? = nil
        for i in 0..<infos.count{
            let info = infos[i]
            let distance = self.countAll(points: info.arrPoints)
            if i == 0{
                temp1 = distance - shortDistance
                result = info
            }
            if distance - shortDistance < temp1{
                temp1 = distance - shortDistance
                result = info
            }
        }
        return result
    }
    //获取p1和p2之间最短的连接信息
    func getShortcutFromPoints(p1:LinkPoint,p2:LinkPoint,turns:Dictionary<LinkPoint,LinkPoint>,shortDistance:Int) -> LinkLine?{
        var infos:[LinkLine] = [LinkLine]()
        for (tp1,tp2) in turns{
            infos.append(LinkLine(p1: p1, p2: tp1, p3: tp2, p4: p2))
        }
        return self.getShortcutFromInfos(infos: infos, shortDistance: shortDistance)
    }
    
    //获取两个转折点的情况
    func getLinkPoints(p1:LinkPoint,p2:LinkPoint,width:Int,height:Int)->Dictionary<LinkPoint,LinkPoint>{
        var result:Dictionary<LinkPoint,LinkPoint> = Dictionary<LinkPoint,LinkPoint>()
        var p1UpChanel = self.getUpChanel(p: p1, min: p2.y, height: height)
        var p1RightChanel  = self.getRightChanel(p: p1, max: p2.x, width: width)
        var p1DownChanel = self.getDownChanel(p: p1, max: p2.y, height: height)
        var p2DownChanel = self.getDownChanel(p: p2, max: p1.y, height: height)
        var p2LeftChanel = self.getLeftChanel(p: p2, min: p1.x, width: width)
        var p2UpChanel = self.getUpChanel(p: p2, min: p1.y, height: height)
        // 获取BaseBoard的最大高度
        let heightMax = (Constants.kYSize + 1) * height + Constants.kBeginImageY
        let widthMax = (Constants.kXSize + 1) * width + Constants.kBeginImageX
        
        if self.isLeftUp(p1: p1, p2: p2) || self.isLeftDown(p1: p1, p2: p2){
            return self.getLinkPoints(p1: p2, p2: p1, width: width, height: height)
        }
        if p1.y == p2.y{
            p1UpChanel = self.getUpChanel(p: p1, min: 0, height: height)
            p2UpChanel = self.getUpChanel(p: p2, min: 0, height: height)
            let upLinkPoints = self.getXLinkPoints(p1Chanel: p1UpChanel, p2Chanel: p2UpChanel, width: height)
            p1DownChanel = self.getDownChanel(p: p1, max: heightMax, height: height)
            p2DownChanel = self.getDownChanel(p: p2, max: heightMax, height: height)
            let downLinkPoints = self.getXLinkPoints(p1Chanel: p1DownChanel, p2Chanel: p2DownChanel, width: height)
            result.merge(newDict: upLinkPoints)
            result.merge(newDict: downLinkPoints)
        }
        if p1.x == p2.x{
            let p1LeftChanel = self.getLeftChanel(p: p1, min: 0, width: width)
            p2LeftChanel = self.getLeftChanel(p: p2, min: 0, width: width)
            let leftLinkPoints = self.getYLinkPoints(p1Chanel: p1LeftChanel, p2Chanel: p2LeftChanel, height: width)
            p1RightChanel = self.getRightChanel(p: p1, max: widthMax, width: width)
            let p2RightChanel = self.getRightChanel(p: p2, max: widthMax, width: width)
            let rightLinkPoints = self.getYLinkPoints(p1Chanel: p1RightChanel, p2Chanel: p2RightChanel, height: width)
            result.merge(newDict: leftLinkPoints)
            result.merge(newDict: rightLinkPoints)
        }
        if self.isRightUp(p1: p1, p2: p2){
            let upDownLinkPoints = self.getXLinkPoints(p1Chanel: p1UpChanel, p2Chanel: p2DownChanel, width: width)
            let rightLeftLinkPoints = self.getYLinkPoints(p1Chanel: p1RightChanel, p2Chanel: p2LeftChanel, height: height)
            p1UpChanel = self.getUpChanel(p: p1, min: 0, height: height)
            p2UpChanel = self.getUpChanel(p: p2, min: 0, height: height)
            let upUpLinkPoints = self.getXLinkPoints(p1Chanel: p1UpChanel, p2Chanel: p2UpChanel, width: width)
            p1DownChanel = self.getDownChanel(p: p1, max: heightMax, height: height)
            p2DownChanel = self.getDownChanel(p: p2, max: heightMax, height: height)
            let downDownLinkPoints = self.getXLinkPoints(p1Chanel: p1DownChanel, p2Chanel: p2DownChanel, width: width)
            p1RightChanel = self.getRightChanel(p: p1, max: widthMax, width: width)
            let p2RightChanel = self.getRightChanel(p: p2, max: widthMax, width: width)
            let rightRightLinkPoints = self.getYLinkPoints(p1Chanel: p1RightChanel, p2Chanel: p2RightChanel, height: height)
            let p1LeftChanel = self.getLeftChanel(p: p1, min: 0, width: width)
            p2LeftChanel = self.getLeftChanel(p: p2, min: 0, width: width)
            let leftLeftLinkPoints = self.getYLinkPoints(p1Chanel: p1LeftChanel, p2Chanel: p2LeftChanel, height: height)
            result.merge(newDict: upDownLinkPoints)
            result.merge(newDict: rightLeftLinkPoints)
            result.merge(newDict: upUpLinkPoints)
            result.merge(newDict: downDownLinkPoints)
            result.merge(newDict: rightRightLinkPoints)
            result.merge(newDict: leftLeftLinkPoints)
        }
        if self.isRightDown(p1: p1, p2: p2){
            let downUpLinkPoints = self.getXLinkPoints(p1Chanel: p1DownChanel, p2Chanel: p2UpChanel, width: width)
            let rightLeftLinkPoints = self.getYLinkPoints(p1Chanel: p1RightChanel, p2Chanel: p2LeftChanel, height: height)
            p1UpChanel = self.getUpChanel(p: p1, min: 0, height: height)
            p2UpChanel = self.getUpChanel(p: p2, min: 0, height: height)
            let upUpLinkPoints = self.getXLinkPoints(p1Chanel: p1UpChanel, p2Chanel: p2UpChanel, width: width)
            p1DownChanel = self.getDownChanel(p: p1, max: heightMax, height: height)
            p2DownChanel = self.getDownChanel(p: p2, max: heightMax, height: height)
            let downDownLinkPoints = self.getXLinkPoints(p1Chanel: p1DownChanel, p2Chanel: p2DownChanel, width: width)
            p1RightChanel = self.getRightChanel(p: p1, max: widthMax, width: width)
            let p2RightChanel = self.getRightChanel(p: p2, max: widthMax, width: width)
            let rightRightLinkPoints = self.getYLinkPoints(p1Chanel: p1RightChanel, p2Chanel: p2RightChanel, height: height)
            let p1LeftChanel = self.getLeftChanel(p: p1, min: 0, width: width)
            p2LeftChanel = self.getLeftChanel(p: p2, min: 0, width: width)
            let leftLeftLinkPoints = self.getYLinkPoints(p1Chanel: p1LeftChanel, p2Chanel: p2LeftChanel, height: height)
            result.merge(newDict: downUpLinkPoints)
            result.merge(newDict: rightLeftLinkPoints)
            result.merge(newDict: upUpLinkPoints)
            result.merge(newDict: downDownLinkPoints)
            result.merge(newDict: rightRightLinkPoints)
            result.merge(newDict: leftLeftLinkPoints)
        }
        return result
    }
}
