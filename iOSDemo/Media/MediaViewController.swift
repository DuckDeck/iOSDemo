//
//  MediaViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit

class MediaViewController: UIViewController {

    var arrData = ["CaptureVideo","Play Music","Add Watermark","Record Audio","Record Video","Take Photo",
                   "Gif","Palette","Compress Image","Push Live","Pull Live","OpenCV Test","ffmpeg"]
    var tbMenu = UITableView()
    
    override func loadView() {
        super.loadView()
        print("New ViewController LoadView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
        print("New ViewController viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       print("New ViewController viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("New ViewController viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("New ViewController viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("New ViewController viewDidDisappear")
    }
    deinit {
        print("New ViewController deinit")
    }
    
}

extension MediaViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrData[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(CaptureVideoViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(MusicListViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(WatermarkViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(SoundRecordViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(VideoListViewController(), animated: true)
        case 5:
            present(TakePhotoViewController(), animated: true, completion: nil)
        case 6:
            navigationController?.pushViewController(GifViewController(), animated: true)
        case 7:
            navigationController?.pushViewController(PaletteViewController(), animated: true)
        case 8:
            navigationController?.pushViewController(CompressImageViewController(), animated: true)
        case 9:
            navigationController?.pushViewController(PushLiveViewController(), animated: true)
        case 10:
            navigationController?.pushViewController(PullLiveViewController(), animated: true)
        case 11:
            navigationController?.pushViewController(opencvViewController(), animated: true)
        case 12:
            navigationController?.pushViewController(FFmpegViewController(), animated: true)
        default:
            break
        }
    }
}
