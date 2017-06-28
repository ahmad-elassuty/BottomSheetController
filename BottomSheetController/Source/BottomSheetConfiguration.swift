//
//  BottomSheetConfiguration.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 10/02/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

public protocol BottomSheetConfiguration {
    var initialY                        : CGFloat       { get }
    var automaticallyAdjustSheetSize    : Bool          { get }
    
    func canMoveTo(y: CGFloat) -> Bool
    func nextY(from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat
}

// MARK: - Default implementation
public extension BottomSheetConfiguration {
    var initialY: CGFloat {
        return UIScreen.main.bounds.maxY - 200
    }
    
    var automaticallyAdjustSheetSize: Bool {
        return true
    }
    
    func canMoveTo(y: CGFloat) -> Bool {
        let screenBounds = UIScreen.main.bounds
        return y >= screenBounds.minY && y <= screenBounds.maxY
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
