import UIKit
import SnapKit

public extension Array {

    @available(*, deprecated, message:"Use newer snp.* syntax.")
    func snp_prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        return self.snp.prepareConstraints(closure)
    }
    
    @available(*, deprecated, message:"Use newer snp.* syntax.")
    func snp_makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.makeConstraints(closure)
    }
    
    @available(*, deprecated, message:"Use newer snp.* syntax.")
    func snp_remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.remakeConstraints(closure)
    }
    
    @available(*, deprecated, message:"Use newer snp.* syntax.")
    func snp_updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.updateConstraints(closure)
    }
    
    @available(*, deprecated, message:"Use newer snp.* syntax.")
    func snp_removeConstraints() {
        self.snp.removeConstraints()
    }
    
    @available(*, deprecated, message:"Use newer snp.* syntax.")
    func snp_distributeViewsAlong(axisType: NSLayoutConstraint.Axis,
                                         fixedSpacing: CGFloat,
                                         leadSpacing: CGFloat = 0,
                                         tailSpacing: CGFloat = 0) {
        
        self.snp.distributeViewsAlong(axisType: axisType,
                                      fixedSpacing: fixedSpacing,
                                      leadSpacing: leadSpacing,
                                      tailSpacing: tailSpacing)
    }

    
    @available(*, deprecated:3.0, message:"Use newer snp.* syntax.")
    public func snp_distributeViewsAlong(axisType: NSLayoutConstraint.Axis,
                                         fixedItemLength: CGFloat,
                                         leadSpacing: CGFloat = 0,
                                         tailSpacing: CGFloat = 0) {
        
        self.snp.distributeViewsAlong(axisType: axisType,
                                      fixedItemLength: fixedItemLength,
                                      leadSpacing: leadSpacing,
                                      tailSpacing: tailSpacing)
    }
    
    @available(*, deprecated:3.0, message:"Use newer snp.* syntax.")
    public func snp_distributeSudokuViews(fixedItemWidth: CGFloat,
                                          fixedItemHeight: CGFloat,
                                          warpCount: Int,
                                          edgeInset: UIEdgeInsets = UIEdgeInsets.zero) {
        
        self.snp.distributeSudokuViews(fixedItemWidth: fixedItemWidth,
                                       fixedItemHeight: fixedItemHeight,
                                       warpCount: warpCount,
                                       edgeInset: edgeInset)
    }
    
    @available(*, deprecated:3.0, message:"Use newer snp.* syntax.")
    public func snp_distributeSudokuViews(fixedLineSpacing: CGFloat,
                                          fixedInteritemSpacing: CGFloat,
                                          warpCount: Int,
                                          edgeInset: UIEdgeInsets = UIEdgeInsets.zero) {
        
        self.snp.distributeSudokuViews(fixedLineSpacing: fixedLineSpacing,
                                       fixedInteritemSpacing: fixedInteritemSpacing,
                                       warpCount: warpCount,
                                       edgeInset: edgeInset)
    }
    
    
    

    public var snp: ConstraintArrayDSL {
        return ConstraintArrayDSL(array: self as! Array<ConstraintView>)
    }
    
}
