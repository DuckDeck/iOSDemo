
//
//  ShadowRangeManager.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/9/5.
//  Copyright © 2018 Stan Hu. All rights reserved.
//
import AVFoundation
class ShadowRangeManager {
    
    static var shareInstance:ShadowRangeManager? = ShadowRangeManager()
    
    var cachedRangeArray:[NSRange]?
    var url = ""
    
    static func completeDealloc() {
        //不知道这样行不行
        shareInstance = nil
    }
    
    func calculateRangeModelArrayForLoadingRequest(loadingRequest:AVAssetResourceLoadingRequest) -> [ShadowRangeInfo] {
        if url != loadingRequest.request.url!.absoluteString{
            cachedRangeArray = [NSRange]()
            url = loadingRequest.request.url!.absoluteString
        }
        let requestOffset = loadingRequest.dataRequest?.requestedOffset ?? 0
        let requestLength = loadingRequest.dataRequest?.requestedLength ?? 0
        let requestRange = NSRange(location: Int(requestOffset), length: requestLength)
        var rangeInfoArray = [ShadowRangeInfo]()
        if cachedRangeArray!.count == 0{
            let rangeInfo = ShadowRangeInfo(requestType: .RequestFromNet, requestRange: requestRange)
            rangeInfoArray.append(rangeInfo)
        }
        else{
              //先处理loadingRequest和本地缓存有交集的部分
            var cachedInfoArray = [ShadowRangeInfo]()
            for (_,value) in cachedRangeArray!.enumerated(){
                let intersectionRange = NSIntersectionRange(value, requestRange)
                if intersectionRange.length > 0{
                    let info = ShadowRangeInfo(requestType: .RequestFromCache, requestRange: intersectionRange)
                    rangeInfoArray.append(info)
                }
            }
            //围绕交集，进行需要网络请求的range的拆解
            if cachedInfoArray.count == 0{
                let info = ShadowRangeInfo(requestType: .RequestFromNet, requestRange: requestRange)
                rangeInfoArray.append(info)
            }
            else{
                for (index,value) in cachedInfoArray.enumerated(){
                    if index == 0{
                        if value.requestRange.location > requestRange.location{//在第一个cacheRange前还有一部分需要net请求
                            let info = ShadowRangeInfo(requestType: .RequestFromNet, requestRange: NSRange(location: requestRange.location, length: value.requestRange.location - requestRange.location))
                            rangeInfoArray.append(info)
                            //注意此处的rangModelArray是最终的包含该loadingRequest的全部rangeModel的数组，因此不要忘记将刚才cachedModelArray中的model也添加进来，而且要注意顺序，依次添加
                        }
                    }
                    else{
                        //除了首尾可能存在的两个（小于首个cachedModel 和 大于最后一个cachedModel）range，其他range都应该是夹在两个cachedModel之间的range，在此处处理
                        let lastCachedRangeModel = cachedInfoArray[index - 1]
                        let currentCachedRangeModel = cachedInfoArray[index]
                        let startOffset = lastCachedRangeModel.requestRange.location + lastCachedRangeModel.requestRange.length
                        let info = ShadowRangeInfo(requestType: .RequestFromNet, requestRange: NSRange(location: startOffset, length: currentCachedRangeModel.requestRange.location - startOffset))
                        rangeInfoArray.append(info)
                        rangeInfoArray.append(currentCachedRangeModel)
                    }
                    if index == cachedInfoArray.count - 1{
                        //最后一个cachedRange后面可能还有一段需要网络请求
                        let lastRangeInfo = cachedInfoArray.last!
                        if requestRange.location + requestRange.length > lastRangeInfo.requestRange.location + lastRangeInfo.requestRange.length{
                            let lastCacheRangeModelEndOffset = lastRangeInfo.requestRange.location + lastRangeInfo.requestRange.location
                            let info = ShadowRangeInfo(requestType: .RequestFromNet, requestRange: NSRange(location: lastCacheRangeModelEndOffset, length: requestRange.location + requestRange.length - lastCacheRangeModelEndOffset))
                            rangeInfoArray.append(info)
                        }
                    }
                }
            }
        }
        return rangeInfoArray
    
    }
    
    func addCacheRange(newRange:NSRange) {
        objc_sync_enter(cachedRangeArray!)
        if self.cachedRangeArray!.count > 0{
            var shouldRemoveArray = [Int]()
            var hasIntersection = false
            var firstMergeIndex = 0
            for (index,value) in cachedRangeArray!.enumerated(){
                let intersectionRange = NSIntersectionRange(value, newRange)
                if intersectionRange.length > 0{
                    //如果和已缓存range有交集的话，必能与其融为一体，融合后代替其位置
                    if !hasIntersection{
                        //第一次出现有交集的，直接融合替换即可
                        hasIntersection = true
                        firstMergeIndex = index
                        let startOffset = min(newRange.location, value.location)
                        let mergeLength = max(newRange.location + newRange.length, value.location + value.length) - startOffset
                        let mergeRange = NSRange(location: startOffset, length: mergeLength)
                        cachedRangeArray?.replaceObject(obj: mergeRange, adIndex: index)
                    }
                    else{
                         //有时newRange可能和多个cacheRange有交集，那就都合到一起
                        let lastMergedRange = cachedRangeArray![firstMergeIndex]
                        let startOffset = lastMergedRange.location
                        let mergeLength = max(lastMergedRange.location + lastMergedRange.length, value.length + value.length) - startOffset
                        let mergeRange = NSRange(location: startOffset, length: mergeLength)
                        cachedRangeArray?.replaceObject(obj: mergeRange, adIndex: firstMergeIndex)
                        shouldRemoveArray.append(index)
                    }
                }
            }
            cachedRangeArray?.removeAtIndexs(indexs: shouldRemoveArray)
            shouldRemoveArray.removeAll()
            //二、处理没有任何交集的range（注意首尾相接的情况）
            for (index,value) in cachedRangeArray!.enumerated(){
                if !shouldRemoveArray.contains(index){
                    ///此时shouldRemoveArray中包含的是已经合并过的，就不再做处理
                    if newRange.location < value.location{
                        ////newRange比cacheRange小（此处的小为range.location的大小，下文一致）
                        if newRange.location + newRange.length == value.location{
                            //new与cache首尾相接
                            cachedRangeArray?.replaceObject(obj: NSRange(location: newRange.location, length: newRange.length + value.length), adIndex: index)
                        }
                        else{
                            cachedRangeArray?.insert(newRange, at: index)
                        }
                        break //被合并或加入cachedRangeArray就不需要继续遍历其他cacheRange与其比较了
                    }
                    else{
                        if value.location + value.length == newRange.location{
                            //当new在cache之后时，有一种特殊情况就是首尾相接，那么此时仍要做合并处理
                            var hasHandle = false
                            if index + 1 < cachedRangeArray!.count{
                                //如果当前cacheRange不是self.cachedRangeArray中的最后一个元素时（保证cachedRangeArray中有下一位）
                                let nextRange = cachedRangeArray![index + 1]
                                if newRange.location + newRange.length == nextRange.location{
                                    //正好newRange的尾又与下一个的头相接（最多只能与两个cachedRange首尾相接，因为newRange和此时的所有cacheRange都没有交集，第一个循环处理已经把有交集的都合并了）
                                    hasHandle = true
                                    cachedRangeArray?.replaceObject(obj: NSRange(location: value.location, length: value.location + newRange.length + nextRange.location), adIndex: index)
                                    shouldRemoveArray.append( index + 1)
                                }
                            }
                            if !hasHandle{
                                //如果只是单纯的一个首尾相接，则执行此处
                                cachedRangeArray?.replaceObject(obj: NSRange(location: value.location, length: value.length + newRange.length), adIndex: index)
                            }
                            break
                        }
                        else{
                            //首尾不相接
                            if index == cachedRangeArray!.count - 1{
                                //在cachedRange后且不首尾相接的newRange，正常是交给下一个cachedRange处理的，但如果是最后一个cachedRange，则没有下一个，直接在此做判断
                                cachedRangeArray?.append(newRange)
                                break
                            }
                        }
                    }
                }
            }
            cachedRangeArray?.removeAtIndexs(indexs: shouldRemoveArray)
        }
        else{
            cachedRangeArray?.append(newRange)
        }
        objc_sync_exit(cachedRangeArray!)
    }
}
