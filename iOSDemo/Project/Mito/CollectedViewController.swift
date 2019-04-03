//
//  CollectedViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/3.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class CollectedViewController: UIViewController {

    let arrImages = MitoConfig.CollectedMito.Value!
     var vCol: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = FlowLayout(columnCount: 2, columnMargin: 8) { [weak self] (index) -> Double in
            return Double(self!.arrImages[index.row].cellHeight)
        }
        
        vCol = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        vCol.backgroundColor = UIColor.white
        vCol.delegate = self
        vCol.dataSource = self
        vCol.register(ImageSetCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(vCol)
        
    }
    

}

extension CollectedViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageSetCell
        cell.imgSet = arrImages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = arrImages[indexPath.row]
        let vc = ImageSetListViewController()
        vc.imageSet = item
        navigationController?.pushViewController(vc, animated: true)
    }
}
