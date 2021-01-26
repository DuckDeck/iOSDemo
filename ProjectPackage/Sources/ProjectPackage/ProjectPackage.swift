import SwiftUI

public struct ProjectPage:View {
  public  var body: some View{
        List{
            NavigationLink("TouchTest",destination:TouchTestDemo())
        }.navigationBarTitle(Text("项目示例"))
    }
    
    public init() {
        
    }
}
