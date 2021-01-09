//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//

import Foundation
import SwiftUI
public struct VideoProcessPage:View {
  public  var body: some View{
        List{
            NavigationLink("播放视频",destination:CompressImageDemo().navigationBarTitle(Text("播放视频示例")))
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
