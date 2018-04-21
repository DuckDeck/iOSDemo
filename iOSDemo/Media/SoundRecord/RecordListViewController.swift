
//
//  RecordListViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 21/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class RecordListViewController: UIViewController {

    var timer:GrandTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        timer = GrandTimer.scheduleTimerWithTimeSpan(TimeSpan.fromSeconds(1), target: self, sel: #selector(tick), userInfo: nil, repeats: true, dispatchQueue: DispatchQueue.main)
        let btnDelete = UIBarButtonItem(title: "删除所有录音", style: .plain, target: self, action: #selector(deleteAllRecord))
        navigationItem.rightBarButtonItem = btnDelete
    }
    
    @objc func tick() {
        Log(message: "12313")
    }
    
    @objc func deleteAllRecord() {
        
        timer.fire()
        return
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            //                let files = try fileManager.contentsOfDirectory(at: documentsDirectory)
            var recordings = files.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
                //                    return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                //                    let path = documentsDirectory.appendPathComponent(recordings[i], inDirectory: true)
                //                    let path = docsDir + "/" + recordings[i]
                
                //                    print("removing \(path)")
                print("removing \(recordings[i])")
                do {
                    try fileManager.removeItem(at: recordings[i])
                } catch {
                    print("could not remove \(recordings[i])")
                    print(error.localizedDescription)
                }
            }
            GrandCue.toast("已经全部删除")
            
        } catch {
            print("could not get contents of directory at \(documentsDirectory)")
            print(error.localizedDescription)
        }

    }

  

}
