//
//  ContentView.swift
//  iOSProject
//
//  Created by shadowedge on 2021/1/4.
//

import SwiftUI
import UIPackage
import MediaPackage
import FoundationPackage
import ProjectPackage
enum Tab{
    case ui,media,project,foundation
}
struct ContentView: View {
    @State private var selection: Tab = .foundation
    @State private var selectTitle: String = "ui"

    var body: some View {

        NavigationView{
            TabView(selection: $selection){
                FoundationPage().tabItem { Image(systemName: "number.circle")
                    Text("Foundation")
                }.tag(Tab.foundation)
                UIPage().tabItem { Image(systemName: "tray")
                    Text("UI")
                }.tag(Tab.ui)
                MediaPage().tabItem { Image(systemName: "play.rectangle.fill")
                    Text("多媒体")
                }
                .tag(Tab.media)
                ProjectPage().tabItem { Image(systemName: "command")
                    Text("项目示例")
                }
                .tag(Tab.project)
            }.navigationBarTitle(self.selectTitle,displayMode: .inline)
            .onChange(of: selection, perform: { value in
                switch(value){
                case .ui:
                    self.selectTitle = "UI"
                case.media:
                    self.selectTitle = "多媒体"
                case .project:
                    self.selectTitle = "项目"
                case .foundation:
                    self.selectTitle = "基础"
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
