
//
//  PaletteViewController.swift
//  iOSDemo
//
//  Created by Stan Hu on 2018/7/10.
//  Copyright © 2018 Stan Hu. All rights reserved.
//

import UIKit

class PaletteViewController: UIViewController,TZImagePickerControllerDelegate {
    var imagePickerController:TZImagePickerController!
    let img = UIImageView()
    var recommandColor = ""
    var colorsHint:[String:Any]?
    let tb = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
    }

    
    func initView() {
        view.backgroundColor = UIColor.white

        imagePickerController = TZImagePickerController(maxImagesCount: 3, delegate: self)
        imagePickerController.didFinishPickingPhotosHandle = {[weak self](images,assert,isSelectOriginalPhoto) in
            if let one = images?.first{
                self?.img.image = one
                
                one.getPaletteImageColor(with: .ALL_MODE_PALETTE) { [weak self](mode, dict, err) in
                    if err != nil || mode == nil{
                        Toast.showToast(msg: err?.localizedDescription ?? "识别失败")
                        return
                    }
                    self?.recommandColor = mode!.imageColorString
                    self?.colorsHint = dict as? [String:Any]
                    let c = UIColor(hexString: mode!.imageColorString)

                    self?.img.layer.borderColor = c!.cgColor
                    self?.tb.reloadData()
                }
            }
        }
        
        let btnChoose = UIBarButtonItem(title: "添加照片", style: .plain, target: self, action: #selector(addImage))
        navigationItem.rightBarButtonItem = btnChoose
        img.contentMode = .scaleAspectFill
        img.layer.borderWidth = 6
        img.layer.borderColor = UIColor.clear.cgColor
        img.clipsToBounds = true
        img.addTo(view: view).snp.makeConstraints { (m) in
            m.left.right.equalTo(0)
            m.top.equalTo(NavigationBarHeight)
            m.height.equalTo(ScreenWidth * 0.6)
        }
        
        tb.delegate = self
        tb.dataSource = self
        tb.tableFooterView = UIView()
        tb.rowHeight = 40
        tb.register(ColorHintCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tb)
        tb.snp.makeConstraints { (m) in
            m.bottom.left.right.equalTo(0)
            m.top.equalTo(img.snp.bottom).offset(10)
        }
    }
    
    @objc func addImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension PaletteViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorsHint?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ColorHintCell
        var model:PaletteColorModel?
        var key = ""
        switch indexPath.row {
        case 0:
            model = colorsHint!["vibrant"] as? PaletteColorModel
            key = "vibrant"
        case 1:
            model = colorsHint!["muted"] as? PaletteColorModel
            key = "muted"
        case 2:
            model = colorsHint!["light_vibrant"] as? PaletteColorModel
            key = "light_vibrant"
        case 3:
            model = colorsHint!["light_muted"] as? PaletteColorModel
            key = "light_muted"
        case 4:
            model = colorsHint!["dark_vibrant"] as? PaletteColorModel
            key = "dark_vibrant"
        case 5:
            model = colorsHint!["dark_muted"] as? PaletteColorModel
            key = "dark_muted"
        default:
            break
        }
        cell.fillCell(model: model, key: key)
        return cell
    }
}

class ColorHintCell: UITableViewCell {
    let lblColor = UILabel()
    func fillCell(model:PaletteColorModel?,key:String)  {
        if let m = model{
            lblColor.text = "\(key):--\(m.imageColorString ?? "识别失败")--\(roundf(Float(m.percentage * 10000)) / 100)%"
            lblColor.backgroundColor = UIColor(hexString: m.imageColorString)!

        }
        else{
            lblColor.text = "\(key):-- 识别失败"
            lblColor.backgroundColor = UIColor.darkGray
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        lblColor.txtAlignment(ali: .center).color(color: UIColor.white).addTo(view: contentView).snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
