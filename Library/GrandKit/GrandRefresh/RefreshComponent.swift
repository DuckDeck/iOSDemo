
import UIKit

/// 状态枚举
///
/// - idle:         闲置
/// - pulling:      可以进行刷新
/// - refreshing:   正在刷新
/// - willRefresh:  即将刷新
/// - noMoreData:   没有更多数据
public enum RefreshState {
    case idle           // 闲置
    case pulling        // 可以进行刷新
    case refreshing     // 正在刷新
    case willRefresh    // 即将刷新
    case noMoreData     // 没有更多数据
}

public protocol SubRefreshComponentProtocol {
    func scollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?)
    func scollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?)
}

open class RefreshComponent: UIView {
    
    public weak var scrollView: UIScrollView?
    
    public var scrollViewOriginalInset: UIEdgeInsets?
    
    var state: RefreshState = .idle
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.backgroundColor = UIColor.clear
        
        self.state = .idle
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.state == .willRefresh {
            // 预防view还没显示出来就调用了beginRefreshing
            self.state = .refreshing
        }
    }
    
    deinit {
        if RefreshConstant.debug { print("RefreshComponent excute deinit() ... ")}
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        self.mj_x = 0
        self.mj_w = scrollView.mj_w

        self.scrollView = scrollView
        // 设置永远支持垂直弹簧效果
        self.scrollView?.alwaysBounceVertical = true
        self.scrollViewOriginalInset = scrollView.mj_inset
        
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow != nil {
            self.addObserver()
        } else {
            self.removeAbserver()
        }
    }
    
    
    // MARK: KVO
    
    private func addObserver() {
        if RefreshConstant.debug { print("Refresh -> addObserver ... ")}
        scrollView?.addObserver(self, forKeyPath: RefreshConstant.keyPathContentOffset, options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: RefreshConstant.keyPathContentSize, options: .new, context: nil)
    }
    
    private func removeAbserver() {
        if RefreshConstant.debug { print("Refresh -> removeAbserver ... ")}
        scrollView?.removeObserver(self, forKeyPath: RefreshConstant.keyPathContentOffset)
        scrollView?.removeObserver(self, forKeyPath: RefreshConstant.keyPathContentSize)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard isUserInteractionEnabled else {
            return
        }
        
        if let sub: SubRefreshComponentProtocol = self as? SubRefreshComponentProtocol {
            if keyPath == RefreshConstant.keyPathContentSize {
                sub.scollViewContentSizeDidChange(change: change)
            }
            
            if self.isHidden {
                return
            }
            
            if keyPath == RefreshConstant.keyPathContentOffset {
                sub.scollViewContentOffsetDidChange(change: change)
            }
            
        }
    }
    
    
    
}
