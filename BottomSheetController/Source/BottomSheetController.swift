//
//  BottomSheetController.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 10/02/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

public class BottomSheetController: UIViewController {
    // MARK: Properties
    public weak var delegate                : BottomSheetControllerDelegate?
    
    fileprivate var rootViewController      : UIViewController!
    fileprivate var viewControllers         = [UIViewController]()
    fileprivate var configurations          = [BottomSheetConfiguration]()
    
    fileprivate var currentSheetIndex  = 0 {
        didSet {
            if currentSheetIndex < 0 {
                currentSheetIndex = 0
            }
        }
    }
    
    fileprivate var sheetAnimator   : UIDynamicAnimator!
    fileprivate var panGesture      : UIPanGestureRecognizer!
    
    var numberOfSheets: Int {
        return viewControllers.count
    }
    
    var isEmpty: Bool {
        return numberOfSheets == 0
    }
    
    var topSheetController: UIViewController? {
        return isEmpty ? nil : viewControllers[currentSheetIndex]
    }
    
    var topSheetView: UIView? {
        return isEmpty ? nil : viewControllers[currentSheetIndex].view
    }
    
    var topSheetConfig: BottomSheetConfiguration? {
        return isEmpty ? nil : configurations[currentSheetIndex]
    }
    
    // MARK: Deinitializer
    deinit {}
    
    // MARK: Initializers
    public convenience init(rootViewController: UIViewController) {
        self.init()
        self.rootViewController = rootViewController
        
        let panGestureAction = #selector(panGestureHandler)
        panGesture = UIPanGestureRecognizer(target: self, action: panGestureAction)
    }
    
    public convenience init(rootViewController: UIViewController,
                            bottomSheetViewController bottomSheet: UIViewController,
                            bottomSheetConfiguration config: BottomSheetConfiguration) {
        self.init(rootViewController: rootViewController)
        addSheet(bottomSheet, configuration: config)
    }
}

extension BottomSheetController {
    override public func loadView() {
        super.loadView()
        add(childViewController: rootViewController)
        
        if let sheetController = topSheetController, let config = topSheetConfig {
            prepareSheetForPresentation(sheetController, configuration: config, animated: false)
            add(childViewController: sheetController)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        sheetAnimator = UIDynamicAnimator(referenceView: view)
        sheetAnimator.delegate  = self
    }
}

// MARK: - Gestures Handlers
private extension BottomSheetController {
    @objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
        guard let sheetController = topSheetController,
            let sheetView = topSheetView,
            let config = topSheetConfig else {
                return
        }
        
        var translation = recognizer.translation(in: view)
        var velocity    = recognizer.velocity(in: view)
        velocity.x      = 0
        let direction: BottomSheetPanDirection = velocity.y < 0 ? .up : .down
        let newY =  sheetView.frame.minY + translation.y
        
        if config.canMoveTo(y: newY) {
            delegate?.bottomSheet?(bottomSheetController: self,
                                   viewController: sheetController,
                                   willMoveTo: newY,
                                   direction: direction)
            translation.x = 0
            translateSheetView(with: translation)
            delegate?.bottomSheet?(bottomSheetController: self,
                                   viewController: sheetController,
                                   didMoveTo: newY,
                                   direction: direction)
        }
        recognizer.setTranslation(.zero, in: sheetView)
        
        if recognizer.state == .began {
            sheetAnimator.removeAllBehaviors()
            return
        }
        
        guard recognizer.state == .ended else {
            return
        }
        
        let currentY    = sheetView.frame.minY
        let targetY     = config.nextY(from: currentY, panDirection: direction)
        let finalHeight = config.sizeFor(y: targetY).height
        let anchorY     = targetY + finalHeight/2
        let targetPoint = CGPoint(x: view.center.x, y: anchorY)
        
        let behavior    = BottomSheetBehavior(item: sheetView, sheetConfiguration: config) { currentMinY in
            self.delegate?.bottomSheet?(bottomSheetController: self,
                                        viewController: sheetController,
                                        didMoveTo: currentMinY,
                                        direction: direction)
        }
        
        behavior.updateTargetPoint(targetPoint)
        behavior.updateVelocity(velocity)
        
        delegate?.bottomSheet?(bottomSheetController: self,
                               viewController: sheetController,
                               animationWillStart: targetY,
                               direction: direction)
        sheetAnimator.addBehavior(behavior)
    }
}

// MARK: Public Methods
public extension BottomSheetController {
    func present(_ viewController: UIViewController,
                 configuration config: BottomSheetConfiguration,
                 animated: Bool = true,
                 completion: ((Bool) -> Void)? = nil) {
        addSheet(viewController, configuration: config)
        prepareSheetForPresentation(viewController, configuration: config, animated: animated)
        add(childViewController: viewController)
        
        guard animated else {
            completion?(true)
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            let yTranslation = -(UIScreen.main.bounds.height - config.initialY)
            let targetPoint = CGPoint(x: 0, y: yTranslation)
            self?.translateSheetView(with: targetPoint)
            }, completion: completion)
    }
}

extension BottomSheetController: UIDynamicAnimatorDelegate {
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        delegate?.bottomSheetAnimationDidEnd?(bottomSheetController: self, viewController: topSheetController!)
    }
    
    public func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        delegate?.bottomSheetAnimationDidStart?(bottomSheetController: self, viewController: topSheetController!)
    }
}

// MARK: - Private Methods
private extension BottomSheetController {
    func addSheet(_ sheet: UIViewController, configuration config: BottomSheetConfiguration) {
        viewControllers.append(sheet)
        configurations.append(config)
        currentSheetIndex = viewControllers.count - 1
    }
    
    func prepareSheetForPresentation(_ sheet: UIViewController,
                                     configuration config: BottomSheetConfiguration,
                                     animated: Bool) {
        let screenMaxY = UIScreen.main.bounds.maxY
        let sheetMinY = animated ? screenMaxY : config.initialY
        sheet.view.frame.origin = CGPoint(x: 0, y: sheetMinY)
        sheet.view.frame.size   = config.sizeOf(sheetView: sheet.view)
        sheet.view.addGestureRecognizer(panGesture)
    }
    
    func translateSheetView(with translation: CGPoint) {
        guard let sheetView = topSheetView,
            let config = topSheetConfig else {
                return
        }
        
        sheetView.frame.origin = sheetView.frame.origin + translation
        sheetView.frame.size   = config.sizeOf(sheetView: sheetView)
        sheetView.layoutIfNeeded()
    }
    
    func add(childViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
    
    func remove(childViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}
