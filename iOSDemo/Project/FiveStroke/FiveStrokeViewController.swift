//
//  FiveStrokeViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/8.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit
import Gifu
class FiveStrokeViewController: UIViewController,UITextFieldDelegate {

    let txtSearch = UITextField()
    let btnSearch = UIButton()
    let tb = UITableView()
    var arrFiveStrokes:[FiveStroke]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arrFiveStrokes = FiveStroke.FiveStrokeLog.Value!
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear for five stroke")
        FiveStroke.FiveStrokeLog.Value! = arrFiveStrokes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        navigationItem.title = "五笔反查"
        
        let btnClearLog = UIButton(type: .custom)
        btnClearLog.setImage(UIImage(named: "btn_video_delete_confirm"), for: .normal)
        btnClearLog.frame = CGRect(x: 0, y: 0, w: 34, h: 34)
        btnClearLog.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btnClearLog.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnClearLog.addTarget(self, action: #selector(clearLog), for: .touchUpInside)
       

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnClearLog)
        
        txtSearch.returnKeyType = .search
        txtSearch.delegate = self
        txtSearch.layer.borderWidth = 1
        txtSearch.layer.borderColor = UIColor.blue.cgColor
        txtSearch.placeholder = "输入中文查询，多个文字不用分割"
        txtSearch.addOffsetView(value: 10)
        txtSearch.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.top.equalTo(NavigationBarHeight + 5)
            m.height.equalTo(36)
            m.right.equalTo(-75)
        }
        
        btnSearch.backgroundColor = UIColor.lightGray
        btnSearch.addTarget(self, action: #selector(searchKey), for: .touchUpInside)
        btnSearch.color(color: UIColor.blue).title(title: "查询").addTo(view: view).snp.makeConstraints { (m) in
            m.top.equalTo(txtSearch)
            m.right.equalTo(-5)
            m.height.equalTo(36)
            m.left.equalTo(txtSearch.snp.right).offset(5)
        }
        
        tb.delegate = self
        tb.dataSource = self
        tb.tableFooterView = UIView()
        tb.rowHeight = 50
        tb.register(strokeCell.self, forCellReuseIdentifier: "Five")
        tb.separatorStyle = .none
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(0)
            m.top.equalTo(txtSearch.snp.bottom).offset(5)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchKey()
        return true
    }
    
    @objc func clearLog(){
        UIAlertController.init(title: "清空记录", message: "你要清空搜索记录吗", preferredStyle: .alert).action(title: "取消", handle: nil).action(title: "确定", handle: {(action:UIAlertAction) in
            FiveStroke.FiveStrokeLog.clear()
            self.arrFiveStrokes.removeAll()
            self.tb.reloadData()
        }).show()
    }
    
    @objc func searchKey(){
        txtSearch.resignFirstResponder()
        if txtSearch.text!.isEmpty{
            Toast.showToast(msg: "请输入文字")
            return
        }
        
        if !(txtSearch.text! =~ "[\\u4e00-\\u9fa5]"){
            Toast.showToast(msg: "请输入中文")
            return
        }
        Toast.showLoading()
        FiveStroke.getFiveStroke(key: txtSearch.text!) { (res) in
            if !handleResult(result: res){
                return
            }
            self.arrFiveStrokes.insertItems(array: res.data! as! [FiveStroke], index: 0)
            self.tb.reloadData()
        }
     
        
        FiveStroke.getFive(key: txtSearch.text!) { res in
           
        }
    }
 

}

extension FiveStrokeViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrFiveStrokes == nil{
            return 0
        }
        return arrFiveStrokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tb.dequeueReusableCell(withIdentifier: "Five", for: indexPath) as! strokeCell
        cell.fiveStroke = arrFiveStrokes[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            arrFiveStrokes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            FiveStroke.FiveStrokeLog.Value! = arrFiveStrokes
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}


class strokeCell: UITableViewCell {
    let lblText = UILabel()
    let lblPinyin = UILabel()
    let lblCode = UILabel()
    let imgFive = UIImageView()
    
    var fiveStroke:FiveStroke?{
        didSet{
            guard let f = fiveStroke else {
                return
            }
            lblText.text = f.text
            lblPinyin.text = f.spell
            lblCode.text = f.code
//            let url = URL(string: f.imgDecodeUrl.urlEncoded())!
//            imgFive.animate(withGIFURL: url)
//            imgFive.startAnimating()
            
            imgFive.setImg(url: f.imgDecodeUrl.urlEncoded())
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lblText.color(color: UIColor.gray).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.width.equalTo(30)
            m.centerY.equalTo(contentView)
        }
        
        lblPinyin.color(color: UIColor.gray).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(lblText.snp.right).offset(10)
            m.width.equalTo(50)
            m.centerY.equalTo(contentView)
        }
        lblCode.color(color: UIColor.gray).addTo(view: contentView).snp.makeConstraints { (m) in
            m.left.equalTo(lblPinyin.snp.right).offset(10)
            m.width.equalTo(50)
            m.centerY.equalTo(contentView)
        }
        imgFive.clipsToBounds = true
        imgFive.contentMode = .scaleAspectFit
        imgFive.addTo(view: contentView).snp.makeConstraints { (m) in
            m.right.equalTo(-5)
            m.centerY.equalTo(contentView)
            m.height.equalTo(34)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
