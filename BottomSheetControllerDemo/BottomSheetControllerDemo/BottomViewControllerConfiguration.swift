//
//  BottomViewControllerConfiguration.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 03/03/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import Foundation
import BottomSheetController

class BottomViewControllerConfiguration: NSObject, BottomSheetConfiguration {
    var initialY: CGFloat {
        return UIScreen.main.bounds.height/2
    }
    
    func nextY(from currentY: CGFloat, panDirection direction: BottomSheetPanDirection) -> CGFloat {
        let screenMidY = UIScreen.main.bounds.height/2
        switch direction {
        case .up:
            return currentY < screenMidY ? minYBound : screenMidY
        case .down:
            return currentY > screenMidY ? maxYBound : screenMidY
        }
    }
}
