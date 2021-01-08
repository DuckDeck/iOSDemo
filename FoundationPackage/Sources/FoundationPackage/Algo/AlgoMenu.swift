//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/7.
//

import SwiftUI

public struct AlgoMenuPage:View {
  public  var body: some View{
        List{
            NavigationLink("查找",destination:SearchMenuPage())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}

