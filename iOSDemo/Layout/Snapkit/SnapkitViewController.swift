//
//  SnapkitViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 19/01/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
class SnapkitViewController: UIViewController,UITextViewDelegate {

    let lbl = UILabel()
    let lbl1 = UILabel()
    let lbl2 = UILabel()
    let lbl3 = UILabel()
    let sc = UIScrollView()
    var isHidden = false
    var updateConstraint:Constraint?
    let txt = UITextView()
    var str = "购买建议：梅花扳手使用频率很多。"
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "试验Snapkit"
        view.backgroundColor = UIColor.white
        lbl.numberOfLines  = 1
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.text = str
        view.addSubview(lbl)
        lbl.snp.makeConstraints {
            $0.left.equalTo(10)
            $0.height.equalTo(15)
            $0.top.equalTo(77)
        }
        
        view.addSubview(lbl1)
        lbl1.text = "那时候，我炒白银亏了十几万元，没有闲钱，阿顺也一样，于是我俩就透支信用卡额度去投资。每月还款日一过，就把钱充到钱宝网里，临近还款日再提现出来，还信用卡。"
        lbl1.numberOfLines = 0
        lbl1.layer.borderWidth = 1
        lbl1.snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(-10)
            m.top.equalTo(lbl.snp.bottom).offset(20)
        }
        
        automaticallyAdjustsScrollViewInsets = false
//        view.addSubview(sc)
//
//        sc.snp.makeConstraints { (m) in
//            m.left.right.equalTo(0)
//            m.top.equalTo(lbl1.snp.bottom)
//            m.bottom.equalTo(-15)
//        }
//
        let viewContainer = UIView()
        viewContainer.backgroundColor = UIColor.green
//        sc.addSubview(viewContainer)
//        viewContainer.snp.makeConstraints { (m) in
//            m.top.bottom.equalTo(sc)
//            m.left.right.equalTo(view)
//            m.height.greaterThanOrEqualTo(sc).offset(1)
//        }
        
        
        lbl2.text = "那时候，我炒白银亏了十几万元，没有闲钱，阿顺也一样，于是我俩就透支信用卡额度去投资。每月还款日一过，就把钱充到钱宝网里，临近还款日再提现出来，还信用卡。"
        lbl2.numberOfLines = 0
        lbl2.layer.borderWidth = 1
        lbl2.font = UIFont.systemFont(ofSize: 18)
        viewContainer.addSubview(lbl2)
        lbl2.snp.makeConstraints { (m) in
            m.left.right.equalTo(viewContainer).inset(15)
            m.top.equalTo(10)
            m.height.lessThanOrEqualTo(1000)
            //self.updateConstraint = m.height.lessThanOrEqualTo(1000).priority(1000).constraint
        }
        
        lbl3.text = "那时候，我炒白银亏了十几万元，没有闲钱，阿顺也一样，于是我俩就透支信用卡额度去投资。每月还款日一过，就把钱充到钱宝网里，临近还款日再提现出来，还信用卡。"
        lbl3.numberOfLines = 0
        lbl3.layer.borderWidth = 1
        lbl3.font = UIFont.systemFont(ofSize: 18)
        viewContainer.addSubview(lbl3)
        lbl3.snp.makeConstraints { (m) in
            m.left.right.equalTo(viewContainer).inset(15)
            m.top.equalTo(lbl2.snp.bottom).offset(20)
            m.bottom.lessThanOrEqualTo(viewContainer).offset(-10)
        }
        
        
        let btn = UIButton().title(title: "Add").color(color: UIColor.red).setTarget(self, action: #selector(addText)).addTo(view: view)
        btn.snp.makeConstraints { (m) in
            m.left.equalTo(lbl.snp.right).offset(5)
            m.top.equalTo(lbl)
            m.height.equalTo(20)
        }
        
        txt.layer.borderWidth = 1
        txt.delegate = self
        view.addSubview(txt)
        txt.snp.makeConstraints { (m) in
                m.left.equalTo(10)
                m.right.equalTo(-10)
                m.top.equalTo(lbl1.snp.bottom)
                m.height.greaterThanOrEqualTo(30)
        }
        
        let barBtn = UIBarButtonItem(title: "hide", style: .plain, target: self, action: #selector(hide))
        let barBtn2 = UIBarButtonItem(title: "Table", style: .plain, target: self, action: #selector(toTable))
        navigationItem.rightBarButtonItems = [barBtn,barBtn2]
        // Do any additional setup after loading the view.
    }

    @objc func addText()  {
        lbl.text = str + "123"
        lbl.font = UIFont.boldSystemFont(ofSize: 13)
        lbl1.text = lbl1.text! + "阿顺也一样，于是我俩就透支信用卡额度去投资。每月还款日一过，就把钱充到钱宝网里，临近还款日"
        lbl3.text = lbl3.text! + "阿顺也一样，于是我俩就透支信用卡额度去投资。每月还款日一过，就把钱充到钱宝网里，临近还款日"
    }
  
    
    
    @objc func hide()  {
        if isHidden{

            UIView.animate(withDuration: 1, animations: {
                self.lbl2.snp.updateConstraints { (m) in
                    m.height.lessThanOrEqualTo(1000)
                }
                self.view.layoutIfNeeded()
            })
            // 使用这种方法可以复原
//            UIView.animate(withDuration: 1, animations: {
//                self.updateConstraint?.update(inset: 1000)
//                self.view.layoutIfNeeded()
//            })
            // 使用这种方法不能复原
            isHidden = false
            //updateViewConstraints()
        }
        else{
            UIView.animate(withDuration: 1, animations: {
                self.lbl2.snp.updateConstraints { (m) in
                    m.height.lessThanOrEqualTo(0)
                }
                self.view.layoutIfNeeded()
            })
            isHidden = true
            
//            UIView.animate(withDuration: 1, animations: {
//               self.updateConstraint?.update(inset: 0)
//                self.view.layoutIfNeeded()
//            })
//            isHidden = true
        }
       
    }
    
    @objc func toTable()  {
        navigationController?.pushViewController(SnapkitTableViewController(), animated: true)
    }
    
}
