//
//  SnapkitTableViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/01/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import Kingfisher
class SnapkitTableViewController: UIViewController {

    let tb = UITableView()
    var arr = [Model1]()
    let vHead = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CELL 高度"
        createModel()
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(view)
        }
        
        vHead.backgroundColor = UIColor.yellow
        vHead.frame = CGRect(x: 0, y: 0, w: ScreenWidth, h: 300)
        
        tb.dataSource = self
        tb.delegate = self
        tb.register(SnapCell.self, forCellReuseIdentifier: "cell")
        tb.estimatedRowHeight = 300
        tb.tableFooterView = UIView()
        tb.separatorInset = UIEdgeInsets()
        tb.layoutMargins = UIEdgeInsets()
        tb.tableHeaderView = vHead
        //        tb.separatorStyle = .none
        //tb.rowHeight = UITableViewAutomaticDimension
        
//        let barBtn = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(addContent))
    }
    
//    func addContent() {
//
//    }
    
    

    func createModel() {
        var m = Model1()
        m.content = "小哥我在办公室有台式机2台，家里台式长期吃灰，更不用移动PC好多年。05年买的三星X05，用了12年，17年早些时候，180元在咸鱼也被我卖"
        m.img = "http://d.5857.com/yr_170908/001.jpg"
        arr.append(m)
        
        m = Model1()
        m.content = "小哥我在办公室有台式机2台，家里台式长期吃灰，更不17年早些时候，180元在咸鱼也被我卖"
        m.img = "http://d.5857.com/fkcjyx_160918/001.jpg"
        arr.append(m)
        
        m = Model1()
        m.content = "小哥我在办公室有台式机2台，家里台式长期吃灰，更不用移动PC好多年。05年买的三星X05，用了12年，17年早些时候，180元在咸鱼也被我卖"
        m.img = "http://d.5857.com/ozxz_180115/001.jpg"
        arr.append(m)
        
        m = Model1()
        m.content = "小哥我在办公室有台式机2台"
        m.img = "http://d.5857.com/qs_160621/004.jpg"
        arr.append(m)
        
        m = Model1()
        m.content = "很多人质疑我家为什么拿这么高的利息去买这个车，我可以给你们解释下。温州的民间借贷一直是中国领先的，往往很多借贷的事情，就是一句话。那么在资金闲置的情况下，大多人都是为守着旧业和放着较高利息的款(比如：一百万一年15万）。但是平时又不想每个月还很多导致自己资金紧张。所以就选择了奔驰的这种租"
        m.img = "http://d.5857.com/nbakl_160928/001.jpg"
        arr.append(m)
        
        m = Model1()
        m.content = "借模式的贷款方式。（平时假如需要用钱的话，十几万基本上就是跟附近朋友亲戚一句话的事情）我的第一辆车奔驰GLC260之购物中的套路和按揭 篇二：提车上牌加使用情况 但是这种温州特有的风气导致了温州人爱面子的不良风气。（在家省吃俭用，出门大方买单）因为没有检查的习惯，所以出现了一些很简单的错误，但是无伤大雅大家看的懂就可以了。一笔带过供大家言欢了。还是那句话，四儿子为什么加价。那是大家一个愿打一个愿挨，没什么酸不酸的。大家的价值观，世界观不同。你可以有你自己的意见，我也可以有。你可以说你自己意见，但是没必要让别人跟您一样。"
        m.img = "http://d.5857.com/fll_160511/001.jpg"
        arr.append(m)
        
        m = Model1()
        m.content = "小哥我在办公室有台"
        m.img = "http://d.5857.com/aaqcmeia_20181120/001.jpg"
        arr.append(m)
    }
}

extension SnapkitTableViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SnapCell
        cell.m = arr[indexPath.row]
        cell.index = indexPath
        let height = cell.systemLayoutSizeFitting(CGSize(width: ScreenWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        arr[indexPath.row].cellHeight = Float(height.height)
        cell.updateBlock = {(index:IndexPath) in
            tableView.reloadRows(at: [index], with: .automatic)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let m = arr[indexPath.row]
        if let h = m.cellHeight{
            return CGFloat(h)
        }
        else{
            return UITableView.automaticDimension
        }
    }
    
}

class SnapCell: UITableViewCell {
    let lbl = UILabel()
    let img = UIImageView()
    let lbl2 = UILabel()
    var index:IndexPath?
    var updateBlock:((_ index:IndexPath)->Void)?
    func setVisible(visible:Bool)  {
        if visible{
            lbl2.snp.remakeConstraints { (m) in
                m.left.equalTo(10)
                m.right.equalTo(-10)
                m.top.equalTo(lbl.snp.bottom).offset(5)
            }
        }
        else{
            lbl2.snp.remakeConstraints { (m) in
                m.left.equalTo(10)
                m.right.equalTo(-10)
                m.top.equalTo(lbl.snp.bottom).offset(5)
                m.height.equalTo(0)
            }
            
        }
    }
    
    var m:Model1?{
        didSet{
            if let s = m{
                lbl.text = s.content
                lbl2.text = s.content
                img.kf.setImage(with: URL(string: s.img)!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (imgData, err, type, url) in
                    if let i = imgData{
                       let scale = i.size.width / i.size.height
                        self.img.snp.updateConstraints({ (m) in
                            m.height.equalTo(ScreenWidth / scale) //在这里更新高度
                            //但是这样还是太慢了，因为这种要等图片下过来才能设定
                        })
                    }
                })
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lbl.layer.borderWidth = 1
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textColor = UIColor.orange
        lbl.numberOfLines = 0
        contentView.addSubview(lbl)
        lbl.snp.makeConstraints {
            $0.left.top.equalTo(10)
            $0.right.equalTo(-10)
        }

        
        
        lbl2.layer.borderWidth = 1
        lbl2.font = UIFont.systemFont(ofSize: 12)
        lbl2.textColor = UIColor.red
        lbl2.numberOfLines = 0
        contentView.addSubview(lbl2)
        lbl2.snp.makeConstraints {
            $0.left.equalTo(10)
            $0.right.equalTo(-10)
            $0.top.equalTo(lbl.snp.bottom).offset(5)
            $0.height.equalTo(0)
        }
        
        contentView.addSubview(img)
        img.snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(lbl2.snp.bottom).offset(20)
            m.bottom.equalTo(-20)
            m.height.equalTo(250)
        }
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    @objc func tap() {
        m?.isShow = !m!.isShow
        setVisible(visible: m!.isShow)
        updateBlock?(index ?? IndexPath(row: 0, section: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Model1: GrandModel {
    var id = 0
    var head = ""
    var name = ""
    var content = ""
    var img = ""
    var imgs : [String]?
    var isShow = false
}
