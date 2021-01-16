//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/12.
//

import UIKit
import ZLPhotoBrowser
import CommonLibrary
import SwiftUI
class WatermarkViewController: UIViewController {

    let txtWatermark = UITextField()
    let btnAddImage = UIButton()
    let btnAddWatermark = UIButton()
    let btnAddImageWatermark = UIButton()
    let imgWatermark = UIImageView()
    var strWatermark = "此处设置水印"
    var imagePickerController:ZLPhotoPreviewSheet!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    
        imagePickerController = ZLPhotoPreviewSheet()
        imagePickerController.selectImageBlock = {[weak self] (images, assets, isOriginal) in
            if let one = images.first{
                self?.imgWatermark.image = one
            }
        }

        btnAddImage.title(title: "选择图片").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth / 4)
            m.top.equalTo(30)
            m.width.equalTo(100)
            m.height.equalTo(25)
        }
        btnAddImage.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        btnAddWatermark.title(title: "添加水印").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(ScreenWidth / 4)
            m.top.equalTo(100)
            m.width.equalTo(100)
            m.height.equalTo(25)
        }
        btnAddWatermark.addTarget(self, action: #selector(addWatermark), for: .touchUpInside)

        
        btnAddImageWatermark.title(title: "添加图片水印").color(color: UIColor.red).bgColor(color: UIColor.lightGray).addTo(view: view).snp.makeConstraints { (m) in
           m.centerX.equalTo(ScreenWidth * 0.75)
            m.top.equalTo(100)
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
        
        txtWatermark.layer.borderWidth = 1
        txtWatermark.addTarget(self, action: #selector(txtChange), for: UIControl.Event.editingChanged)
        txtWatermark.color(color: UIColor.green).plaHolder(txt: "此处设置水印").addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(-10)
            m.top.equalTo(imgWatermark.snp.bottom).offset(20)
            m.height.equalTo(25)
        }
    }

    
    @objc func addImage() {
        imagePickerController.showPhotoLibrary(sender: self)
        //这里点donw无法返回是因为用了swiftUI，没有适配的话就会这样
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
            let newImage = img.addWatermark(maskImage:#imageLiteral(resourceName: "img_watermark_b"),scale:3)
            imgWatermark.image = newImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

struct AddWatermarkDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = WatermarkViewController
    
    func makeUIViewController(context: Context) -> WatermarkViewController {
        return WatermarkViewController()
    }
}

