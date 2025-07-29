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
        _ viewControllerToPresent: some WispPresented,
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
        
        /// modal presentation을 `dismiss`하고 난 직후 바로 다른 VC를 `present`하려고 할 때,
        /// `dismiss`가 완전히 끝나기 전인 경우,
        /// (`present`되는 시점에 `presentingViewController`의 `presentedViewController` 가 존재하면)
        /// 의도한 custom transition 대신 `.fullScreen` 방식으로 transition되는 문제 발생.
        /// 시스템이 자동으로 fullscreen transition을 채택하는 것 같다.
        guard presentingViewController.presentedViewController == nil else { return }
        
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
