//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/12.
//

import SwiftUI
public struct AudioProcessPage:View {
  public  var body: some View{
        List{
            NavigationLink("音频列表",destination:AudioListDemo().navigationBarTitle(Text("音频列表示例")))
            NavigationLink("录制音频",destination:AudioRecordDemo().navigationBarTitle(Text("音频列表示例")))
        }.navigationBarTitle(Text("音频处理"))
    }
    
    public init() {
        
    }
}
