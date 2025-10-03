//
//  WispPresenter.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


public final class WispPresenter {
    
    private weak var sourceViewController: UIViewController?
    
    internal init(source: UIViewController) {
        self.sourceViewController = source
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
        guard let sourceViewController else { return }
        guard sourceViewController.view.containsAsSubview(collectionView) else {
            print("Collection view is not subview of presenting view controller's view.")
            print("Custom transition will be cancelled and run modal presentation.")
            viewControllerToPresent.modalPresentationStyle = .formSheet
            sourceViewController.present(viewControllerToPresent, animated: true)
            return
        }
        
        /// 바로 직전의 예외처리로 인한 modal presentation을 `dismiss`하고 난 직후 바로 다른 VC를 `present`하려고 할 때,
        /// `dismiss`가 완전히 끝나기 전인 경우,
        /// (`present`되는 시점에 `presentingViewController`의 `presentedViewController` 가 존재하면)
        /// 의도한 custom transition 대신 `.fullScreen` 방식으로 transition되는 문제 발생.
        /// 시스템이 자동으로 fullscreen transition을 채택하는 것 같다.
        guard sourceViewController.presentedViewController == nil else { return }
        
        let selectedCell = collectionView.cellForItem(at: indexPath)
        let cellSnapshot = selectedCell?.snapshotView(afterScreenUpdates: false)
        
        let wispContext = WispContext(
            sourceViewController: sourceViewController,
            viewControllerToPresent: viewControllerToPresent,
            collectionView: collectionView,
            sourceIndexPath: indexPath,
            destinationIndexPath: indexPath,
            sourceCellSnapshot: cellSnapshot,
            presentedSnapshot: nil,
            configuration: configuration
        )
        
        let wispTransitioningDelegate = WispTransitioningDelegate(
            context: wispContext,
        )
        
        WispManager.shared.contextStackManager.push(wispContext)
        WispManager.shared.transitioningDelegate = wispTransitioningDelegate
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = wispTransitioningDelegate
        sourceViewController.view.endEditing(true)
        sourceViewController.present(viewControllerToPresent, animated: true)
    }
    
}


// MARK: - Public Dismissal
public extension WispPresenter {
    
    @MainActor
    func dismiss(to indexPath: IndexPath? = nil, animated: Bool = true, autoFallback: Bool = false) {
        guard let sourceViewController else {
            return
        }
        
        // validating if the vc to be dismissed is presented by `Wisp`
        /*
         currentContext.viewControllerToPresent와 sourceViewController.presentingViewController?.presentedViewController를 비교하는 이유는
         sourceViewController가 navigationController 안의 VC인 경우, currentContext.viewControllerToPresent와 다른 값이 나올 수도 있기 때문.
         */
        guard let currentContext = WispManager.shared.contextStackManager.currentContext,
              let vcToPresentInContext = currentContext.viewControllerToPresent,
              vcToPresentInContext == sourceViewController.presentingViewController?.presentedViewController,
              let wispPresentaitonController = vcToPresentInContext.presentationController as? WispPresentationController
        else {
            if autoFallback {
                sourceViewController.dismiss(animated: animated)
            } else {
                print("""
                      Warning: Attempted to dismiss a view controller that was not presented with Wisp. No action was taken.
                      You can either set `autoFallback: true` to allow Wisp to automatically fallback to a standard UIKit dismissal,
                      or call the standard `dismiss(animated:completion:)` method directly on the view controller to handle dismissal explicitly.
                      """)
            }
            return
        }
        
        // switching current context to apply the `indexPath` parameter.
        var newContext = consume currentContext
        newContext.destinationIndexPath = indexPath ?? newContext.sourceIndexPath
        WispManager.shared.contextStackManager.currentContext = newContext
        
        if animated {
            wispPresentaitonController.presentedViewController.dismissCard()
        } else {
            sourceViewController.dismiss(animated: false)
            newContext.collectionView?.makeSelectedCellVisible(indexPath: newContext.sourceIndexPath)
        }
    }
    
    @MainActor
    func setDestinationIndex(to indexPath: IndexPath) {
        guard sourceViewController != nil else {
            return
        }
        guard let oldContext = WispManager.shared.contextStackManager.pop() else {
            return
        }
        var newContext = consume oldContext
        newContext.destinationIndexPath = indexPath
        WispManager.shared.contextStackManager.push(newContext)
    }
    
}
