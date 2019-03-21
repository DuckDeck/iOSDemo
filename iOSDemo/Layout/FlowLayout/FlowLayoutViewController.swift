//
//  FlowLayoutViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/3/21.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class FlowLayoutViewController: UIViewController {

    var vCol:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = FlowLayout(columnCount: 3, columnMargin: 8) { (index) -> Double in
            let i = Double(arc4random() % 100 )
            if i < 20{
                return i + 20
            }
            return i
        }

        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(vCol)
    }
    

   
}

extension FlowLayoutViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.random
        return cell
    }
    
    
}
