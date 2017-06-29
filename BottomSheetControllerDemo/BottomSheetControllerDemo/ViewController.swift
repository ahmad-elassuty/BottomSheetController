//
//  ViewController.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 03/03/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import UIKit
import BottomSheetController

class ViewController: UIViewController {
    @IBOutlet weak var redView  : UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var blueView : UIView!
    
    let bottomSheetDelegate         = BottomViewControllerDelegate()
    let bottomSheetConfiguration    = BottomViewControllerConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomSheetDelegate.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let sheetController = parent as? BottomSheetController {
            let sheetViewController = UIStoryboard.scrollableBottomSheetViewController
            sheetController.present(sheetViewController,
                                    configuration: bottomSheetConfiguration,
                                    animated: animated)
        }
    }
    
    @IBAction func expandSheet(_ sender: Any) {
        bottomSheetController?.expand()
    }
}
