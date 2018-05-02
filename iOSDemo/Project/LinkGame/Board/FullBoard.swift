//
//  FullBoard.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class FullBoard: BaseBoard {
    override func createPieces(pieces:[[Piece?]]) -> [Piece?]?{
        var notNummPieces = Array<Piece?>()
        for i in 1..<pieces.count-1{
            for j in 1..<pieces[i].count-1{
                let piece = Piece(indexX: i, indexY: j)
                notNummPieces.append(piece)
            }
        }
        return notNummPieces
    }
}
