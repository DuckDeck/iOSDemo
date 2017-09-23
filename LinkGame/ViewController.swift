//
//  ViewController.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var gameView:GameView?
    var leftTime:Int?
    var timer:Timer?
    var isPlaying = false
    var lostAlert:UIAlertView?
    var successAlert:UIAlertView?
    var btnStart:UIButton?
    var lblTime:UILabel?
    var vMenu:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.sharedApplication.statusBarHidden = true
        view.backgroundColor = UIColor(patternImage: UIImage(named: "room.jpg")!)
        gameView = GameView(frame: UIScreen.main.bounds)
        gameView?.gameService = GameService()
        gameView?.delegate = self as? GameViewDelegate
        gameView?.backgroundColor = UIColor.clear
        view.addSubview(gameView!)
        vMenu = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 50, width: UIScreen.main.bounds.width, height: 50))
        gameView?.addSubview(vMenu!)
        btnStart = UIButton(frame: CGRect(x: 0, y: 0, width: 170, height: 50))
        btnStart?.setBackgroundImage(UIImage(named: "start.png"), for: UIControlState.normal)
        btnStart?.setBackgroundImage(UIImage(named: "start_down.png"), for: UIControlState.highlighted)
        btnStart?.addTarget(self, action: #selector(ViewController.startGameClick), for: UIControlEvents.touchUpInside)
        vMenu?.addSubview(btnStart!)
        lblTime = UILabel(frame: CGRect(x: 178, y: 0, width: 135, height: 50))
        lblTime?.textColor = UIColor(red: 1, green: 1, blue: 9.0/15.0, alpha: 1)
        vMenu?.addSubview(lblTime!)
        lostAlert = UIAlertView(title:"失败", message:"游戏失败,重新开始?", delegate:self, cancelButtonTitle:"取消")
        lostAlert?.addButton(withTitle: "确定")
        successAlert = UIAlertView(title: "胜利！", message: "游戏胜利！重新开始？", delegate: self, cancelButtonTitle: "取消")
        successAlert?.addButton(withTitle: "确定")
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func startGameClick(sender:UIButton){
        if timer != nil{
            timer?.invalidate()
        }
        leftTime = Constants.kDefaultTIme
        gameView?.startGame()
        isPlaying = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.refreshView), userInfo: nil, repeats: true)
        gameView?.selectedPiece = nil
    }
    
    @objc func refreshView(){
        lblTime?.text = "剩余时间：\(leftTime!)"
        leftTime  = leftTime! - 1
        if leftTime! < 0 {
            timer?.invalidate()
            isPlaying = false
            lostAlert?.show()
            return
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1{
            startGameClick(sender: btnStart!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkWin(gameView: GameView) {
        if !gameView.gameService!.hasPieces()
        {
            successAlert?.show()
            timer?.invalidate()
            isPlaying = false
        }
    }


}

