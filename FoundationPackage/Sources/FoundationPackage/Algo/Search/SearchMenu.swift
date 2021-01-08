//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/7.
//
import SwiftUI
public struct SearchMenuPage:View {
  public  var body: some View{
        List{
            NavigationLink("二分查找",destination:BinarySearchPage())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}

