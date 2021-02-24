import SwiftUI

public struct FoundationPage:View {
  public  var body: some View{
        List{
            NavigationLink("Algo",destination:AlgoMenuPage())
            NavigationLink("NetWork",destination:NetWorkMenuPage())
            NavigationLink("Sensor",destination:SensorMenuPage())
            NavigationLink("Pointer",destination:PointerMenuPage())
        }.navigationBarTitle(Text("UI"))
    
    }
    
    public init() {
        
    }
}
