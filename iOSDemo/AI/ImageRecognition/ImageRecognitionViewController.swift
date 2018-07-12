//
//  ImageRecognitionViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import SnapKit
import ImagePicker
import CoreML
import Vision
@available(iOS 11.0, *)
class ImageRecognitionViewController: UIViewController {
    
    let img = UIImageView()
    let btnChooseImage = UIButton()
    let btnStart  = UIButton()
    let lblResult = UILabel()
    let lblProbably = UILabel()
    var imagePickerController:ImagePickerController!
  
    
    
    
    
    @objc func chooseImage()  {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func startCheck(){
        if img.image == nil {
            GrandCue.toast("you do not choose image")
            return
        }
        
        let resnetModel = Resnet50()
        let image = img.image!
       let vnCoreModel = try? VNCoreMLModel(for: resnetModel.model)
        if vnCoreModel == nil {
            return
        }
        let vnCoreMlRequest = VNCoreMLRequest(model: vnCoreModel!) { (request, err) in
            var confidence:Float = 0.0
            var tempClassification:VNClassificationObservation? = nil
            for classification in request.results!{
                let c = classification as! VNClassificationObservation
                if c.confidence > confidence{
                    confidence = c.confidence
                    tempClassification = c
                }
            }
           self.lblResult.text = tempClassification?.identifier
            self.lblProbably.text = "probability \(tempClassification?.confidence ?? 0)"
        }
        let vnImageRequestHandle = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        try?  vnImageRequestHandle.perform([vnCoreMlRequest])
    }
    
    override func loadView() {
        super.loadView()
        self.view = UIScrollView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = UIColor.white
       
        
        var configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.allowMultiplePhotoSelection = true
        imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
       
      
        view.addSubview(img)
        img.snp.makeConstraints { (m) in
            m.width.equalTo(view)
            m.left.top.equalTo(0)
            m.height.greaterThanOrEqualTo(300)
        }
        
        
        
        btnChooseImage.setTarget(self, action: #selector(ImageRecognitionViewController.chooseImage)).title(title: "Choose Image").color(color: UIColor.red).bgColor(color: UIColor.blue).addTo(view: view).completed()
        btnChooseImage.snp.makeConstraints { (m) in
            m.top.equalTo(img.snp.bottom).offset(10)
            m.width.equalTo(ScreenWidth - 100)
            m.height.equalTo(36)
            m.centerX.equalTo(view)
        }
        
        btnStart.title(title: "Start Check").setTarget(self, action: #selector(ImageRecognitionViewController.startCheck)).color(color: UIColor.red).bgColor(color: UIColor.blue).addTo(view: view).completed()
     
        btnStart.snp.makeConstraints { (m) in
            m.top.equalTo(btnChooseImage.snp.bottom).offset(10)
            m.width.equalTo(ScreenWidth - 100)
            m.height.equalTo(36)
            m.centerX.equalTo(view)
        }
        
        
        lblResult.color(color: UIColor.red).txtAlignment(ali: .center).bgColor(color: UIColor.blue).addTo(view: view).completed()
      
        lblResult.snp.makeConstraints { (m) in
            m.top.equalTo(btnStart.snp.bottom).offset(10)
            m.width.equalTo(ScreenWidth - 100)
            m.height.equalTo(36)
            m.centerX.equalTo(view)
        }
        
        
        lblProbably.color(color: UIColor.red).txtAlignment(ali: .center).bgColor(color: UIColor.blue).addTo(view: view).completed()
       
        
        lblProbably.snp.makeConstraints { (m) in
            m.top.equalTo(lblResult.snp.bottom).offset(10)
            m.width.equalTo(ScreenWidth - 100)
            m.height.equalTo(36)
            m.centerX.equalTo(view)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

@available(iOS 11.0, *)
extension ImageRecognitionViewController:ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        if let one = images.first{
            img.image = one
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    
}
