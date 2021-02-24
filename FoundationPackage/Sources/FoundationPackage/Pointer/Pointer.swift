//
//  File.swift
//  
//
//  Created by Stan Hu on 2021/2/23.
//

import SwiftUI
public struct PointerMenuPage:View {
  public  var body: some View{
        List{
            Text("swift中的指针分为两类：typed pointer 指定数据类型指针，即UnsafePointer<T>,其中T表示泛型   raw pointer 未指定数据类型的指针（原生指针），即UnsafeRawPointer")
            
        }.navigationBarTitle(Text("指针"))
    }
    
    public init() {
        
    }
}

