//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/7.
//

import Foundation

//这里写一个二分搜索的demo的图形化的一全演示

func binarySearch(nums:[Int],target:Int) -> Int {

    var start = 0,end = nums.count - 1
    var mid  = 0
    while start <= end {
       mid = start + (end - start) / 2
        if nums[mid] == target {
            return mid
        }
        else if nums[mid] > target {
            end = mid
        }
        else{
            start = mid
        }
    }
    return mid
}
