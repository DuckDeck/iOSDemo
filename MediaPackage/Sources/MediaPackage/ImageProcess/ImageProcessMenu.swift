//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//
import SwiftUI
public struct ImageProcessPage:View {
  public  var body: some View{
        List{
            NavigationLink("压缩图片",destination:CompressImageDemo().navigationBarTitle(Text("压缩图片示例")))
            NavigationLink("GIF图片",destination:GifImageDemo().navigationBarTitle(Text("Gif图片示例")))
            NavigationLink("照片拍摄",destination:TakePhotoDemo().navigationBarTitle(Text("照片拍摄示例")))
            NavigationLink("添加水印",destination:AddWatermarkDemo().navigationBarTitle(Text("添加水印示例")))
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
