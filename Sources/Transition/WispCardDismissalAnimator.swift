//
//  WispCardDismissalAnimator.swift
//  Wisp
//
//  Created by 김민성 on 8/12/25.
//

import UIKit

internal final class WispCardDismissalAnimator: NSObject {
    
    private let context: WispContext
    
    init(context: WispContext) {
        self.context = context
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension WispCardDismissalAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.5
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        
        let topInset = context.configuration.layout.presentedAreaInset.top
        
        UIView.springAnimate(withDuration: transitionDuration(using: transitionContext)) { [weak self] in
            guard let self else { return }
            fromView?.superview?.frame.origin.y += (containerView.frame.height - topInset)
            self.context.collectionView?.cellForItem(at: self.context.sourceIndexPath)?.alpha = 1
        } completion: { isFinished in
            transitionContext.completeTransition(isFinished)
        }
    }
    
}
