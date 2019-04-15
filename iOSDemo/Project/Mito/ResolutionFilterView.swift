//
//  ResolutionFilterView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/15.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class ResolutionFilterView: UIView {

    let vMain = UIView()
    let tbResolution = UITableView()
    var arrFilters = [Resolution]()
    var selectBlock:((_ res:Resolution)->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = 111
        backgroundColor = UIColor(gray: 0.5, alpha: 0.5)
        
        vMain.bgColor(color: UIColor.white).addTo(view: self).snp.makeConstraints { (m) in
            m.center.equalTo(self)
            m.width.equalTo(300)
            m.height.equalTo(600)
        }
        
        let lblTitle = UILabel().text(text: "选择分辨率").color(color: UIColor.darkGray).addTo(view: vMain)
        lblTitle.snp.makeConstraints { (m) in
            m.centerX.equalTo(vMain)
            m.top.equalTo(10)
        }
        
        tbResolution.separatorStyle = .none
        tbResolution.rowHeight = 30
        tbResolution.tableFooterView = UIView()
        tbResolution.dataSource = self
        tbResolution.delegate = self
        tbResolution.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tbResolution.addTo(view: vMain).snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.top.equalTo(lblTitle.snp.bottom).offset(5)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToRemove(ges:)))
        self.isUserInteractionEnabled = true
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    @objc func tapToRemove(ges:UIGestureRecognizer)  {
        removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ResolutionFilterView:UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrFilters[indexPath.row].toString()
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectBlock?(arrFilters[indexPath.row])
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.tag == 111{
            return true
        }
        return false
    }
}


