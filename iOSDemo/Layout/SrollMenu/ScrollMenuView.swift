//
//  ScrollMenuView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
let count = 5000
class ScrollMenuView: UIView,UITableViewDataSource,UITableViewDelegate {

    var tb = UITableView()
    var arrData:[model]?
    override init(frame: CGRect) {
        arrData = [model]()
        var m = model()
        m.name = "111111"
        m.url = "1"
        arrData?.append(m)
        m = model()
        m.name = "22222"
        m.url = "2"
        arrData?.append(m)
        m = model()
        m.name = "33333"
        m.url = "3"
        arrData?.append(m)
        m = model()
        m.name = "44444"
        m.url = "4"
        arrData?.append(m)
        m = model()
        m.name = "55555"
        m.url = "5"
        arrData?.append(m)
        
        
        super.init(frame: frame)
        tb = UITableView()
        tb.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        tb.frame = self.bounds
        tb.bounces = false
        tb.scrollsToTop = true
        tb.separatorStyle = .none
        tb.showsVerticalScrollIndicator = false
        tb.delegate = self
        tb.dataSource = self
        addSubview(tb)
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        let  index = IndexPath(row: count / 2, section: 0)
        tb.scrollToRow(at: index, at: .middle, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? demoCell
        if cell == nil{
            cell = demoCell(style: .default, reuseIdentifier: "cell")
            cell?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            cell?.selectionStyle = .none
        }
        let m = arrData![indexPath.row % arrData!.count]
        cell?.mo = m
        return cell!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(scrollView.isDecelerating)
        print(scrollView.isDragging)
        if scrollView.isDragging{
            return
        }
        print(scrollView.contentOffset)
        let y = round( (scrollView.contentOffset.y + 150) / self.frame.size.height)
        print(y)
        
        let index = IndexPath(row: Int(y), section: 0)
        
        tb.selectRow(at: index, animated: true, scrollPosition: .middle)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let y = round( (scrollView.contentOffset.y + 150) / self.frame.size.height)
        
        
        let index = IndexPath(row: Int(y), section: 0)
        
        tb.selectRow(at: index, animated: true, scrollPosition: .middle)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? demoCell{
            let m = cell.mo!
            m.isSelect = !m.isSelect
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class demoCell : UITableViewCell {
    
    var img = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var lbl = UILabel(frame: CGRect(x: 0, y: 100, width: 100, height: 30))
    var block:((_ view:demoCell)->Void)?
    var mo:model?{
        didSet{
            if let m = mo{
                lbl.text = m.name
                img.image = UIImage(named: m.url)
                if m.isSelect {
                    img.frame = CGRect(x: img.frame.origin.x, y: img.frame.origin.y, width: 120, height: 120)
                }
                else{
                    img.frame = CGRect(x: img.frame.origin.x, y: img.frame.origin.y, width: 100, height: 100)
                }
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        contentView.addSubview(img)
        lbl.textAlignment = .center
        contentView.addSubview(lbl)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class model {
    var name = ""
    var url = ""
    var isSelect = false
}
