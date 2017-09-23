//
//  PieceImage.swift
//  LinkGame
//
//  Created by Stan Hu on 2017/9/23.
//  Copyright © 2017年 Stan Hu. All rights reserved.
//

import UIKit

class PieceImage: NSObject {
    var image:UIImage
    var imageId:String
    init(image:UIImage,imageId:String) {
        self.image = image
        self.imageId = imageId
    }
}
