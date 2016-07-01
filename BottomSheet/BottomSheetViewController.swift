//
//  BottomSheetViewController.swift
//  BottomSheet
//
//  Created by Ahmed Elassuty on 7/1/16.
//  Copyright © 2016 Ahmed Elassuty. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController {
    let fullView: CGFloat = 100
    var partialView: CGFloat {
        return UIScreen.mainScreen().bounds.height - (left.frame.maxY + UIApplication.sharedApplication().statusBarFrame.height)
    }

    @IBOutlet weak var holdView: UIView!
    
    @IBOutlet weak var left: UIButton!
    @IBOutlet weak var right: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 5
        holdView.layer.cornerRadius = 3
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        view.addGestureRecognizer(gesture)
        
        left.layer.cornerRadius = 10
        right.layer.cornerRadius = 10
        left.layer.borderColor = UIColor(colorLiteralRed: 0, green: 148/255, blue: 247.0/255.0, alpha: 1).CGColor
        left.layer.borderWidth = 1
        view.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .Dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.mainScreen().bounds
        bluredView.frame = UIScreen.mainScreen().bounds
        
        view.insertSubview(bluredView, atIndex: 0)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animateWithDuration(0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRectMake(0, yComponent!, frame!.width, frame!.height)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rightButton(sender: AnyObject) {
        print("tabbed")
    }
    
    @IBAction func close(sender: AnyObject) {
        UIView.animateWithDuration(0.3) {
            self.view.frame = CGRectMake(0, self.partialView, self.view.frame.width, self.view.frame.height)
        }
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        let velocity = recognizer.velocityInView(self.view)
        let y = self.view.frame.minY
        if ( y + translation.y >= fullView) && (y + translation.y <= partialView ) {
            self.view.frame = CGRectMake(0, y + translation.y, view.frame.width, view.frame.height)
            recognizer.setTranslation(CGPointZero, inView: self.view)
        }
        
        if recognizer.state == .Ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )

            duration = duration > 1.3 ? 1 : duration
            UIView.animateWithDuration(duration) {
                
                if  velocity.y >= 0 {
                    self.view.frame = CGRectMake(0, self.partialView, self.view.frame.width, self.view.frame.height)
                } else {
                    self.view.frame = CGRectMake(0, self.fullView, self.view.frame.width, self.view.frame.height)
                }
            }
        }
    
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
