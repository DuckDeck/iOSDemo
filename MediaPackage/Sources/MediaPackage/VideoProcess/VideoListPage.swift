//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//

import UIKit
import AVKit
import CommonLibrary
import SwiftUI
class VideoListViewController: UIViewController {
    
    var vc : UICollectionView!
    var arrFile = [VideoModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
        initData()
    }
    
    func initView()  {
        
        
        authAudio()
        authVideo()
        
        let btnRecord = UIBarButtonItem(title: "录视频", style: .plain, target: self, action: #selector(recordVideo))
        let btnNetwork = UIBarButtonItem(title: "网络视频", style: .plain, target: self, action: #selector(showNetworkVideo))
        navigationItem.rightBarButtonItems = [btnNetwork,btnRecord]
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: (ScreenWidth - 30) / 2, height: (ScreenWidth - 30) / 2)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vc = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        vc.backgroundColor = UIColor.white
        vc.register(VideoImageCell.self, forCellWithReuseIdentifier: "cell")
        vc.delegate = self
        vc.dataSource = self
        vc.setEmptyView(view: UICollectionView.createEmptyView(size: CGSize(width: 300, height: 100), img: "file_not_exist", text: NSAttributedString(string: "没有视频😌")), offset: 300)
        view.addSubview(vc)
        vc.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
    }
    
    func initData() {
        let files = FileManager.getAllVideos()
        arrFile = files.map({ (url) -> VideoModel in
            return VideoModel(url: url, coverImg: Tool.thumbnailImageForVideo(url: url), fileName: url.lastPathComponent)
        })
        vc.emptyReload()
    }
    
    @objc func showNetworkVideo() {
        //http://dev.qiniu-app.yihuivip.cn/15351672430
        //http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4
        let url = URL(string: "https://lovelive.ink:19996/file/1594266552cxh.mp4")
        let vc = ShadowVideoPlayerViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.url = url
        
        present(vc, animated: true, completion: nil)
    }
    
    @objc func recordVideo() {
        let vc = VideoRecordViewController()
        vc.uploadVideoBlock = {(url:URL) in
            let m = VideoModel(url: url, coverImg: Tool.thumbnailImageForVideo(url: url), fileName: url.lastPathComponent)
            self.arrFile.insert(m, at: 0)
            self.vc.reloadData()
        }
        vc.modalPresentationStyle = .fullScreen
        present(VideoRecordViewController(), animated: true) {
            print("123")
        }
    }
    
    
    
    func authVideo() {
        let status = Auth.isAuthCamera()
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Video)
        case .notDetermined:
            Auth.authCamera { (res) in
                if(res){
                    
                }
                else{
                    Toast.showToast(msg: "摄像头授权失败")
                }
            }
            
        default:
            break
        }
    }
    
    func authAudio() {
        let status = Auth.isAuthMicrophone()
        
        switch status {
        case .denied , .restricted:
            Auth.showEventAccessDeniedAlert(view: self, authTpye: .Audio)
        case .notDetermined:
            Auth.authMicrophone { (res) in
                if(res){
                    
                }
                else{
                    Toast.showToast(msg: "麦克风授权失败")
                }
            }
            
        default:
            break
        }
    }
}

extension VideoListViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFile.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoImageCell
        cell.img.image = UIImage(named: "10")
        cell.lblTitle.text = "Look"
        cell.model = arrFile[indexPath.row]
        cell.addLongPressGesture { (press) in
            UIAlertController.title(title: "你要删除该视频吗", message: "删除").action(title: "Cancel", handle: nil).action(title: "Confirm", handle: { (alert) in
                let file = self.arrFile.remove(at: indexPath.row)
                try? FileManager.default.removeItem(at: file.url)
                self.vc.reloadData()
            }).show()
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = arrFile[indexPath.row].url
        let vc = VideoPlayViewController()
        vc.url = url!
        vc.modalPresentationStyle = .fullScreen
        vc.deleteBlock = {(url:URL) in
            self.initData()
        }
        //搞一个错误的视频
//        let str = url!.absoluteString.replacingOccurrencesOfString(".", withString: "_")
//        let newUrl = URL(string: str)
//        vc.url = newUrl!
        present(vc, animated: true, completion: nil)
//        let avPlayer = AVPlayer(url: url!)
//        let vc = AVPlayerViewController()
//        vc.player = avPlayer
//        vc.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
//        vc.showsPlaybackControls = true
//        vc.view.frame = view.bounds
//        addChildViewController(vc)
//        view.addSubview(vc.view)
//        vc.player?.play()
        
    }
    
}

class VideoImageCell: UICollectionViewCell {
    let img = UIImageView()
    let lblTitle = UILabel()
    var model:VideoModel?{
        didSet{
            guard let m = model else {
                return
            }
            img.image = m.coverImg
            lblTitle.text = m.fileName
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(gray: 0.3)
        contentView.addSubview(img)
        img.contentMode = .scaleAspectFit
        img.snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.top.equalTo(5)
            m.width.equalTo(frame.size.width - 10)
            m.height.equalTo(frame.size.height - 33)
        }
        
        lblTitle.txtAlignment(ali: .center).setFont(font: 15).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.bottom.equalTo(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct VideoModel {
    var url:URL!
    var coverImg:UIImage?
    var fileName = ""
}
struct VideoListDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = VideoListViewController
    
    func makeUIViewController(context: Context) -> VideoListViewController {
        return VideoListViewController()
    }
}


