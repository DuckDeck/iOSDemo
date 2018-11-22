//
//  WatermarkViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 09/04/2018.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit
import TZImagePickerController
class WatermarkViewController: UIViewController,TZImagePickerControllerDelegate {

    let txtWatermark = UITextField()
    let btnAddWatermark = UIButton()
    let btnAddImageWatermark = UIButton()
    let imgWatermark = UIImageView()
    var strWatermark = "此处设置水印"
    var imagePickerController:TZImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
       
        imagePickerController = TZImagePickerController(maxImagesCount: 3, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            if let one = images?.first{
                self?.imgWatermark.image = one
            }
        }
        

        
     
        
        btnAddWatermark.title(title: "添加水印").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth / 4)
            m.top.equalTo(80)
            m.width.equalTo(100)
            m.height.equalTo(25)
        }
        btnAddWatermark.addTarget(self, action: #selector(addWatermark), for: .touchUpInside)

        
        btnAddImageWatermark.title(title: "添加图片水印").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
           m.centerX.equalTo(ScreenWidth * 0.75)
            m.top.equalTo(80)
            m.width.equalTo(120)
            m.height.equalTo(25)
        }
        btnAddImageWatermark.addTarget(self, action: #selector(addImageWatermark), for: .touchUpInside)

        
        imgWatermark.contentMode = .scaleAspectFit
        imgWatermark.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(-10)
            m.top.equalTo(btnAddWatermark.snp.bottom).offset(15)
            m.height.equalTo(imgWatermark.snp.width).multipliedBy(1.2)
        }
        imgWatermark.image = UIImage(named: "7")
        txtWatermark.addTarget(self, action: #selector(txtChange), for: UIControl.Event.editingChanged)
        txtWatermark.color(color: UIColor.green).plaHolder(txt: "此处设置水印").addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(-10)
            m.top.equalTo(imgWatermark.snp.bottom).offset(20)
            m.height.equalTo(25)
        }
    }

    
    @objc func txtChange() {
        strWatermark = txtWatermark.text ?? "此处设置水印"
    }
    
    @objc func addWatermark()  {
        if let img = imgWatermark.image{
            let newImage = img.addWatermark(text: strWatermark, point: CGPoint(x: 100, y: 100))
            imgWatermark.image = newImage
        }
    }
    
    @objc func addImageWatermark()  {
        if let img = imgWatermark.image{
            let newImage = img.addWatermark(maskImage:#imageLiteral(resourceName: "img_watermark_b"),scale:1)
            imgWatermark.image = newImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

