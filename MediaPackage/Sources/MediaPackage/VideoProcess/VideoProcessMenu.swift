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
            NavigationLink("录制视频",destination:VideoRecordDemo().navigationBarHidden(true))
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
