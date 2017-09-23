
import UIKit

class LinkPoint:NSObject {
    var x:Int
    var y:Int
    init(x:Int,y:Int) {
        self.x = x
        self.y = y
    }
    
    // swift 没有实现copyWithZone
    //    override func copy() -> AnyObject {
    //
    //    }
    
    

    
    override var hash:Int{
        get
        {
            return self.x*31+self.y
        }
    }
    
    override var description:String{
        get
        {
            return "{x=\(self.x),y=\(self.y)}"
        }
    }
    
}

extension LinkPoint{
     func isEqual(object: AnyObject?) -> Bool {
        if let target = object as? LinkPoint
        {
            return target.x==self.x&&target.y==self.y
        }
        else
        {
            return false
        }
    }
}
