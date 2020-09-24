//
//  ViewController.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class LinkGameViewController: UIViewController {
    var gameView:GameView?
    var leftTime:Int?
    var timer:Timer?
    var isPlaying = false
    var lostAlert:UIAlertController?
    var successAlert:UIAlertController?
    var btnStart:UIButton?
    var lblTime:UILabel?
    var vMenu:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        btnStart?.setBackgroundImage(UIImage(named: "start.png"), for: UIControl.State.normal)
        btnStart?.setBackgroundImage(UIImage(named: "start_down.png"), for: UIControl.State.highlighted)
        btnStart?.addTarget(self, action: #selector(LinkGameViewController.startGameClick), for: UIControl.Event.touchUpInside)
        vMenu?.addSubview(btnStart!)
        lblTime = UILabel(frame: CGRect(x: 178, y: 0, width: 135, height: 50))
        lblTime?.textColor = UIColor(red: 1, green: 1, blue: 9.0/15.0, alpha: 1)
        vMenu?.addSubview(lblTime!)
        
        lostAlert = UIAlertController(title: "失败", message: "游戏失败,重新开始?", preferredStyle: .alert).action(title: "确定", handle: { [weak self](alert) in
            self?.startGameClick(sender: self!.btnStart!)
        })
        
        
        successAlert = UIAlertController(title: "胜利！", message: "游戏胜利！重新开始？", preferredStyle: .alert).action(title: "确定", handle: { [weak self](alert) in
            self?.startGameClick(sender: self!.btnStart!)
        })

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func startGameClick(sender:UIButton){
        if timer != nil{
            timer?.invalidate()
        }
        leftTime = Constants.kDefaultTIme
        gameView?.startGame()
        isPlaying = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LinkGameViewController.refreshView), userInfo: nil, repeats: true)
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

