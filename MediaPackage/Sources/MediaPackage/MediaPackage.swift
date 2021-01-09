import SwiftUI

public struct MediaPage:View {
  public  var body: some View{
        List{
            NavigationLink("图片处理",destination:ImageProcessPage())
           
        }.navigationBarTitle(Text("多媒体"))
    }
    
    public init() {
        
    }
}
