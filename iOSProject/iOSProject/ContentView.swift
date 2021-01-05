//
//  ContentView.swift
//  iOSProject
//
//  Created by shadowedge on 2021/1/4.
//

import SwiftUI
import UIPackage
import MediaPackage
enum Tab{
    case ui,media,project
}
struct ContentView: View {
    @State private var selection: Tab = .ui
    @State private var selectTitle: String = "ui"

    var body: some View {

        NavigationView{
            TabView(selection: $selection){
                UIPage().tabItem { Image(systemName: "tray")
                    Text("UI")
                }.tag(Tab.ui)
                MediaPage().tabItem { Image(systemName: "play.rectangle.fill")
                    Text("多媒体")
                }.tag(Tab.media)
            }.navigationBarTitle(self.selectTitle,displayMode: .inline)
            .onChange(of: selection, perform: { value in
                switch(value){
                case .ui:
                    self.selectTitle = "UI"
                case.media:
                    self.selectTitle = "多媒体"
                case .project:
                    self.selectTitle = "项目"
                }
            })
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
