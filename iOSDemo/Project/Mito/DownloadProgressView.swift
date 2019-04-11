//
//  DownloadProgressView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/11.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class DownloadProgressView: UIView {
 
    let lblPercent = UILabel()
    
    var downloadUrl :String?
    
    
    var maxValue:Double = 1
    var minValue:Double = 0
    
    var value:Double = 0{
        didSet{
           
            setNeedsDisplay()
            
        }
    }
    
    var bgTintColor = UIColor.lightGray{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        lblPercent.text = "开始下载"
        lblPercent.color(color: bgTintColor).setFont(font: 13).addTo(view: self).snp.makeConstraints { (m) in
            m.center.equalTo(self)
        }
    }
    
    var lineWidth:CGFloat = 2{
        didSet{
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startDownloadWithUrl(url:String)  {
        downloadUrl = url
        let config = URLSessionConfiguration.background(withIdentifier: "download_video")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        let task = session.downloadTask(with: URLRequest(url: URL(string: downloadUrl!)!))
        task.resume()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        let newRect = CGRect(x: rect.origin.x + lineWidth, y: rect.origin.y + lineWidth, w: rect.size.width - lineWidth * 2, h: rect.size.width - lineWidth * 2)
        context.setStrokeColor(bgTintColor.cgColor)
        context.setLineWidth(lineWidth)
        context.strokeEllipse(in: newRect)
        context.addArc(center: CGPoint(x: rect.size.width / 2, y: rect.size.height / 2), radius: newRect.size.width / 2, startAngle: -CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi * 2 * value / (maxValue - minValue)) - CGFloat(Double.pi / 2), clockwise: false)
        context.setStrokeColor(tintColor.cgColor)
        context.strokePath()
        //绘制圆
        
        context.setFillColor(UIColor.init(gray: 0.5, alpha: 0.5).cgColor)
        context.fillEllipse(in: newRect)
        //绘制里面的填充部分
    }

}

extension DownloadProgressView:URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(progress)
        DispatchQueue.main.async {
            self.value = Double(progress)
            self.lblPercent.text = "\(Int(progress * 100))%"
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.lblPercent.text = "下载完成"
        }
        _ = delay(time: 0.5) {
            DispatchQueue.main.async {
                self.removeFromSuperview()
            }
        }
        //这里下载后会自动删除，需要自己动手弄出去
        let tmp = NSTemporaryDirectory()
        let file = URL(fileURLWithPath: tmp).appendingPathComponent(downloadTask.response!.suggestedFilename!)
        do{
            try FileManager.default.moveItem(at: location, to: file)
            
        }
        catch{
            Toast.showToast(msg: error.localizedDescription)
            return
        }
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file.path){
            UISaveVideoAtPathToSavedPhotosAlbum(file.path, self, nil, nil)
            try? FileManager.default.removeItem(at: file)
            DispatchQueue.main.async {
                Toast.showToast(msg:"成功保存到相册")
            }
        }
    }
    

}
