//
//  ImageRecognitionViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2017/9/24.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit
import TangramKit
import ImagePicker
import CoreML
import Vision
@available(iOS 11.0, *)
class ImageRecognitionViewController: UIViewController {
    
    let vMain =  TGLinearLayout(TGOrientation.vert)
    let img = UIImageView()
    let btnChooseImage = UIButton()
    let btnStart  = UIButton()
    let lblResult = UILabel()
    let lblProbably = UILabel()
    let imagePickerController = ImagePickerController()
    override func loadView() {
        self.view = UIScrollView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.white
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        vMain.tg_width.equal(.fill)
        vMain.tg_height.equal(.wrap)
        self.view.addSubview(vMain)
        img.tg_width.equal(.fill)
        img.tg_height.min(300)
        img.tg_height.equal(.wrap)
        vMain.addSubview(img)
        
        btnChooseImage.setTarget(self, action: #selector(ImageRecognitionViewController.chooseImage)).title(title: "Choose Image").color(color: UIColor.red).bgColor(color: UIColor.blue).addTo(view: vMain).completed()
        btnChooseImage.tg_top.equal(10)
        btnChooseImage.tg_width.equal(.fill)
        btnChooseImage.tg_height.equal(36)
        
        btnStart.title(title: "Start Check").setTarget(self, action: #selector(ImageRecognitionViewController.startCheck)).color(color: UIColor.red).bgColor(color: UIColor.blue).addTo(view: vMain).completed()
        btnStart.tg_top.equal(10)
        btnStart.tg_width.equal(.fill)
        btnStart.tg_height.equal(36)
        
        
        lblResult.color(color: UIColor.red).txtAlignment(ali: .center).bgColor(color: UIColor.blue).addTo(view: vMain).completed()
        lblResult.tg_top.equal(10)
        lblResult.tg_width.equal(.fill)
        lblResult.tg_height.equal(36)
        
        lblProbably.color(color: UIColor.red).txtAlignment(ali: .center).bgColor(color: UIColor.blue).addTo(view: vMain).completed()
        lblProbably.tg_top.equal(10)
        lblProbably.tg_width.equal(.fill)
        lblProbably.tg_height.equal(36)
    }
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
