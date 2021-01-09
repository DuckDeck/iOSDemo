//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//

import UIKit
import SnapKit
import Gifu
import SwiftUI
import CommonLibrary
class GifViewController: UIViewController {
    var vc : UICollectionView!
    var arrFile = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
        initData()
    }
    
    func initView()  {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: (ScreenWidth - 30) / 2, height: (ScreenWidth - 30) / 2)
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vc = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        vc.backgroundColor = UIColor.white
        vc.register(GifCell.self, forCellWithReuseIdentifier: "cell")
        vc.delegate = self
        vc.dataSource = self
        view.addSubview(vc)
        vc.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        
    }
    
    func initData() {
        guard let url = Bundle.main.url(forResource: "gif0", withExtension: "gif") else{
            return
        }
        arrFile.append(url)
        arrFile.append(URL(string: "http://wx4.sinaimg.cn/mw690/92e8647aly1frt8slz750g20ah0czhe0.gif")!)
        arrFile.append(URL(string: "http://wx2.sinaimg.cn/mw690/92e8647aly1frt8sudfcgg20f008mx6q.gif")!)
        arrFile.append(URL(string: "http://wx4.sinaimg.cn/mw690/92e8647aly1frt8ri5yobg205k086b29.gif")!)
        arrFile.append(URL(string: "http://wx3.sinaimg.cn/mw690/92e8647aly1frt8ssryj4g207w0e0hdz.gif")!)
        arrFile.append(URL(string: "http://wx2.sinaimg.cn/mw690/92e8647aly1frt8r5uoeyg20f006ou0x.gif")!)
        //arrFile.append(URL(string: "https://www.52wubi.com/wbbmcx/tp/灰.gif".urlEncoded())!)

        vc.reloadData()
    }
}

extension GifViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFile.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GifCell
        cell.url = arrFile[indexPath.row]
        return cell
        
    }
    
    
}

class GifCell: UICollectionViewCell {
    let img = GIFImageView()
    let btnPlay = UIButton()
    var url:URL?{
        didSet{
            guard let u = url else {
                return
            }
            img.animate(withGIFURL: u)
            img.startAnimating()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(gray: 0.7)
        contentView.addSubview(img)
        img.contentMode = .scaleAspectFit
        img.snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.top.equalTo(5)
            m.width.equalTo(frame.size.width - 10)
            m.height.equalTo(frame.size.height - 33)
        }
        btnPlay.setTitle("Play", for: .selected)
        btnPlay.title(title: "Stop").setFont(font: 15).color(color: UIColor.red).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.bottom.equalTo(-5)
        }
        btnPlay.addTarget(self, action: #selector(playGif), for: .touchUpInside)
        
    }
    
    @objc func playGif() {
        if btnPlay.isSelected{
            img.startAnimatingGIF()
        }
        else{
            img.stopAnimatingGIF()
        }
        btnPlay.isSelected = !btnPlay.isSelected
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct GifImageDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = GifViewController
    
    func makeUIViewController(context: Context) -> GifViewController {
        return GifViewController()
    }
}


