
import Foundation
import WebKit
class URLSchemeHandler:NSObject, WKURLSchemeHandler {
  
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
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
            urlSchemeTask.didReceive(res!)
            urlSchemeTask.didReceive(data!)
            urlSchemeTask.didFinish()
        }
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("stop urlSchemeTask")
    }
}
