//
//  BottomSheetBehavior.swift
//  BottomSheetController
//
//  Created by Ahmed Elassuty on 05/05/2017.
//  Copyright © 2017 Ahmed Elassuty. All rights reserved.
//

class BottomSheetBehavior: UIDynamicBehavior {
    let item                : UIDynamicItem
    let itemBehavior        : UIDynamicItemBehavior
    let attachmentBehavior          : UIAttachmentBehavior
    private(set) var targetPoint : CGPoint               = .zero
    private(set) var velocity    : CGPoint               = .zero

    init(item dynamicItem: UIDynamicItem,
         sheetConfiguration config: BottomSheetConfiguration,
         onAnimationStep: ((_ minY: CGFloat) -> Void)? = nil) {
        item = dynamicItem
        itemBehavior = UIDynamicItemBehavior(items: [item])
        attachmentBehavior  = UIAttachmentBehavior(item: item, attachedToAnchor: .zero)
        super.init()

        action = { [weak self] in
            guard let view = self?.item as? UIView else {
                return
            }

            var frame = view.frame
            frame.size = config.sizeOf(sheetView: view)
            view.frame = frame
            view.layoutIfNeeded()
            onAnimationStep?(frame.minY)
        }

        configureBehavior()
        addBehaviors()
    }
    
    func updateTargetPoint(_ point: CGPoint) {
        targetPoint = point
        attachmentBehavior.anchorPoint = targetPoint
    }
    
    func updateVelocity(_ point: CGPoint) {
        velocity = point
        let currentVelocity = itemBehavior.linearVelocity(for: item)
        let vDelta = velocity - currentVelocity
        itemBehavior.addLinearVelocity(vDelta, for: item)
    }
}

// MARK: Private Methods
private extension BottomSheetBehavior {
    func addBehaviors() {
        addChildBehavior(attachmentBehavior)
        addChildBehavior(itemBehavior)
    }

    func configureBehavior() {
        configureAttachementBehavior()
        configureItemBehavior()
    }
    
    func configureAttachementBehavior() {
        attachmentBehavior.frequency    = 3.5
        attachmentBehavior.damping      = 0.4
        attachmentBehavior.length       = 0
    }
    
    func configureItemBehavior() {
        itemBehavior.density    = 100
        itemBehavior.resistance = 10
    }
}
