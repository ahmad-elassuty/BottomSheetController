//
//  UIStoryboard+BottomSheetControllerDemo.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 08/05/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static var masterViewController: ViewController {
        return main.instantiateInitialViewController() as! ViewController
    }
    
    static var bottomSheetViewController: BottomViewController {
        return main.instantiateViewController(withIdentifier: "BottomViewController") as! BottomViewController
    }
    
    static var scrollableBottomSheetViewController: ScrollableBottomViewController {
        return main.instantiateViewController(withIdentifier: "ScrollableBottomViewController") as! ScrollableBottomViewController
    }
}
