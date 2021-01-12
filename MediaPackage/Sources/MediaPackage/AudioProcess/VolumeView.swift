//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/12.
//

import UIKit
enum HUDType: Int {
    case bar = 0
    case line
}

class VolumeView: UIView {
    
    //MARK: Private Properties
    /// 声音表数组
    private var soundMeters: [Float]!
    
    private var type: HUDType = .bar
    
    var barWidth = 6
    
    var barGap = 3
    //MARK: Init
    convenience init(frame: CGRect, type: HUDType) {
        self.init(frame: frame)
        self.type = type
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentMode = .redraw   //内容模式为重绘，因为需要多次重复绘制音量表
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notice:)), name: NSNotification.Name.init("updateMeters"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if soundMeters != nil && soundMeters.count > 0 {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineCap(.round)
            context?.setLineJoin(.round)
            context?.setStrokeColor(UIColor.blue.cgColor)
            
            let noVoice = -46.0     // 该值代表低于-46.0的声音都认为无声音
            let maxVolume = 45.0    // 该值代表最高声音为55.0
            
            switch type {
            case .bar:
                context?.setLineWidth(CGFloat(barWidth))
                for (index,item) in soundMeters.enumerated() {
                    var barHeight = (maxVolume - (Double(item) - noVoice))    //通过当前声音表计算应该显示的声音表高度
                    if barHeight > 45{
                        barHeight = 45
                    }
                    context?.move(to: CGPoint(x: index * barWidth + barGap * index, y: 45 ))
                    context?.addLine(to: CGPoint(x: index * barWidth + barGap * index, y:  Int(barHeight)))
                }
            case .line:
                context?.setLineWidth(1.5)
                for (index, item) in soundMeters.enumerated() {
                    let position = maxVolume - (Double(item) - noVoice)     //计算对应线段高度
                    context?.addLine(to: CGPoint(x: Double(index * 6 + 3), y: position))
                    context?.move(to: CGPoint(x: Double(index * 6 + 3), y: position))
                }
            }
            context?.strokePath()
        }
    }
    
    @objc private func updateView(notice: Notification) {
        soundMeters = notice.object as? [Float]
        setNeedsDisplay()
    }
    
}
