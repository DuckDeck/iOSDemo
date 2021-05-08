//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//

import Foundation
import SwiftUI
import CommonLibrary
public struct VideoProcessPage:View {
    @State private var isPresented = false
  public  var body: some View{
        List{
            NavigationLink("视频列表",destination:VideoListDemo().navigationBarTitle(Text("视频列表示例")))
            NavigationLink("录制视频",destination:VideoRecordDemo().navigationBarHidden(true))
           
            if #available(iOS 14.0, *) {
                Button("拍图拍视频"){
                    self.isPresented.toggle()
                }.fullScreenCover(isPresented: $isPresented, content: {
                    ShootDemo()
                })
            } else {
              
            }
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
