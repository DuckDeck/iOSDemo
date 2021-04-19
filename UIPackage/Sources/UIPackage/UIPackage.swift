import SwiftUI

public struct UIPage:View {
  public  var body: some View{
        List{
            NavigationLink("snapkitViewTest",destination:SnapkitDemo())
            NavigationLink("UIDemo",destination:UIDemo())
            NavigationLink("InfiniteTableDemo",destination:InfiniteTableDemo())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}
