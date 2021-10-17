
import UIKit
import WebKit
import SwiftUI
import SnapKit
class InterceptViewController: UIViewController {
    var arrData = [("网易","https://www.163.com"),("sohu","https://www.sohu.com/"),("the verge","https://www.theverge.com/")]
    var tbMenu = UITableView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.dataSource = self
        tbMenu.delegate = self
        tbMenu.tableFooterView = UIView()
        view.addSubview(tbMenu)
        tbMenu.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
    }
    
}


extension InterceptViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = arrData[indexPath.row].0
        cell?.detailTextLabel?.text = arrData[indexPath.row].1
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = CacheWebViewController(urlString: arrData[indexPath.row].1)
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
