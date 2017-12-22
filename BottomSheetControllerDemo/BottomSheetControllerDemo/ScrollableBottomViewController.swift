//
//  ScrollableBottomViewController.swift
//  BottomSheetControllerDemo
//
//  Created by Ahmed Elassuty on 29/06/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

import UIKit
import BottomSheetController

class ScrollableBottomViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    let bottomSheetConfiguration    = BottomViewControllerConfiguration()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        bottomSheetConfiguration.viewController = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        bottomSheetConfiguration.viewController = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners([.topLeft, .topRight], radius: 12)
    }
    
    @IBAction func collapseSheet() {
        bottomSheetController?.collapse()
    }
}

extension ScrollableBottomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath.row + 1)"
        return cell
    }
}
