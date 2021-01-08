import SwiftUI

public struct FoundationPage:View {
  public  var body: some View{
        List{
            NavigationLink("Algo",destination:AlgoMenuPage())
            NavigationLink("NetWork",destination:NetWorkMenuPage())
        }.navigationBarTitle(Text("UI"))
    
    }
    
    public init() {
        
    }
}
