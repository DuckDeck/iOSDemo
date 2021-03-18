import SwiftUI

public struct UIPage:View {
  public  var body: some View{
        List{
            NavigationLink("snapkitViewTest",destination:SnapkitDemo())
            NavigationLink("UIDemoTest",destination:UIDemo())
        }.navigationBarTitle(Text("UI"))
    }
    
    public init() {
        
    }
}
