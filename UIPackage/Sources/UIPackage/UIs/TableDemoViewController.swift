//
//  File.swift
//  
//
//  Created by chen liang on 2021/4/19.
//

import UIKit
import SwiftUI
import CommonLibrary
class InfiniteTableViewController: BaseViewController {
    
    fileprivate let tb = UITableView()
    fileprivate let indicatorView = UIActivityIndicatorView(style: .medium)
    var vm : PreloadCellViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm = PreloadCellViewModel()
        vm.delegate = self
        
        view.addSubview(tb)
        tb.tableFooterView = UIView()
        tb.prefetchDataSource = self
        tb.register(ProloadTableViewCell.self, forCellReuseIdentifier: "cell")
        tb.dataSource = self
        tb.delegate = self
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        view.addSubview(indicatorView)
        indicatorView.startAnimating()
        indicatorView.snp.makeConstraints { (m) in
            m.center.equalTo(view)
            m.width.height.equalTo(25)
        }
        vm.fetchImages()
    }
    
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tb.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func isLoadingCell(index:IndexPath) -> Bool {
        return index.row >= vm.currentCount
    }

}

extension InfiniteTableViewController:PreloadCellViewModelDelegate{
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndex = newIndexPathsToReload else {
            tb.tableFooterView = nil
            tb.reloadData()
            return
        }
        let indexPath = visibleIndexPathsToReload(intersecting: newIndex)
        indicatorView.stopAnimating()
        tb.reloadRows(at: indexPath, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        indicatorView.stopAnimating()
        tb.reloadData()
    }
    
    
}

extension InfiniteTableViewController:UITableViewDataSourcePrefetching,UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let needFetch = indexPaths.contains { $0.row >= vm.currentCount}
        if needFetch {
            // 1.满足条件进行翻页请求
            indicatorView.startAnimating()
            vm.fetchImages()
        }
        for indexPath in indexPaths {
            if let _ = vm.loadingOperations[indexPath] {
                return
            }
            
            if let dataloader = vm.loadImage(at: indexPath.row) {
                print("在 \(indexPath.row) 行 对图片进行 prefetch ")
                // 2 对需要下载的图片进行预热
                vm.loadingQueue.addOperation(dataloader)
                // 3 将该下载线程加入到记录数组中以便根据索引查找
                vm.loadingOperations[indexPath] = dataloader
            }
        }

    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{
            if let dataLoader = vm.loadingOperations[$0] {
                print("在 \($0.row) 行 cancelPrefetchingForRowsAt ")
                dataLoader.cancel()
                vm.loadingOperations.removeValue(forKey: $0)
            }

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // preheat image ，处理将要显示的图像
        guard let cell = cell as? ProloadTableViewCell else {
            return
        }

        // 图片下载完毕后更新 cell
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.updateUI(image, orderNo: "\(indexPath.row)")
            vm.loadingOperations.removeValue(forKey: indexPath)
        }
        // 1. 首先判断是否已经存在创建好的下载线程
        if let dataLoader = vm.loadingOperations[indexPath] {
            if let image = dataLoader.image {
                // 1.1 若图片已经下载好，直接更新
                cell.updateUI(image, orderNo: "\(indexPath.row)")
            } else {
                // 1.2 若图片还未下载好，则等待图片下载完后更新 cell
                dataLoader.loadingCompleteHandle = updateCellClosure
            }
        } else {
            // 2. 没找到，则为指定的 url 创建一个新的下载线程
            print("在 \(indexPath.row) 行创建一个新的图片下载线程")
            if let dataloader = vm.loadImage(at: indexPath.row) {
                // 2.1 添加图片下载完毕后的回调
                dataloader.loadingCompleteHandle = updateCellClosure
                // 2.2 启动下载
                vm.loadingQueue.addOperation(dataloader)
                // 2.3 将该下载线程加入到记录数组中以便根据索引查找
                vm.loadingOperations[indexPath] = dataloader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ProloadTableViewCell else {
            fatalError("you can not load cell")
        }
        if isLoadingCell(index: indexPath) {
            cell.updateUI(.none, orderNo: "\(indexPath.row)")
        }
        return cell
    }
}

class ImageCache {
    private var cache = NSCache<AnyObject, UIImage>()
    public static let shared = ImageCache()
    
   
    func getCache() -> NSCache<AnyObject, UIImage> {
       return cache
    }
}

class DataLoadOperation: Operation {
    var image: UIImage?
    var loadingCompleteHandle: ((UIImage?) -> ())?
    private var _image: ImageModel
    
    init(_ image: ImageModel) {
        _image = image
    }
    
    public final func getCacheImage(url: NSURL) -> UIImage? {
        return ImageCache.shared.getCache().object(forKey: url)
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let url = _image.url else {
            return
        }
        downloadImageFrom(url) { (image) in
            DispatchQueue.main.async { [weak self] in
                guard let ss = self else { return }
                if ss.isCancelled { return }
                ss.image = image
                ss.loadingCompleteHandle?(ss.image)
            }
        }
        
    }
    
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    func downloadImageFrom(_ url: URL, completeHandler: @escaping (UIImage?) -> ()) {
        // Check for a cached image.
        if let cachedImage = getCacheImage(url: url as NSURL) {
            print("命中缓存")
            DispatchQueue.main.async {
                completeHandler(cachedImage)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let _image = UIImage(data: data)
                else { return }
            
            // Cache the image.
            ImageCache.shared.getCache().setObject(_image, forKey: url as NSURL)

            completeHandler(_image)
            }.resume()
    }
}

struct InfiniteTableDemo:UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: InfiniteTableViewController, context: Context) {
        
    }
    typealias UIViewControllerType = InfiniteTableViewController
    
    func makeUIViewController(context: Context) -> InfiniteTableViewController {
        return InfiniteTableViewController()
    }
}
struct ImageModel {
    var url: URL?
  var order: Int?
  
  init(url: String, order: Int) {
      self.url = URL(string: url)
      self.order = order
  }}
