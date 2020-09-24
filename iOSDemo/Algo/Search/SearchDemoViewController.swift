//
//  SearchDemoViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2020/9/7.
//  Copyright © 2020 Stan Hu. All rights reserved.
//

import UIKit
class SearchDemoViewController: UIViewController {

    let lblIntro = UILabel()
    
    let lblCode = UILabel()
    let btnRun = UIButton()
    var strDesc = ""
    var code : [[String]]?
    let btnClose = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        lblIntro.text(text: strDesc).lineNum(num: 0).setFont(font: 14).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(5)
            m.right.equalTo(-5)
            m.top.equalTo(10)
        }
        
        var k = 20.createRandomNums(max: 100)
        k.sort()
        let code = """
        ## Title
        ### this is a title
        `this is a code` i need see the code
        ```
           #!/usr/bin/env python3
           print("Hello, World!");
        ```
        """
        let markdownParser = MarkdownParser()
        
        lblCode.attributedText = markdownParser.parse(code)
        lblCode.lineNum(num: 0).addTo(view: view).snp.makeConstraints { (m) in
            m.left.equalTo(10)
            m.right.equalTo(10)
            m.top.equalTo(lblIntro.snp.bottom).offset(20)
        }
        
        
        var nums = 30.createRandomNums(max: 100)
        nums.sort()
        _ = binarySearch(nums: nums, target: 20)
        
    }
    

   

}

func binarySearch(nums:[Int],target:Int) -> Int {

    var start = 0,end = nums.count - 1
    var mid  = 0
    while start <= end {
       mid = start + (end - start) / 2
        if nums[mid] == target {
            return mid
        }
        else if nums[mid] > target {
            end = mid
        }
        else{
            start = mid
        }
    }
    return mid
}
