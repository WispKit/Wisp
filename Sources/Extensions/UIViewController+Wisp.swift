//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 7/29/25.
//

import UIKit

public extension UIViewController {
    
    var wisp: WispPresenter {
        return WispPresenter(source: self)
    }
    
}


internal extension UIViewController {
    
    func dismissCard(withVelocity initialVelocity: CGPoint = .zero) {
        if isBeingPresented {
            guard
                let wispTransitioningDelegate = transitioningDelegate as? WispTransitioningDelegate
            else {
                dismiss(animated: true) {
                    guard let context = WispManager.shared.currentContext else { return }
                    context.collectionView?.makeSelectedCellVisible(indexPath: context.sourceIndexPath)
                }
                return
            }
            wispTransitioningDelegate.presentingAnimator.stopAnimation(false)
            wispTransitioningDelegate.presentingAnimator.finishAnimation(at: .current)
        }
        startCardDismissing(withVelocity: initialVelocity)
    }
    
    private func startCardDismissing(withVelocity initialVelocity: CGPoint) {
        defer {
            dismiss(animated: false)
            view.alpha = 0
            view.isHidden = true
        }
        
        let snapshot = view.snapshotView(afterScreenUpdates: true)
        WispManager.shared.contextStackManager.currentContext?.setPresentedSnapshot(snapshot)
        guard let cardContainerView = view.superview else {
            return
        }
        WispManager.shared.handleInteractiveDismissEnded(startFrame: cardContainerView.frame, initialVelocity: initialVelocity)
    }
    
}
