//
//  WispPresented.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


@MainActor public protocol WispPresented: UIViewController {
    
    func dismissCard()
    
}


public extension WispPresented {
    
    func dismissCard() {
        // 배경 블러 없애기
        guard let presentationController = presentationController as? WispPresentationController else {
            return
        }
        presentationController.tapRecognizingBlurView.effect = nil
        
        if isBeingPresented {
            guard
                let wispTransitioningDelegate = transitioningDelegate as? WispTransitioningDelegate
            else {
                dismiss(animated: true) {
                    guard let context = WispManager.shared.currentContext else { return }
                    context.collectionView?.cellForItem(at: context.indexPath)?.alpha = 1
                }
                return
            }
            wispTransitioningDelegate.presentingAnimator.stopAnimation(false)
            wispTransitioningDelegate.presentingAnimator.finishAnimation(at: .current)
        }
        startCardDismissing()
    }
    
    private func startCardDismissing() {
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
        WispManager.shared.handleInteractiveDismissEnded(startFrame: cardContainerView.frame)
    }
    
}
