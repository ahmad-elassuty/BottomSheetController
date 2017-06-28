//
//  BottomViewController.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 03/03/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import UIKit
import BottomSheetController

class BottomViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners([.topLeft, .topRight], radius: 12)
    }
    
    @IBAction func collapseSheet(_ sender: Any) {
        bottomSheetController?.collapse()
    }
}
