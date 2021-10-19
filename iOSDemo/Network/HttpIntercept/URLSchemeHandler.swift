
import Foundation
import WebKit
class URLSchemeHandler:NSObject, WKURLSchemeHandler {
    var holdUrlSchemeTasks = [AnyHashable: Bool]()
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
      //  holdUrlSchemeTasks[urlSchemeTask.description] = true
        let request = urlSchemeTask.request
        print("request = \(request)")
        let url = request.url?.absoluteString
        if url?.hasSuffix("css") ?? false {
            print("hook css file:\(url!)")
        }
        if url?.hasSuffix("js") ?? false {
            print("hook js file:\(url!)")
        }
        let session = URLSession.init(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (data, res, err) in
            
            if let isValid = self.holdUrlSchemeTasks[urlSchemeTask.description] {
                if !isValid {
                    return
                }
            }
            
            urlSchemeTask.didReceive(res!)
            urlSchemeTask.didReceive(data!)
            urlSchemeTask.didFinish()
        }
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
       // holdUrlSchemeTasks[urlSchemeTask.description] = false
    }
    
    
}
