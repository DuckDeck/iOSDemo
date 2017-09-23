
import UIKit

class Piece:NSObject {
    var pieceImage:PieceImage?
    var beginX:Int?
    var beginY:Int?
    var indexX:Int
    var indexY:Int
    
    init(indexX:Int,indexY:Int) {
        self.indexX = indexX
        self.indexY = indexY
    }
    
    func getCenter()->LinkPoint{
        return LinkPoint(x:Int( self.pieceImage!.image.size.width/2)+self.beginX!, y: Int(self.pieceImage!.image.size.height/2)+self.beginY!)
    }
    
     func isEqual(object: AnyObject?) -> Bool {
        if let newPiece = object as? Piece
        {
            if self.pieceImage == nil
            {
                if newPiece.pieceImage != nil
                {
                    return false
                }
            }
            
            return self.pieceImage?.imageId == newPiece.pieceImage?.imageId && self.indexX == newPiece.indexX && self.indexY == newPiece.indexY
        }
        else
        {
            return false
        }
    }
    
    func isTheSameImgae(object: AnyObject?) -> Bool {
        if let newPiece = object as? Piece
        {
            if self.pieceImage == nil
            {
                if newPiece.pieceImage != nil
                {
                    return false
                }
            }
            
            return self.pieceImage?.imageId == newPiece.pieceImage?.imageId
        }
        else
        {
            return false
        }
    }
}
