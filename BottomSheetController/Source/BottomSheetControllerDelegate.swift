//
//  BottomSheetControllerDelegate.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 10/02/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

@objc
public protocol BottomSheetControllerDelegate: class {
    @objc optional func bottomSheet(bottomSheetController: BottomSheetController,
                              viewController: UIViewController,
                              willMoveTo minY: CGFloat,
                              direction: BottomSheetPanDirection)
    
    @objc optional func bottomSheet(bottomSheetController: BottomSheetController,
                              viewController: UIViewController,
                              didMoveTo minY: CGFloat,
                              direction: BottomSheetPanDirection)
    
    @objc optional func bottomSheet(bottomSheetController: BottomSheetController,
                              viewController: UIViewController,
                              animationWillStart targetY: CGFloat,
                              direction: BottomSheetPanDirection)
    
    @objc optional func bottomSheetAnimationDidStart(bottomSheetController: BottomSheetController,
                                               viewController: UIViewController)
    
    @objc optional func bottomSheetAnimationDidEnd(bottomSheetController: BottomSheetController,
                                             viewController: UIViewController)
}
