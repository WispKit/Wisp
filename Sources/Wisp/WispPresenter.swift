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
        presentingViewController?.present(viewControllerToPresent, animated: true)
    }
    
}
