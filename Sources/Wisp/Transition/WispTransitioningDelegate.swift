//
//  WispTransitioningDelegate.swift
//  NoteCard
//
//  Created by 김민성 on 7/21/25.
//

import Combine
import UIKit


internal final class WispTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let presentationInteractor = UIPercentDrivenInteractiveTransition()
    private let startCellFrame: CGRect
    private var cancellables: Set<AnyCancellable> = []
    
    init(context: WispContext) {
        // 시작할 때 셀 frame
        guard let selectedCell = context.collectionView?.cellForItem(at: context.indexPath) else {
            fatalError()
        }
        let convertedCellFrame = selectedCell.convert(selectedCell.contentView.frame, to: nil)
        self.startCellFrame = convertedCellFrame
        super.init()
    }
    
    // MARK: - Presentation Controller
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        guard let wispDismissableVC = presented as? WispPresented else {
            fatalError()
        }
        return WispPresentationController(
            presentedViewController: wispDismissableVC,
            presenting: presenting,
        )
    }
    
    // MARK: - Presentation Animator
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        return WispPresentationAnimator(startFrame: startCellFrame, interactor: presentationInteractor)
    }
    
    // MARK: - Presentation Animator (Interaction)
    func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return self.presentationInteractor
    }
    
}
