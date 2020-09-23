//
//  GameView.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
protocol GameViewDelegate{
    func checkWin(gameView:GameView)
}
class GameView: UIView {
    var gameService:GameService?
    var linkInfo:LinkLine?
    var selectedPiece:Piece?
    var delegate:GameViewDelegate?
    var selectedImage:UIImage?
    var soundIdGu:SystemSoundID = 0
    var soundIdDis:SystemSoundID = 0
    var bubbleColor:UIColor?
    override  init(frame: CGRect) {
        super.init(frame: frame)
        selectedImage = UIImage(named: "selected.png")
        let disUrl = Bundle.main.url(forResource: "dis", withExtension: "wav")
        let guUrl = Bundle.main.url(forResource: "gu", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(disUrl! as CFURL, &soundIdDis)
        AudioServicesCreateSystemSoundID(guUrl! as CFURL, &soundIdGu)
        bubbleColor = UIColor(patternImage: UIImage(named: "bubble.jpg")!)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func startGame(){
        gameService?.start()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        if gameService == nil{
            return
        }
        var piece:Piece?
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.clear(rect)
        ctx!.setStrokeColor((bubbleColor?.cgColor)!)
        ctx!.setLineWidth(10)
        ctx!.setLineJoin(CGLineJoin.round)
        ctx!.setLineCap(CGLineCap.round)
        let pieces = self.gameService?.pieces
        if pieces != nil{
            for i in 0..<pieces!.count{
                for j in 0..<pieces![i].count{
                    if pieces![i][j] != nil{
                        piece = pieces![i][j]
                        piece!.pieceImage!.image.draw(at: CGPoint(x: piece!.beginX!, y: piece!.beginY!))
                    }
                }
            }
        }
        if linkInfo != nil{
            drawLine(line: linkInfo!, ctx: ctx!)
            linkInfo = nil
            let delayTime = DispatchTime(uptimeNanoseconds: UInt64(0.25 * Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                   self.setNeedsDisplay()// 这个要延时0.3 秒，以后再想办法
            })
        
            
        }
        if selectedPiece != nil{
            selectedImage?.draw(at: CGPoint(x: selectedPiece!.beginX!, y:selectedPiece!.beginY!))
        }
    }
    
    func drawLine(line:LinkLine, ctx:CGContext){
        let points = line.arrPoints
        let firstPoint = points.first!
        ctx.move(to: CGPoint(x: CGFloat(firstPoint.x), y: CGFloat(firstPoint.y)))
     
        for i in 1..<points.count{
            ctx.addLine(to: CGPoint(x: CGFloat(points[i].x), y: CGFloat(points[i].y)))
        }
        ctx.strokePath()
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        _ = gameService?.pieces
        let touchPoint = touch.location(in: self)
        let piece = gameService?.findPieceAtTouchX(touchX: touchPoint.x, touchY: touchPoint.y)
        print("the piece is :x\(String(describing: piece?.indexX)) y:\(String(describing: piece?.indexY))")
        if piece == nil{
            return
        }
        if selectedPiece == nil{
            selectedPiece = piece
            AudioServicesPlaySystemSound(soundIdGu)
            setNeedsDisplay()
            return
        }
        else{
            let line = gameService?.linkWithPiece(p1: selectedPiece!, p2: piece!)
            if line == nil{
                selectedPiece = piece
                AudioServicesPlaySystemSound(soundIdGu)
                setNeedsDisplay()
 }
            else{
                AudioServicesPlaySystemSound(soundIdDis)
                //handleSuccess(line!, prevPiece: selectedPiece!, currPiece: piece!, pieces: pieces)
                handleSuccess(line: line!, prevPiece: selectedPiece!, currPiece: piece!)
                
                
            }
        }
    }
    func handleSuccess(line:LinkLine,prevPiece:Piece,currPiece:Piece){
        linkInfo = line
        selectedPiece = nil
        gameService?.pieces![prevPiece.indexX][prevPiece.indexY] = nil
        gameService?.pieces![currPiece.indexX][currPiece.indexY] = nil
        setNeedsDisplay()
        delegate?.checkWin(gameView: self)
    }
}
