//
//  WispPresenter.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

/// Delegate for Wisp lifecycle events
@objc public protocol WispPresenterDelegate: AnyObject {
    /// Called right before a restoring animation starts
    @objc optional func wispWillRestore()
    /// Called right after restoring finished
    @objc optional func wispDidRestore()
}

public final class WispPresenter {
    
    internal enum State {
        case idle
        case presenting
        case presented
        case dismissing
        case restoring
    }
    
    public weak var delegate: (any WispPresenterDelegate)?
    private lazy var restorationHandler = WispRestorationHandler(delegate: self.delegate)
    
    private weak var hostViewController: UIViewController?
    private weak var previousPresenter: WispPresenter? = nil
    private weak var nextPresenter: WispPresenter? = nil
    
    internal private(set) var context: WispContext? = nil
    internal private(set) var state: State = .idle 
    
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
        guard state != .presenting else {
            print("""
            ⚠️ Wisp Warning: Duplicate presentation detected from \(hostViewController)
            Wisp will proceed only with the first presentation call and ignore any subsequent ones.
            """)
            return
        }
        state = .presenting
        guard hostViewController.view.containsAsSubview(collectionView) else {
            fatalError("""
            WispPresenter Error: The collection view must be a subview of the presenting view controller's view.
            """)
        }
        
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
        hostViewController.present(viewControllerToPresent, animated: true) { [weak self] in
            guard let self else { return }
            self.state = .presented
        }
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
            // TODO: - 예외처리 필요
            return
        }
        
        guard context.collectionView?.window != nil else {
            print("""
                  ⚠️ Warning: collectionView.window is nil — unable to perform restore animation.
                  Falling back to default dismiss transition.
                  """)
            context.collectionView?.makeSelectedCellVisible(indexPath: context.sourceIndexPath)
            delegate?.wispWillRestore?()
            viewControllerToDismiss.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                self.delegate?.wispDidRestore?()
            }
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
            self.state = .dismissing
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
            delegate?.wispWillRestore?()
            viewControllerToDismiss.dismiss(animated: true) { [weak self] in
                self?.delegate?.wispDidRestore?()
            }
            return
        }
        
        delegate?.wispWillRestore?()
        state = .restoring
        restorationHandler.restore(
            startFrame: cardContainerView.frame,
            initialVelocity: initialVelocity,
            context: context
        ) { [weak self] in
            guard let self else { return }
            self.state = .idle
        }
        viewControllerToDismiss.dismiss(animated: false)
        viewControllerToDismiss.view.isHidden = true
        
        self.transitioningDelegate = nil
        self.context = nil
    }
    
}
