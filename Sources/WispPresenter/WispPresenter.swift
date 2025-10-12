//
//  WispPresenter.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

/// Delegate for Wisp lifecycle events
public protocol WispPresenterDelegate: AnyObject {
    /// Called right before a restoring animation starts
    func wispWillRestore()
    /// Called right after restoring finished
    func wispDidRestore()
}

public final class WispPresenter {
    
    public weak var delegate: (any WispPresenterDelegate)?
    private lazy var restorationHandler = WispRestorationHandler(delegate: self.delegate)
    
    private weak var hostViewController: UIViewController?
    private weak var previousPresenter: WispPresenter? = nil
    private weak var nextPresenter: WispPresenter? = nil
    
    internal private(set) var context: WispContext? = nil
    
    private var transitioningDelegate: WispTransitioningDelegate? = nil
    
    internal init(host: UIViewController) {
        self.hostViewController = host
    }
    
}


// MARK: - Public Presentation
public extension WispPresenter {
    
    @MainActor func present(
        _ viewControllerToPresent: UIViewController,
        collectionView: WispableCollectionView,
        at indexPath: IndexPath,
        configuration: WispConfiguration = .default
    ) {
        guard let hostViewController else { return }
        guard hostViewController.view.containsAsSubview(collectionView) else {
            print("Collection view is not subview of presenting view controller's view.")
            print("Custom transition will be cancelled and run modal presentation.")
            viewControllerToPresent.modalPresentationStyle = .formSheet
            hostViewController.present(viewControllerToPresent, animated: true)
            return
        }
        
        /// 바로 직전의 예외처리로 인한 modal presentation을 `dismiss`하고 난 직후 바로 다른 VC를 `present`하려고 할 때,
        /// `dismiss`가 완전히 끝나기 전인 경우,
        /// (`present`되는 시점에 `presentingViewController`의 `presentedViewController` 가 존재하면)
        /// 의도한 custom transition 대신 `.fullScreen` 방식으로 transition되는 문제 발생.
        /// 시스템이 자동으로 fullscreen transition을 채택하는 것 같다.
//        guard sourceViewController.presentedViewController == nil else { return }
        
        let selectedCell = collectionView.cellForItem(at: indexPath)
        let cellSnapshot = selectedCell?.snapshotView(afterScreenUpdates: false)
        
        let wispContext = WispContext(
            sourceViewController: hostViewController,
            viewControllerToPresent: viewControllerToPresent,
            collectionView: collectionView,
            sourceIndexPath: indexPath,
            sourceCellSnapshot: cellSnapshot,
            configuration: configuration
        )
        
        self.context = wispContext
        let wispTransitioningDelegate = WispTransitioningDelegate(context: wispContext)
        self.transitioningDelegate = wispTransitioningDelegate
        
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = wispTransitioningDelegate
        let nextPresenter = viewControllerToPresent.wisp
        self.nextPresenter = nextPresenter
        nextPresenter.previousPresenter = self
        
        hostViewController.view.endEditing(true)
        hostViewController.present(viewControllerToPresent, animated: true)
    }
    
}


// MARK: - Public Dismissal
public extension WispPresenter {
    
    @MainActor
    func dismiss(to indexPath: IndexPath? = nil, animated: Bool = true, autoFallback: Bool = false) {
        guard let hostViewController else {
            return
        }
        
        // validating if the vc to be dismissed is presented by `Wisp`
        guard let actualVCToDismiss = hostViewController.presentingViewController?.presentedViewController,
              let previousPresenter = actualVCToDismiss.wisp.previousPresenter,
              let previousContext = previousPresenter.context,
              actualVCToDismiss == previousContext.viewControllerToPresent
        else {
            if autoFallback {
                hostViewController.dismiss(animated: animated)
            } else {
                print("""
                      Warning: Attempted to dismiss a view controller that was not presented with Wisp. No action was taken.
                      You can either set `autoFallback: true` to allow Wisp to automatically fallback to a standard UIKit dismissal,
                      or call the standard `dismiss(animated:completion:)` method directly on the view controller to handle dismissal explicitly.
                      """)
            }
            return
        }
        
        // switching previousPresenter's context to apply the `indexPath` parameter.
        if let newDestinationIndexPath = indexPath {
            previousPresenter.context?.destinationIndexPath = newDestinationIndexPath
        }
        
        if animated {
            previousPresenter.dismissPresentedVC()
        } else {
            hostViewController.dismiss(animated: false)
            previousPresenter.context?.collectionView?.makeSelectedCellVisible(indexPath: previousContext.sourceIndexPath)
        }
    }
    
    @MainActor
    func setDestinationIndex(to indexPath: IndexPath) {
        guard let hostViewController else {
            return
        }
        
        guard let actualVCToDismiss = hostViewController.presentingViewController?.presentedViewController,
              let previousPresenter = actualVCToDismiss.wisp.previousPresenter,
              let previousContext = previousPresenter.context,
              actualVCToDismiss == previousContext.viewControllerToPresent
        else {
            return
        }
        previousPresenter.context?.destinationIndexPath = indexPath
    }
    
}


internal extension WispPresenter {
    
    func dismissPresentedVC(withVelocity initialVelocity: CGPoint = .zero) {
        guard let context,
              let viewControllerToDismiss = context.viewControllerToPresent
        else {
            return
        }
        
        guard let transitioningDelegate else {
            context.collectionView?.makeSelectedCellVisible(indexPath: context.sourceIndexPath)
            viewControllerToDismiss.dismiss(animated: true)
            return
        }
        
        if viewControllerToDismiss.isBeingPresented {
            transitioningDelegate.presentingAnimator.stopAnimation(false)
            transitioningDelegate.presentingAnimator.finishAnimation(at: .current)
        }
        
        Task {
            await startWispDismissing(with: initialVelocity)
        }
    }
    
}


private extension WispPresenter {
    
    @MainActor func startWispDismissing(with initialVelocity: CGPoint) {
        guard let context,
              let viewControllerToDismiss = context.viewControllerToPresent
        else {
            return
        }
        
        let snapshot = viewControllerToDismiss.view.snapshotView(afterScreenUpdates: true)
        context.setPresentedSnapshot(snapshot)
        guard let cardContainerView = viewControllerToDismiss.view.superview else {
            return
        }
        
        guard let collectionView = context.collectionView,
              let destinationIndexPath = context.destinationIndexPath,
              let targetCell = collectionView.cellForItem(at: destinationIndexPath)
        else {
            // Apply fallback dismissing animation when target collectionView or cell is missing
            delegate?.wispWillRestore()
            viewControllerToDismiss.dismiss(animated: true) { [weak self] in
                self?.delegate?.wispDidRestore()
            }
            return
        }
        
        delegate?.wispWillRestore()
        restorationHandler.restore(
            startFrame: cardContainerView.frame,
            initialVelocity: initialVelocity,
            context: context
        )
        viewControllerToDismiss.dismiss(animated: false)
        viewControllerToDismiss.view.isHidden = true
        
        self.transitioningDelegate = nil
        self.context = nil
    }
    
}
