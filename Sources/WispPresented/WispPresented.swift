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
        let screenCornerRadius = UIDevice.current.userInterfaceIdiom == .pad ? 32.0 : 37.0
        view.layer.cornerRadius = screenCornerRadius
        view.layer.cornerCurve = .continuous
        
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
        let snapshot = view.snapshotView(afterScreenUpdates: true)
        WispManager.shared.contextStackManager.currentContext?.setPresentedSnapshot(snapshot)
        WispManager.shared.handleInteractiveDismissEnded(startFrame: view.frame)
        dismiss(animated: false)
        view.alpha = 0
        view.isHidden = true
    }
    
}


internal extension WispPresented {
    
    func setViewShowingInitialState(startFrame: CGRect) {
        let cardFinalFrame = view.frame
        
        let centerDiffX = startFrame.center.x - cardFinalFrame.center.x
        let centerDiffY = startFrame.center.y - cardFinalFrame.center.y
        
        let cardWidthScaleDiff = startFrame.width / cardFinalFrame.width
        let cardHeightScaleDiff = startFrame.height / cardFinalFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: cardWidthScaleDiff, y: cardHeightScaleDiff)
        let centerTransform = CGAffineTransform(translationX: centerDiffX, y: centerDiffY)
        let cardTransform = scaleTransform.concatenating(centerTransform)
        let screenCornerRadius = UIDevice.current.userInterfaceIdiom == .pad ? 32.0 : 20.0
        view.layer.cornerRadius = screenCornerRadius / ((cardWidthScaleDiff + cardHeightScaleDiff)/2)
        view.layer.cornerCurve = .continuous
        view.transform = cardTransform
    }
    
    func setSnapshotShowingFinalState(
        _ snapshot: UIView?,
        blurView: UIVisualEffectView
    ) {
        snapshot?.alpha = 0
        blurView.effect = UIBlurEffect(style: .regular)
    }
    
    func setViewShowingFinalState() {
        let screenCornerRadius = UIDevice.current.userInterfaceIdiom == .pad ? 32.0 : 37.0
        view.layer.cornerRadius = screenCornerRadius
        view.layer.cornerCurve = .continuous
        view.transform = .identity
    }
    
}
