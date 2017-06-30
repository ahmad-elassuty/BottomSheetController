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
    
    fileprivate var sheetAnimator: UIDynamicAnimator!
    fileprivate var panGesture: UIPanGestureRecognizer!
    
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
        panGesture.delegate = self
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
        
        if config.canMoveTo(newY) {
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
        
        let targetY     = config.nextY(from: sheetView.frame.minY, panDirection: direction)
        let targetPoint = CGPoint(x: 0, y: targetY)
        moveSheet(to: targetPoint, velocity: velocity)
    }
}

extension BottomSheetController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let config = topSheetConfig,
            let scrollableView = config.scrollableView,
            let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        if !scrollableView.frame.contains(panGesture.touchPoint) {
            return true
        }
        
        let offsetY         = scrollableView.contentOffset.y
        let isBouncing      = offsetY < 0
        let isDragingDown   = panGesture.direction == .down
        return (isBouncing && isDragingDown) ||
            (offsetY == 0 && isDragingDown) ||
            !config.allowsContentScrolling
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

public extension BottomSheetController {
    func expand() {
        guard let config = topSheetConfig else { return }
        sheetAnimator.removeAllBehaviors()
        let targetPoint = CGPoint(x: 0, y: config.minYBound)
        moveSheet(to: targetPoint)
    }
    
    func collapse() {
        guard let config = topSheetConfig else { return }
        sheetAnimator.removeAllBehaviors()
        let targetPoint = CGPoint(x: 0, y: config.maxYBound)
        moveSheet(to: targetPoint)
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
        var config = config
        config.allowsContentScrolling = config.initialY == config.minYBound
    }
    
    func translateSheetView(with translation: CGPoint) {
        guard let sheetView = topSheetView,
            let config = topSheetConfig else {
                return
        }
        
        sheetView.frame.origin += translation
        sheetView.frame.size   = config.sizeOf(sheetView: sheetView)
        sheetView.layoutIfNeeded()
    }
    
    func add(childViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        topSheetConfig?.scrollableView?.panGestureRecognizer.require(toFail: panGesture)
    }
    
    func remove(childViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func moveSheet(to target: CGPoint, velocity: CGPoint = .zero) {
        guard let sheetController = topSheetController,
            let sheetView = topSheetView,
            var config = topSheetConfig else {
                return
        }
        
        config.allowsContentScrolling = target.y == config.minYBound
        let currentY = sheetView.frame.minY
        let direction: BottomSheetPanDirection = target.y >= currentY ? .down : .up
        
        let finalHeight = config.sizeFor(y: target.y).height
        let anchorY     = target.y + finalHeight/2
        let targetPoint = CGPoint(x: view.center.x, y: anchorY)
        let behavior    = BottomSheetBehavior(item: sheetView, sheetConfiguration: config) { newY in
            self.delegate?.bottomSheet?(bottomSheetController: self,
                                        viewController: sheetController,
                                        didMoveTo: newY,
                                        direction: direction)
        }
        
        behavior.updateTargetPoint(targetPoint)
        behavior.updateVelocity(velocity)
        delegate?.bottomSheet?(bottomSheetController: self,
                               viewController: sheetController,
                               animationWillStart: target.y,
                               direction: direction)
        sheetAnimator.addBehavior(behavior)
    }
}
