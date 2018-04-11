//
//  WatermarkViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 09/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import ImagePicker
class WatermarkViewController: UIViewController {

    let txtWatermark = UITextField()
    let btnChooseImg = UIButton()
    let btnAddWatermark = UIButton()
    let btnAddImageWatermark = UIButton()
    let imgWatermark = UIImageView()
    var strWatermark = "此处设置水印"
    let imagePickerController = ImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        btnChooseImg.title(title: "添加图片").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(20)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(25)
        }
        
        btnChooseImg.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        btnAddWatermark.title(title: "添加水印").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(btnChooseImg.snp.right).offset(30)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(25)
        }
        btnAddWatermark.addTarget(self, action: #selector(addWatermark), for: .touchUpInside)

        
        btnAddImageWatermark.title(title: "添加水印").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(btnAddWatermark.snp.right).offset(30)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(25)
        }
        btnAddImageWatermark.addTarget(self, action: #selector(addImageWatermark), for: .touchUpInside)

        
        imgWatermark.contentMode = .scaleAspectFit
        imgWatermark.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(-10)
            m.top.equalTo(btnChooseImg.snp.bottom).offset(20)
            m.height.equalTo(imgWatermark.snp.width).multipliedBy(0.65)
        }
        
        txtWatermark.bgColor(color: UIColor.lightGray).plaHolder(txt: "此处设置水印").addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(-10)
            m.top.equalTo(imgWatermark.snp.bottom).offset(20)
            m.height.equalTo(25)
        }
    }

    @objc func addImage()  {
         present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func addWatermark()  {
        if let img = imgWatermark.image{
            let newImage = img.addWatermark(text: strWatermark, point: CGPoint(x: 100, y: 100))
            imgWatermark.image = newImage
        }
    }
    
    @objc func addImageWatermark()  {
        if let img = imgWatermark.image{
            
            let newImage = img.addWatermark(maskImage: #imageLiteral(resourceName: "img_watermark"))
            imgWatermark.image = newImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension WatermarkViewController:ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        if let one = images.first{
            imgWatermark.image = one
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
}
