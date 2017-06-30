//
//  BottomSheetConfiguration.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 10/02/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

public protocol BottomSheetConfiguration {
    var initialY                        : CGFloat           { get }
    var minYBound                       : CGFloat           { get }
    var maxYBound                       : CGFloat           { get }
    var automaticallyAdjustSheetSize    : Bool              { get }
    var allowsContentScrolling          : Bool              { get set }
    var scrollableView                  : UIScrollView?     { get }
    
    func canMoveTo(y: CGFloat) -> Bool
    func nextY(from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat
}

// MARK: - Default implementation
public extension BottomSheetConfiguration {
    var initialY: CGFloat {
        return minYBound
    }
    
    var minYBound: CGFloat {
        return 20
    }
    
    var maxYBound: CGFloat {
        return UIScreen.main.bounds.height - 200
    }
    
    var automaticallyAdjustSheetSize: Bool {
        return true
    }
    
    var scrollableView: UIScrollView? {
        return nil
    }
    
    func canMoveTo(y: CGFloat) -> Bool {
        return y >= minYBound && y <= maxYBound
    }
}

extension BottomSheetConfiguration {
    func sizeOf(sheetView view: UIView) -> CGSize {
        return sizeFor(y: view.frame.minY)
    }
    
    func sizeFor(y: CGFloat) -> CGSize {
        let screenBounds = UIScreen.main.bounds
        guard automaticallyAdjustSheetSize else {
            return screenBounds.size
        }
        
        let width   = screenBounds.width
        let height  = screenBounds.height - y
        return CGSize(width: width, height: height)
    }
}
