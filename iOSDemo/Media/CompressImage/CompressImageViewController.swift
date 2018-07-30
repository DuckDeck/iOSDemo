//
//  CompressImageViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/7/30.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import ImagePicker
class CompressImageViewController: UIViewController {

    let imgOrigin = UIImageView()
    let btnChoose = UIButton()
    let imgCompress = UIImageView()
    let btnCompress = UIButton()
    let lblOriginSize = UILabel()
    let lblCompressSize = UILabel()
    let imagePickerController = ImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        imgOrigin.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(NavigationBarHeight + 10)
            m.width.equalTo(ScreenWidth - 70)
            m.height.equalTo(200)
        }
        
        lblOriginSize.color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(imgOrigin)
            m.top.equalTo(imgOrigin.snp.bottom).offset(10)
        }
        
        btnChoose.title(title: "选择图片").addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(imgOrigin.snp.right).offset(10)
            m.right.equalTo(-10)
            m.centerY.equalTo(imgOrigin)
        }
        btnChoose.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        
        imgCompress.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(lblOriginSize.snp.bottom).offset(10)
            m.width.equalTo(ScreenWidth - 70)
            m.height.equalTo(200)
        }
        
        lblCompressSize.color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(imgOrigin)
            m.top.equalTo(imgCompress.snp.bottom).offset(10)
        }
        
        btnCompress.title(title: "选择图片").addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(imgOrigin.snp.right).offset(10)
            m.right.equalTo(-10)
            m.centerY.equalTo(imgOrigin)
        }
        btnChoose.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        
        
        
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
    }

    
    @objc func chooseImage() {
         present(imagePickerController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
extension  CompressImageViewController:ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        if let one = images.first{
            imgOrigin.image = one
            lblOriginSize.text = "\((UIImageJPEGRepresentation(one, 1) as! NSData).length) kb"
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}

