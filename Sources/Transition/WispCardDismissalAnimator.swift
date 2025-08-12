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
        0.3
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        context.collectionView?.cellForItem(at: context.indexPath)?.alpha = 1
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            fromView?.alpha = 0
        } completion: { isFinished in
            transitionContext.completeTransition(isFinished)
        }
    }
    
}
