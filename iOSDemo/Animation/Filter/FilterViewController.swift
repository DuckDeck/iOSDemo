//
//  FilterViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 27/12/2017.
//  Copyright © 2017 Stan Hu. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var slider1:UISlider?
    var slider2:UISlider?
    var slider3:UISlider?
    var slider4:UISlider?
    var btnReset:UIButton?
    var btnChoosePhoto:UIButton?
    var btnSave:UIButton?
    var img:UIImageView?
    
    var imgPicker:UIImagePickerController?
    var ctx:CIContext?
    var imgBegin:CIImage?
    var imgResult:UIImage?
    var filter1:CIFilter?
    var filter2:CIFilter?
    var filter3:CIFilter?
    var filter4:CIFilter?
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        self.navigationItem.title = "使用CoreImage"
        img = UIImageView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 250))
        view.addSubview(img!);
        slider1 = UISlider(frame: CGRect(x: 0, y: 305, width: UIScreen.main.bounds.width, height: 30))
        slider1?.addTarget(self, action: #selector(sliderChange1(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(slider1!)
        slider2 = UISlider(frame: CGRect(x: 0, y: 335, width: UIScreen.main.bounds.width, height: 30))
        slider2?.addTarget(self, action: #selector(sliderChange2(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(slider2!)
        slider3 = UISlider(frame: CGRect(x: 0, y: 365, width: UIScreen.main.bounds.width, height: 30))
        slider3?.addTarget(self, action: #selector(sliderChange3(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(slider3!)
        slider4 = UISlider(frame: CGRect(x: 0, y: 395, width: UIScreen.main.bounds.width, height: 30))
        slider4?.addTarget(self, action: #selector(sliderChange4(sender:)), for: UIControl.Event.valueChanged)
        view.addSubview(slider4!)
        btnReset = UIButton(frame: CGRect(x: 0, y: 430, width: 100, height: 30))
        btnReset?.setTitle("重设", for: UIControl.State.normal)
        btnReset?.addTarget(self, action: #selector(reset(sender:)), for: UIControl.Event.touchUpInside)
        btnReset?.setTitleColor(UIColor.black, for: UIControl.State.normal)
        view.addSubview(btnReset!)
        btnChoosePhoto = UIButton(frame: CGRect(x: 106, y: 430, width: 100, height: 30))
        btnChoosePhoto?.setTitle("照片", for: UIControl.State.normal)
        btnChoosePhoto?.addTarget(self, action: #selector(load(sender:)), for: UIControl.Event.touchUpInside)
        btnChoosePhoto?.setTitleColor(UIColor.black, for: UIControl.State.normal)
        view.addSubview(btnChoosePhoto!)
        btnSave = UIButton(frame: CGRect(x: 212, y: 430, width: 100, height: 30))
        btnSave?.setTitle("保存", for: UIControl.State.normal)
        btnSave?.addTarget(self, action: #selector(save(sender:)), for: UIControl.Event.touchUpInside)
        btnSave?.setTitleColor(UIColor.black, for: UIControl.State.normal)
        view.addSubview(btnSave!)
        
        
        imgPicker = UIImagePickerController()
        imgPicker?.delegate = self
        
        slider1?.minimumValue = 0
        slider1?.maximumValue = 10
        slider2?.minimumValue = -4
        slider2?.maximumValue = 4
        slider3?.minimumValue = -2 * Float(Double.pi)
        slider3?.maximumValue = 2 * Float(Double.pi)
        slider4?.minimumValue = 0
        slider4?.maximumValue = 30
        reset(sender: btnReset!)
        loadAllFilters()
        ctx = CIContext()
        let eaglCtx = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        ctx = CIContext(eaglContext: eaglCtx!)
        filter1 = CIFilter(name: "CIGaussianBlur")
        filter2 = CIFilter(name: "CIBumpDistortion")
        filter3 = CIFilter(name: "CIHueAdjust")
        filter4 = CIFilter(name: "CIPixellate")
    }

    @objc func reset(sender:UIButton){
        slider1?.value = 0
        slider2?.value = 0
        slider3?.value = 0
        slider4?.value = 0
        // var path = NSBundle.mainBundle().pathForResource("cIImageDemo", ofType: "jpg")
        // var url = NSURL(fileURLWithPath: path!)
        let image = UIImage(named: "2")
        img?.image = image
        imgBegin = CIImage(cgImage: image!.cgImage!)
    }
    func loadAllFilters(){
        let allFIlters = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        print("所有内建过渡器\(allFIlters)")
        for  s  in allFIlters {
            let filter = CIFilter(name: s)
            print("===\(s)===\(filter!.attributes)")
        }
    }
    @objc func sliderChange1(sender:UISlider){
        slider2?.value = 0
        slider3?.value = 0
        slider4?.value = 0
        let sliderValue = sender.value
        filter1?.setValue(imgBegin, forKey: "inputImage")
        filter1?.setValue(sliderValue, forKey: "inputRadius")
        let imgOut = filter1?.outputImage
        let temp = ctx?.createCGImage(imgOut!, from: imgOut!.extent)
        imgResult = UIImage(cgImage: temp!)
        img?.image = imgResult
    }
    @objc func sliderChange2(sender:UISlider){
        slider1?.value = 0
        slider3?.value = 0
        slider4?.value = 0
        let sliderValue = sender.value
        filter2?.setValue(imgBegin, forKey: "inputImage")
        filter2?.setValue(CIVector(x: 150, y: 240), forKey: "inputCenter")
        filter2?.setValue(150, forKey: "inputRadius")
        filter2?.setValue(sliderValue, forKey: "inputScale")
        let imgOut = filter2?.outputImage
        let temp = ctx?.createCGImage(imgOut!, from: imgOut!.extent)
        imgResult = UIImage(cgImage: temp!)
        img?.image = imgResult
        
    }
    @objc func sliderChange3(sender:UISlider){
        slider1?.value = 0
        slider2?.value = 0
        slider4?.value = 0
        let sliderValue = sender.value
        filter3?.setValue(imgBegin, forKey: "inputImage")
        filter3?.setValue(sliderValue, forKey: "inputAngle")
        let imgOut = filter3?.outputImage
        let temp = ctx?.createCGImage(imgOut!, from: imgOut!.extent)
        imgResult = UIImage(cgImage: temp!)
        img?.image = imgResult
    }
    @objc func sliderChange4(sender:UISlider){
        slider1?.value = 0
        slider2?.value = 0
        slider3?.value = 0
        let sliderValue = sender.value
        filter4?.setValue(imgBegin, forKey: "inputImage")
        filter4?.setValue(CIVector(x: 150, y: 240), forKey: "inputCenter")
        filter4?.setValue(sliderValue, forKey: "inputScale")
        let imgOut = filter4?.outputImage
        let temp = ctx?.createCGImage(imgOut!, from: imgOut!.extent)
        imgResult = UIImage(cgImage: temp!)
        img?.image = imgResult
    }
    @objc func load(sender:UIButton){
        self.present(imgPicker!, animated: true, completion: nil)
    }
    @objc func save(sender:UIButton){
        UIImageWriteToSavedPhotosAlbum(imgResult!, nil, nil, nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let imgSeleted = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            imgBegin = CIImage(cgImage: imgSeleted.cgImage!)
            img?.image = imgSeleted
        }
    }
    
   

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
 
}
