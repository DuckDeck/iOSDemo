//
//  File.swift
//  
//
//  Created by chen liang on 2021/4/19.
//

import UIKit
class InfiniteTableViewController: UIViewController {
    
    var isFetchInProcess = false
    var total = 0
    var currentPage = 1
    var baseURL = ""
    var images = [ImageModel]()
    let tb = UITableView()
    let indicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tb)
        tb.tableFooterView = UIView()
        tb.prefetchDataSource = self
        tb.snp.makeConstraints { (m) in
            m.edges.equalTo(0)
        }
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (m) in
            m.center.equalTo(view)
            m.width.height.equalTo(25)
        }
    }
    
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
            let indexPathsForVisibleRows = tb.indexPathsForVisibleRows ?? []
            let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
            return Array(indexPathsIntersection)
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

extension InfiniteTableViewController:UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let needFetch = indexPaths.contains(where: <#T##(IndexPath) throws -> Bool#>)
    }
    
    
}

class ImageCache {
    private var cache = NSCache<AnyObject, UIImage>()
    public static let shared = ImageCache()
    private override init() {}
   
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


struct ImageModel {
    var url = ""
    var order = 0
}
