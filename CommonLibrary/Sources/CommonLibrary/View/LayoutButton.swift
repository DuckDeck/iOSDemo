//
//  File.swift
//  
//
//  Created by shadowedge on 2021/1/5.
//

import UIKit

public enum LayoutButtonStyle{
   case  LeftImageRightTitle,LeftTitleRightImage,TopImageBottomTitle,TopTitleBottomImage
}

public class LayoutButton: UIButton {
    var layoutStyle = LayoutButtonStyle.LeftImageRightTitle
    var midSpacing:CGFloat = 5{
        didSet{
            setNeedsLayout()
        }
    }
    var imageSize = CGSize(width: 50, height: 50){
        didSet{
            setNeedsLayout()
        }
    }
    var textLine = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if imageSize == CGSize(width: 0, height: 0) {
            imageView?.sizeToFit()
        }
        else{
            imageView?.frame = CGRect(x: imageView!.frame.origin.x, y: imageView!.frame.origin.y, width: imageSize.width, height: imageSize.height)
        }
        
        if titleLabel!.numberOfLines == 0{
            let size = titleLabel!.sizeThatFits(imageSize)
            titleLabel?.frame = CGRect(x: titleLabel!.frame.origin.x, y: titleLabel!.frame.origin.y, width: size.width, height: size.height)
        }
        else{
            if textLine == 0{
                titleLabel?.sizeToFit()
            }
            else{
                titleLabel?.numberOfLines = textLine
                let newSize = titleLabel!.sizeThatFits(CGSize(width: imageSize.width + 12, height: imageSize.height))
                titleLabel?.frame = CGRect(x:titleLabel!.frame.origin.x , y: titleLabel!.frame.origin.y, width: newSize.width, height: newSize.height)
            }
        }
        
        switch layoutStyle {
            case .LeftImageRightTitle:
                self.layoutHorizontal(leftView: imageView!, rightView: titleLabel!)
            case .LeftTitleRightImage:
                self.layoutHorizontal(leftView: titleLabel!, rightView: imageView!)
            case .TopImageBottomTitle:
                self.layoutVertical(upView: imageView!, downView: titleLabel!)
            case .TopTitleBottomImage:
                self.layoutVertical(upView: titleLabel!, downView: imageView!)
        }
    }
    
    func layoutHorizontal(leftView:UIView,rightView:UIView) {
        var leftViewFrame = leftView.frame
        var rightViewFrame = rightView.frame
        let totalWidth = leftViewFrame.width + midSpacing + rightViewFrame.width
        leftViewFrame.origin.x = (frame.width - totalWidth) / 2.0
        leftViewFrame.origin.y = (frame.height - leftViewFrame.height) / 2.0
        leftView.frame = leftViewFrame
        rightViewFrame.origin.x = leftViewFrame.maxX + midSpacing
        rightViewFrame.origin.y = (frame.height - rightViewFrame.height) / 2.0
        rightView.frame = rightViewFrame
    }
    
    func layoutVertical(upView:UIView,downView:UIView)  {
        var upViewFrame = upView.frame
        var downViewFrame = downView.frame
        let totalHeight = upViewFrame.height + midSpacing + downViewFrame.height
        upViewFrame.origin.y = (frame.height - totalHeight) / 2.0
        upViewFrame.origin.x = (frame.width - upViewFrame.width) / 2
        upView.frame = upViewFrame
        downViewFrame.origin.y = upViewFrame.maxY + midSpacing
        downViewFrame.origin.x = (frame.width - downViewFrame.width) / 2.0
        downView.frame = downViewFrame
    }
    
    public override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        setNeedsLayout()
    }
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
    }
    
}
