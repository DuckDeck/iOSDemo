
//
//  RecordListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 21/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import AVFoundation
class RecordListViewController: UIViewController {

    let tb = UITableView()
    var arrFiles:[URL]?
    var player: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let btnDelete = UIBarButtonItem(title: "删除所有录音", style: .plain, target: self, action: #selector(deleteAllRecord))
        navigationItem.rightBarButtonItem = btnDelete
        
        tb.dataSource = self
        tb.delegate = self
        tb.tableFooterView = UIView()
        tb.estimatedRowHeight = 60
        tb.separatorStyle = .none
        tb.register(AudioFileCell.self, forCellReuseIdentifier: "audio")
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.top.equalTo(NavigationBarHeight)
        }
        
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            arrFiles = files.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
              
            })
            tb.reloadData()
            
        } catch {
            print("could not get contents of directory at \(documentsDirectory)")
            print(error.localizedDescription)
        }
        
    }
    
    @objc func tick() {
        Log(message: "12313")
    }
    
    func deleteAllAudio() {
        if let files = arrFiles{
            let fileManager = FileManager.default
            for i in 0 ..< files.count {
                //                    let path = documentsDirectory.appendPathComponent(recordings[i], inDirectory: true)
                //                    let path = docsDir + "/" + recordings[i]
                
                //                    print("removing \(path)")
                print("removing \(files[i])")
                do {
                    try fileManager.removeItem(at: files[i])
                } catch {
                    print("could not remove \(files[i])")
                    print(error.localizedDescription)
                }
            }
            arrFiles?.removeAll()
            tb.reloadData()
            GrandCue.toast("已经全部删除")
        }
        
       
    }
    
    func play(_ url: URL) {
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch {
            self.player = nil
            print(error.localizedDescription)
            print("AVAudioPlayer init failed")
        }
        
    }
    
    @objc func deleteAllRecord() {
        UIAlertController.title(title: "删除所有声音文件", message: nil).action(title: "确定", handle: {[weak self](action:UIAlertAction) in
            self?.deleteAllAudio()
        }).action(title: "取消", handle: nil).show()
    }
}

extension RecordListViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFiles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath) as! AudioFileCell
        cell.url = arrFiles![indexPath.row]
        cell.block = {[weak self](action:Int,url:URL) in
            if action == 1{
                self?.rename(url: url)
            }
            else{
                self?.deleteAudio(url: url)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = arrFiles![indexPath.row]
        play(url)
    }
    
    func deleteAudio(url:URL)   {
    
    }
    
    func rename(url:URL) {
        
    }
}

class AudioFileCell: UITableViewCell {
    let lblName = UILabel()
    let lblAudioLength = UILabel()
    let btnRename = UIButton()
    let btnDelete = UIButton()
    var block:((_ action:Int,_ url:URL)->Void)?
    var url:URL?{
        didSet{
            guard let u = url else {
                return
            }
            lblName.text = u.lastPathComponent
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        lblName.setFont(font: 14).color(color: UIColor.darkGray).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(15)
            m.top.equalTo(10)
        }
        
        lblAudioLength.setFont(font: 12).color(color: UIColor.purple).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(15)
            m.top.equalTo(lblName.snp.bottom).offset(8)
        }
        
        btnDelete.title(title: "删除").color(color: UIColor.red).addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(-10)
            m.centerY.equalTo(contentView)
            m.width.equalTo(60)
            m.height.equalTo(30)
        }
        btnDelete.addTarget(self, action: #selector(deleteAudio), for: .touchUpInside)
        
        btnRename.title(title: "重命名").color(color: UIColor.red).addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(btnDelete.snp.left).offset(10)
            m.centerY.equalTo(contentView)
            m.width.equalTo(60)
            m.height.equalTo(30)
        }
        btnRename.addTarget(self, action: #selector(rename), for: .touchUpInside)
    }
    
    @objc func rename() {
        block(1,url!)
    }
    
    @objc func deleteAudio() {
        block(2,url!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
