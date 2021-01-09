//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/9.
//

import UIKit
import ZLPhotoBrowser
import CommonLibrary
import SwiftUI
class CompressImageViewController: UIViewController {

    let imgOrigin = UIImageView()
    let btnChoose = UIButton()
    let imgCompress = UIImageView()
    let btnCompress = UIButton()
    let lblOriginSize = UILabel()
    let lblCompressSize = UILabel()
    var imagePickerController:ZLPhotoPreviewSheet!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        imgOrigin.contentMode = .scaleAspectFit
        imgOrigin.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(NavigationBarHeight + 10)
            m.width.equalTo(ScreenWidth - 120)
            m.height.equalTo(160)
        }
        
        lblOriginSize.color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(imgOrigin)
            m.top.equalTo(imgOrigin.snp.bottom).offset(10)
            m.height.equalTo(15)
        }
        
        btnChoose.title(title: "选择图片").color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(imgOrigin.snp.right).offset(10)
            m.right.equalTo(-10)
            m.centerY.equalTo(imgOrigin)
        }
        btnChoose.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        
        imgCompress.contentMode = .scaleAspectFit
        imgCompress.addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.top.equalTo(lblOriginSize.snp.bottom).offset(10)
            m.width.equalTo(ScreenWidth - 120)
            m.height.equalTo(160)
        }
        
        lblCompressSize.color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.centerX.equalTo(imgCompress)
            m.top.equalTo(imgCompress.snp.bottom).offset(10)
            m.height.equalTo(15)
        }
        
        btnCompress.title(title: "压缩图片").color(color: UIColor.gray).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(imgOrigin.snp.right).offset(10)
            m.right.equalTo(-10)
            
            m.centerY.equalTo(imgCompress)
        }
        btnCompress.addTarget(self, action: #selector(compressImage), for: .touchUpInside)
        

        imagePickerController = ZLPhotoPreviewSheet()
        imagePickerController.selectImageBlock = {[weak self] (images, assets, isOriginal) in
            if let one = images.first{
                self?.imgOrigin.image = one
                //事实上对于iOS来说，获取图片文件大小是无法获取到真正的大小的，因为iOS不会让你直接获取文件，而是先读取出来再解压缩后生成Data数据，这个data数据和原先的文件没有任何关系了，所以只能设置一个文件大小上限
                self?.lblOriginSize.text = one.getFileSize().1
            }
        }
    }

    
    @objc func chooseImage() {
        imagePickerController.showPhotoLibrary(sender: self)
    }
    
    @objc func compressImage(){
        if let img = imgOrigin.image{
            if let d = img.compressWithMaxLength(maxLength: 100000){
                let i = UIImage(data: d)!
                imgCompress.image = i
                lblCompressSize.text = "\((d as NSData).length) b"
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
struct CompressImageDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    typealias UIViewControllerType = CompressImageViewController
    
    func makeUIViewController(context: Context) -> CompressImageViewController {
        return CompressImageViewController()
    }
}
