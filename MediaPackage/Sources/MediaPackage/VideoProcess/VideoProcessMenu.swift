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
            NavigationLink("视频列表",destination:VideoListDemo().navigationBarTitle(Text("视频列表示例")))
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
