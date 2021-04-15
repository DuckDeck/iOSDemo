//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/8.
//

import SwiftUI

public struct NetWorkMenuPage:View {
  public  var body: some View{
        List{
            NavigationLink("问卷(JS control)",destination:JSControlDemo())
            NavigationLink("WKWebView拦截http请求",destination:InterceptDemo())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}
