//
//  WispPresenter.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


public final class WispPresenter {
    
    private weak var presentingViewController: UIViewController?
    
    internal init(presentingVC: UIViewController) {
        self.presentingViewController = presentingVC
    }
    
}

public extension WispPresenter {
    
    @MainActor func present(
        _ viewControllerToPresent: some WispDismissable,
        collectionView: WispableCollectionView,
        at indexPath: IndexPath,
        configuration: WispConfiguration = .default
    ) {
        guard let presentingViewController else { return }
        guard presentingViewController.view.containsAsSubview(collectionView) else {
            print("Collection view is not subview of presenting view controller's view.")
            print("Custom transition will be cancelled and run modal presentation.")
            viewControllerToPresent.modalPresentationStyle = .formSheet
            presentingViewController.present(viewControllerToPresent, animated: true)
            return
        }
        print("presentedViewController: ", presentingViewController.presentedViewController)
        let selectedCell = collectionView.cellForItem(at: indexPath)
        let cellSnapshot = selectedCell?.snapshotView(afterScreenUpdates: false)
        selectedCell?.alpha = 0
        
        let wispContext = WispContext(
            sourceViewController: presentingViewController,
            collectionView: collectionView,
            indexPath: indexPath,
            sourceCellSnapshot: cellSnapshot,
            presentedSnapshot: nil,
            configuration: .default
        )
        let wispTransitioningDelegate = WispTransitioningDelegate(context: wispContext)
        
        WispManager.shared.activeContext = wispContext
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = wispTransitioningDelegate
        presentingViewController.present(viewControllerToPresent, animated: true)
    }
    
}
