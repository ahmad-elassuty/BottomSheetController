//
//  UIView+Utils.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 28/06/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let cornerRadii = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: cornerRadii)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask?.removeFromSuperlayer()
        layer.mask = mask
    }
}
