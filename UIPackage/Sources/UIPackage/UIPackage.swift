import SwiftUI

public struct UIPage:View {
  public  var body: some View{
        List{
            NavigationLink("snapkitViewTest",destination:SnapkitDemo())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}
