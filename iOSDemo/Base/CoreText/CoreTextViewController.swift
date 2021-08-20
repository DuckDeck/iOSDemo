//
//  CoreTextViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2021/8/17.
//  Copyright © 2021 Stan Hu. All rights reserved.
//

import Foundation
import CoreText
class CoreTextViewController: BaseViewController {
    var height : CGFloat = 0
    let v = txtView(frame: CGRect(x: 10, y: 0, width: ScreenWidth - 20, height: 5000))
    let txtConrainer = UIView(frame: CGRect(x: 10, y: 0, width: ScreenWidth - 20, height: 100))
    let sc = UIScrollView(frame: CGRect(x: 0, y: 100, width: ScreenWidth, height: ScreenHeight - 100))
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        v.txt = "采用LDPC算法,ECC智能纠错机制，S.M.A.R.T,全盘均衡磨损算法技术"
        v.backgroundColor = UIColor.white
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.purple.cgColor
        v.calculatorHeigt = {[weak self] height in
            self?.txtConrainer.frame = CGRect(x: 10, y: 0, width: ScreenWidth - 20, height: height)
            self?.sc.contentSize = CGSize(width: ScreenWidth, height: height)
        }
        sc.addSubview(txtConrainer)
        txtConrainer.clipsToBounds = true
        txtConrainer.addSubview(v)
        view.addSubview(sc)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "加文字", style: .plain, target: self, action: #selector(addTxt))
    }
    
    @objc func addTxt()  {
        v.txt += "有效加快处理速度采用LDPC算法,\n"
        
    }
}

class txtView: UIView {
    var txt = ""{
        didSet{
            if txt.count > 0 {
                setNeedsDisplay()
            }
        }
    }
    
    var calculatorHeigt:((_ height:CGFloat)->Void)?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.textMatrix = .identity
//        context?.ctm = CGAffineTransform(scaleX: 0, y: bounds.size.height)
        context?.translateBy(x: 0, y: bounds.size.height)
        context?.scaleBy(x: 1, y: -1)
        //绘制区域
        let path = CGMutablePath()
        path.addRect(self.bounds)
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor:UIColor.blue]
        let str = NSMutableAttributedString(string: txt,attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(str)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, str.length), path, nil)
        
        
        let arr = CTFrameGetLines(frame) as NSArray

        let last = arr.lastObject as! CTLine
        
       let rect = CTLineGetBoundsWithOptions(last, .useOpticalBounds)
       let height = arr.count * (rect.size.height + 3)
        calculatorHeigt?(height + 3)
//        let lastWidth = rect.size.width
        CTFrameDraw(frame, context!)
    }
}

class imgTextView: UIView {
  
    
}
