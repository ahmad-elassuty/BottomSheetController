//
//  BottomSheet+Utils.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 28/06/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import Foundation

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
