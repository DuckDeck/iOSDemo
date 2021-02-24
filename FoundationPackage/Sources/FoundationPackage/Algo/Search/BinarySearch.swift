//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/7.
//

import SwiftUI


public struct BinarySearchPage:View {
  public  var body: some View{
        List{
            Text("最基本的二分查找就是从数组的中间取数。再和给定的数据比较大小，根据比较的结果缩小搜索范围，再重复前面的搜索过程，时间复杂度是O[logn]，空间复杂度是O[1]")
            Text("如果这个已经排好序的数组的内部元素分布十分不均匀，那么二分查找执行起来效率会有所降低")
            Text("二分搜索是一种从一个有序(有般是小到大)的数组中找出给定的一个指定元素,因为是有序的，所以每次都可以取该数组中间的一个数和给定的数比较小，再根据大小从新的区域重复这个查找过程，因此可以使用递归和循环来实现。")
            Button("查看最基本的二分查找写法") {
                print("查看最基本的二分查找写法")
            }
        }.navigationBarTitle(Text("二分查找"))
   
    }
    
    public init() {
        
    }
}

