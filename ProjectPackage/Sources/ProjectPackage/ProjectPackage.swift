import SwiftUI

public struct ProjectPage:View {
  public  var body: some View{
        List{
            NavigationLink("TouchTest",destination:TouchTestDemo())
            NavigationLink("五笔反查",destination:FiveStrokeDemo())
            NavigationLink("9点解锁",destination:PinLockDemo())
        }.navigationBarTitle(Text("项目示例"))
    }
    
    public init() {
        
    }
}
