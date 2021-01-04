import SwiftUI

public struct UIPage:View {
  public  var body: some View{
        List{
            NavigationLink("snapkitView",destination:SnapkitDemo())
        }
    }
    
    public init() {
        
    }
}
