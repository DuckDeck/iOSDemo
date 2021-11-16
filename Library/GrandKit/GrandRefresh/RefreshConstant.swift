import UIKit

class RefreshConstant {
    static let slowAnimationDuration: TimeInterval = 0.4
    static let fastAnimationDuration: TimeInterval = 0.25
    
    
    static let keyPathContentOffset: String = "contentOffset"
    static let keyPathContentInset: String = "contentInset"
    static let keyPathContentSize: String = "contentSize"
    //    static let keyPathPanState: String = "state"
    
    
    static var associatedObjectHeader = 0
    static var associatedObjectFooter = 1
    
    static let debug = false
}

public func RLocalize(_ string:String)->String{
    return NSLocalizedString(string, tableName: "Localize", bundle: Bundle(for: DefaultRefreshHeader.self), value: "", comment: "")
}
public struct RHeaderString{
    static public let pullDownToRefresh = RLocalize("pullDownToRefresh")
    static public let releaseToRefresh = RLocalize("releaseToRefresh")
    static public let refreshSuccess = RLocalize("refreshSuccess")
    static public let refreshFailure = RLocalize("refreshFailure")
    static public let refreshing = RLocalize("refreshing")
}

public struct RFooterString{
    static public let pullUpToRefresh = RLocalize("pullUpToRefresh")
    static public let loadding = RLocalize("loadMore")
    static public let noMoreData = RLocalize("noMoreData")
    static public let releaseLoadMore = RLocalize("releaseLoadMore")
    //static public let scrollAndTapToRefresh = GTMRLocalize("scrollAndTapToRefresh")
}
