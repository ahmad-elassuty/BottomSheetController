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
    fileprivate var sheetController         : UIViewController?
    fileprivate var configuration           : BottomSheetConfiguration?
    
    fileprivate var sheetAnimator: UIDynamicAnimator!
    fileprivate var panGesture: UIPanGestureRecognizer!
    
    // MARK: Deinitializer
    deinit {}
    
    // MARK: Initializers
    public convenience init(rootViewController: UIViewController) {
        self.init()
        self.rootViewController = rootViewController
        setupPanGesture()
    }
    
    public convenience init(rootViewController: UIViewController,
                            sheetViewController viewController: UIViewController,
                            configuration config: BottomSheetConfiguration) {
        self.init(rootViewController: rootViewController)
        sheetController = viewController
        configuration = config
    }
}

extension BottomSheetController {
    override public func loadView() {
        super.loadView()
        add(childViewController: rootViewController)

        guard let sheetController = sheetController,
            let configuration = configuration else {
            return
        }

        prepareSheetForPresentation(sheetController,
                                    configuration: configuration,
                                    animated: false)
        add(childViewController: sheetController)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        sheetAnimator = UIDynamicAnimator(referenceView: view)
        sheetAnimator.delegate  = self
    }
}

// MARK: - Pan Gestures
private extension BottomSheetController {
    func setupPanGesture() {
        let gestureAction = #selector(panGestureHandler)
        panGesture = UIPanGestureRecognizer(target: self,
                                            action: gestureAction)
        panGesture.delegate = self
    }

    @objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
        guard let sheetController = sheetController,
            let sheetView = sheetController.view,
            let config = configuration else {
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
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let config = configuration,
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
        if let sheetController = sheetController {
            remove(childViewController: sheetController)
        }

        sheetController = viewController
        configuration = config

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
        guard let config = configuration else {
            return
        }

        sheetAnimator.removeAllBehaviors()
        let targetPoint = CGPoint(x: 0, y: config.minYBound)
        moveSheet(to: targetPoint)
    }
    
    func collapse() {
        guard let config = configuration else {
            return
        }

        sheetAnimator.removeAllBehaviors()
        let targetPoint = CGPoint(x: 0, y: config.maxYBound)
        moveSheet(to: targetPoint)
    }
}

extension BottomSheetController: UIDynamicAnimatorDelegate {
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        delegate?.bottomSheetAnimationDidEnd?(
            bottomSheetController: self,
            viewController: sheetController!
        )
    }
    
    public func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        delegate?.bottomSheetAnimationDidStart?(
            bottomSheetController: self,
            viewController: sheetController!
        )
    }
}

// MARK: - Private Methods
private extension BottomSheetController {
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
        guard let sheetView = sheetController?.view,
            let config = configuration else {
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
        configuration?.scrollableView?.panGestureRecognizer.require(toFail: panGesture)
    }
    
    func remove(childViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func moveSheet(to target: CGPoint, velocity: CGPoint = .zero) {
        guard let sheetController = sheetController,
            let sheetView = sheetController.view,
            var config = configuration else {
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
