//
//  WispDismissable.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


@MainActor public protocol WispDismissable: UIViewController {
    
    var viewInset: NSDirectionalEdgeInsets { get }
    
    func dismissCard()
    
}



internal extension WispDismissable {
    
    public func dismissCard() {
        let screenCornerRadius = UIDevice.current.userInterfaceIdiom == .pad ? 32.0 : 37.0
        view.layer.cornerRadius = screenCornerRadius
        view.layer.cornerCurve = .continuous
        
        WispManager.shared.activeContext?.presentedSnapshot = view.snapshotView(
            afterScreenUpdates: false
        )
        WispManager.shared.handleInteractiveDismissEnded(startFrame: view.frame)
        dismiss(animated: false)
        view.alpha = 0
        view.isHidden = true
    }
    
}


internal extension WispDismissable {
    
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
