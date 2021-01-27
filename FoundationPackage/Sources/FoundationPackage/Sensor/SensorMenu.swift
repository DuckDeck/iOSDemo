//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/26.
//

import SwiftUI

public struct SensorMenuPage:View {
  public  var body: some View{
        List{
            NavigationLink("动态传感器",destination:MotionSensorDemo())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}
