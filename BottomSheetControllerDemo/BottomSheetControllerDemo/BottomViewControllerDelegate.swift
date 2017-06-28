//
//  BottomViewControllerDelegate.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 03/03/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import Foundation
import BottomSheetController

class BottomViewControllerDelegate: NSObject, BottomSheetControllerDelegate {
    weak var viewController: UIViewController?
    
    func bottomSheet(bottomSheetController: BottomSheetController,
                     viewController: UIViewController,
                     willMoveTo minY: CGFloat,
                     direction: BottomSheetPanDirection) {
        
    }
    
    func bottomSheet(bottomSheetController: BottomSheetController,
                     viewController: UIViewController,
                     didMoveTo minY: CGFloat,
                     direction: BottomSheetPanDirection) {
        let screenHeight = UIScreen.main.bounds.height
        if minY < (screenHeight - 200) {
            castedViewController?.greenView.alpha = minY/(screenHeight - 200)
        } else {
            castedViewController?.greenView.alpha = 1
        }
    }
    
    func bottomSheet(bottomSheetController: BottomSheetController,
                     viewController: UIViewController,
                     animationWillStart targetY: CGFloat,
                     direction: BottomSheetPanDirection) {
        castedViewController?.blueView.isHidden = false
    }
    
    func bottomSheetAnimationDidEnd(bottomSheetController: BottomSheetController, viewController: UIViewController) {
        castedViewController?.blueView.isHidden = true
    }
}

fileprivate extension BottomViewControllerDelegate {
    var castedViewController: ViewController? {
        return viewController as? ViewController
    }
}
