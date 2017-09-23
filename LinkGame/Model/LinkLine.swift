
import UIKit

class LinkLine {
    var arrPoints:Array<LinkPoint>
    init(p1:LinkPoint,p2:LinkPoint) {
        arrPoints = Array<LinkPoint>()
        arrPoints.append(p1)
        arrPoints.append(p2)
    }
    init(p1:LinkPoint,p2:LinkPoint,p3:LinkPoint) {
        arrPoints = Array<LinkPoint>()
        arrPoints.append(p1)
        arrPoints.append(p2)
        arrPoints.append(p3)
        
    }
    init(p1:LinkPoint,p2:LinkPoint,p3:LinkPoint,p4:LinkPoint) {
        arrPoints = Array<LinkPoint>()
        arrPoints.append(p1)
        arrPoints.append(p2)
        arrPoints.append(p3)
        arrPoints.append(p4)
    }
}
