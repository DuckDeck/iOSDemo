//
//  FlowLayout.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/21.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewLayout {
 
    var columnCount = 2
    var columnMargin = 5
    var arrColsHeight:[Double]!
   
    var colWidth = 0.0
    var heightBlock:((_ index:IndexPath)->Double)?
    
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(columnCount:Int ,columnMargin:Int,heightBlock:@escaping ((_ index:IndexPath)->Double)) {
        self.init()
        self.columnCount = columnCount
        self.columnMargin = columnMargin
        self.heightBlock = heightBlock
    }
    
    override func prepare() {
        super.prepare()
        colWidth = Double((collectionView!.frame.size.width - CGFloat(columnCount + 1) * columnMargin) / CGFloat(columnCount))
        arrColsHeight = nil
    }

   
    override var collectionViewContentSize: CGSize{
        get{
            if arrColsHeight == nil{
                 arrColsHeight = [Double].init(repeating: 0.0, count: columnCount)
            }
            let longest = arrColsHeight!.max()
            return CGSize(width: Double(collectionView!.frame.size.width), height: longest!)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var shortest = arrColsHeight![0]
        var shortCol = 0
        for i in 0..<arrColsHeight!.count{
            if shortest > arrColsHeight![i]{
                shortest = arrColsHeight![i]
                shortCol = i
            }
        }
        let x = (shortCol + 1) * columnMargin + shortCol * colWidth
        let y = shortest + columnMargin
        
        var height:Double  = 0
        assert(heightBlock != nil,"heightBlock can not be nil")
        if let hb = heightBlock{
            height = hb(indexPath) //这里的问题就是不能用自动计算高度了
        }
        attr.frame = CGRect(x: x, y: y, width: colWidth, height: height)
        arrColsHeight![shortCol] = shortest + columnMargin + height
        return attr
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var arr = [UICollectionViewLayoutAttributes]()
        let items = collectionView!.numberOfItems(inSection: 0)
        for i in 0..<items{
            let attr = layoutAttributesForItem(at: IndexPath(item: i, section: 0))
            arr.append(attr!)
        }
        return arr
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
