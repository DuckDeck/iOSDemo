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
            NavigationLink("压缩图片",destination:CompressImageDemo())
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
