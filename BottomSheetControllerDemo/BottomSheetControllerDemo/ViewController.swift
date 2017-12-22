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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bottomSheetDelegate.viewController = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        bottomSheetDelegate.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let sheetController = bottomSheetController {
            let sheetViewController = UIStoryboard.scrollableBottomSheetViewController
            let sheetConfiguration = sheetViewController.bottomSheetConfiguration
            sheetController.present(sheetViewController,
                                    configuration: sheetConfiguration,
                                    animated: false)
        }
    }
    
    @IBAction func expandSheet(_ sender: Any) {
        bottomSheetController?.expand()
    }
}
