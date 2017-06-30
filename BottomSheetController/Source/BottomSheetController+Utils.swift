//
//  BottomSheetController+Utils.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 28/06/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import UIKit

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

public extension UIViewController {
    var bottomSheetController: BottomSheetController? {
        return parent as? BottomSheetController
    }
}

extension UIPanGestureRecognizer {
    var direction: BottomSheetPanDirection {
        return velocity(in: view).y < 0 ? .up : .down
    }
    
    var touchPoint: CGPoint {
        return location(in: view)
    }
}
