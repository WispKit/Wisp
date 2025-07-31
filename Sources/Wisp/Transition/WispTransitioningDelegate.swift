//
//  WispTransitioningDelegate.swift
//  NoteCard
//
//  Created by 김민성 on 7/21/25.
//

import Combine
import UIKit


internal final class WispTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private(set) lazy var presentingAnimator = UIViewPropertyAnimator(
        duration: context.configuration.animationSpeed.rawValue,
        dampingRatio: 1
    )
    private let context: WispContext
    private let presentationInteractor = UIPercentDrivenInteractiveTransition()
    private var startCellFrame: CGRect {
        guard let selectedCell = context.collectionView?.cellForItem(at: context.indexPath) else {
            fatalError()
        }
        return selectedCell.convert(selectedCell.contentView.frame, to: nil)
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init(context: WispContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Presentation Controller
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return WispPresentationController(
            presentedViewController: presented as WispPresented,
            presenting: presenting,
        )
    }
    
    // MARK: - Presentation Animator
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        return WispPresentationAnimator(
            animator: presentingAnimator,
            startFrame: startCellFrame,
            interactor: presentationInteractor,
            context: context
        )
    }
    
//     MARK: - Presentation Animator (Interaction)
    func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return self.presentationInteractor
    }
    
}
