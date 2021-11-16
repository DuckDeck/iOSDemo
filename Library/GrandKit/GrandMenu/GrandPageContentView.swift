//
//  GrandPageContentView.swift
//  GrandMenuDemo
//
//  Created by Stan Hu on 21/9/2017.
//  Copyright © 2017 Qfq. All rights reserved.
//

import UIKit

@objc public protocol GrandPageContentViewDelagate {
  @objc optional  func contentViewWillBeginDragging(contentview:GrandPageContentView)
  @objc optional  func contentViewDidScroll(contentview:GrandPageContentView,startIndex:CGFloat,endIndex:CGFloat,progress:CGFloat)
  @objc optional  func contentViewDidEndDecelerating(contentview:GrandPageContentView,startIndex:CGFloat,endIndex:CGFloat)
}

open class GrandPageContentView: UIView {
     let cellId = "GrandCelId"

    weak open var delegate:GrandPageContentViewDelagate?
    open var contentViewCurrentIndex = 0{
        didSet{
            if contentViewCurrentIndex < 0 || contentViewCurrentIndex > self.childViewController!.count-1{
                return
            }
            isSelectBtn = true
            let path = IndexPath(row: self.contentViewCurrentIndex, section: 0)
            collectionView?.scrollToItem(at: path, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    open var contentViewCanScroll = true{
        didSet{
             self.collectionView?.isScrollEnabled = self.contentViewCanScroll
        }
    }
    open var isNeedNearPagePreload = true
    weak fileprivate var parentViewController:UIViewController?
    fileprivate var childViewController:[UIViewController]?
    fileprivate var collectionView:UICollectionView?
    fileprivate var startOffsetX:CGFloat = 0.0
    fileprivate var isSelectBtn = false
    
    public init(frame: CGRect,childViewControllers:[UIViewController],parentViewController:UIViewController,delegate:GrandPageContentViewDelagate) {
        super.init(frame: frame)
        self.parentViewController = parentViewController
        self.childViewController = childViewControllers
        self.delegate = delegate
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.itemSize = self.bounds.size
        collectionViewFlowLayout.minimumLineSpacing = 0
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: collectionViewFlowLayout)
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.bounces = false
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        for vc in self.childViewController!{
            self.parentViewController?.addChild(vc)
        }
        
        addSubview(self.collectionView!)
    }
    

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension GrandPageContentView:UICollectionViewDataSource,UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.childViewController?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        cell.contentView.subviews.forEach { (v) in  // because reuse, you need remove the previous view
            v.removeFromSuperview()
        }
        let childVc = self.childViewController![indexPath.item]
        if isNeedNearPagePreload{
            if let count = self.childViewController?.count{
                if count >= 2{
                    if indexPath.item > 0 && indexPath.item < count - 1{
                        assert( self.childViewController![indexPath.item - 1].view != nil)
                        assert( self.childViewController![indexPath.item + 1].view != nil)
                    }
                    else if indexPath.item == 0{
                        assert( self.childViewController![indexPath.item + 1].view != nil)
                    }
                    else{
                        assert( self.childViewController![indexPath.item - 1].view != nil)
                    }
                }
            }
        }
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        return cell
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isSelectBtn = false
        startOffsetX = scrollView.contentOffset.x
        delegate?.contentViewWillBeginDragging?(contentview: self)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSelectBtn {
            return
        }
        let scrollWidth = scrollView.bounds.size.width
        let currentOffsetX = scrollView.contentOffset.x
        let startIndex = floor(startOffsetX / scrollWidth)
        var endIndex:CGFloat = 0
        var progress:CGFloat = 0
        if currentOffsetX > startOffsetX {
            progress = (currentOffsetX - startOffsetX)/scrollWidth
            endIndex = startOffsetX + 1
            if endIndex > CGFloat(self.childViewController!.count - 1) {
                endIndex = CGFloat(self.childViewController!.count - 1)
            }
        }
        else if currentOffsetX == startOffsetX{
            progress = 0.0
            endIndex = startIndex
        }
        else{
            progress = (startOffsetX - currentOffsetX)/scrollWidth
            endIndex = startIndex - 1
            endIndex = endIndex < 0 ? 0 : endIndex
        }
        delegate?.contentViewDidScroll?(contentview: self, startIndex: startIndex, endIndex: endIndex, progress: progress)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.bounds.size.width
        let currentOffsetX = scrollView.contentOffset.x
        let startIndex = floor(startOffsetX / scrollViewWidth)
        let endIndex = floor(currentOffsetX / scrollViewWidth)
        delegate?.contentViewDidEndDecelerating?(contentview: self, startIndex: startIndex, endIndex: endIndex)
    }
    
}
