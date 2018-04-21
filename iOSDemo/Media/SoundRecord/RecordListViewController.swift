
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
        let v = UITableView.createEmptyView(size: CGSize(width: ScreenWidth, height: 50), text: "目前没有音频文件", font: UIFont.systemFont(ofSize: 20), color: UIColor.brown)
        tb.setEmptyView(view: v, offset: 300)
        listRecordings()
    }

    func listRecordings() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            arrFiles = files.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
                
            })
            tb.emptyReload()
            
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
            tb.emptyReload()
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
            GrandCue.toast("正在播放\(url.lastPathComponent)")
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
    
    
    
    func deleteAudio(url:URL)   {
        
        UIAlertController.title(title: "删除该\(url.lastPathComponent)声音文件", message: nil).action(title: "确定", handle: {[weak self](action:UIAlertAction) in
            self?.deleteRecording(url)
        }).action(title: "取消", handle: nil).show()
        
        
    }
    
    func rename(url:URL) {
        let alert = UIAlertController(title: "Rename",
                                      message: "Rename Recording \(url.lastPathComponent)?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            [unowned alert] _ in
            print("yes was tapped \(url)")
            if let textFields = alert.textFields {
                let tfa = textFields as [UITextField]
                let text = tfa[0].text
                let newUrl = URL(fileURLWithPath: text!)
                self.renameRecording(url, to: newUrl)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
            print("no was tapped")
        }))
        alert.addTextField(configurationHandler: {textfield in
            textfield.placeholder = "Enter a filename"
            textfield.text = "\(url.lastPathComponent)"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func renameRecording(_ from: URL, to: URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let toURL = documentsDirectory.appendingPathComponent(to.lastPathComponent)
        
        print("renaming file \(from.absoluteString) to \(to) url \(toURL)")
        let fileManager = FileManager.default
        fileManager.delegate = self
        do {
            try FileManager.default.moveItem(at: from, to: toURL)
        } catch {
            print(error.localizedDescription)
            print("error renaming recording")
        }
        DispatchQueue.main.async {
            self.listRecordings()
            self.tb.emptyReload()
        }
    }
    func deleteRecording(_ url: URL) {
        
        print("removing file at \(url.absoluteString)")
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
            print("error deleting recording")
        }
        
        DispatchQueue.main.async {
            self.listRecordings()
           self.tb.emptyReload()
        }
    }
}

extension RecordListViewController:FileManagerDelegate{
    func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {
        
        print("should move \(srcURL) to \(dstURL)")
        return true
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
        
        btnDelete.title(title: "删除").setFont(font: 13).color(color: UIColor.red).addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(-10)
            m.centerY.equalTo(contentView)
            m.height.equalTo(30)
        }
        btnDelete.addTarget(self, action: #selector(deleteAudio), for: .touchUpInside)
        
        btnRename.title(title: "重命名").setFont(font: 13).color(color: UIColor.red).addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(btnDelete.snp.left).offset(-10)
            m.centerY.equalTo(contentView)
            m.height.equalTo(30)
        }
        btnRename.addTarget(self, action: #selector(rename), for: .touchUpInside)
    }
    
    @objc func rename() {
        block?(1,url!)
    }
    
    @objc func deleteAudio() {
        block?(0,url!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
