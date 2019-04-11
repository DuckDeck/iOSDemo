//
//  DownloadProgressView.swift
//  iOSDemo
//
//  Created by Stan Hu on 2019/4/11.
//  Copyright © 2019 Stan Hu. All rights reserved.
//

import UIKit

class DownloadProgressView: UIView {
    let config = URLSessionConfiguration.background(withIdentifier: "download_video")
    var session : URLSession!
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
        lblPercent.text = "准备下载"
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
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

    
    
    deinit {
        print("DownloadProgressView deinit")
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
        session.finishTasksAndInvalidate()
        let tmp = NSTemporaryDirectory()
        let file = URL(fileURLWithPath: tmp).appendingPathComponent(downloadTask.response!.suggestedFilename!)
        do{
            try FileManager.default.moveItem(at: location, to: file)
        }
        catch{
            print(error.localizedDescription)
            return
        }
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(file.path){
            UISaveVideoAtPathToSavedPhotosAlbum(file.path, self, nil, nil)
            //try? FileManager.default.removeItem(at: file)
            //Issue，当保存，不能马上调用这行代码删除文件，不然就会促成 到相册失败
        }
        
        //Issue点，获取到location只能在当前线程操作，如果用DispatchQueue.main在主纯种里操作，那么当前纯种已经把文件删除了导致失败
        DispatchQueue.main.async {
            _ = delay(time: 0.5) {
                Toast.showToast(msg:"成功保存到相册")
                self.removeFromSuperview()
            }
            //这里下载后会自动删除，需要自己动手弄出去
        }
       
    }
    
}
