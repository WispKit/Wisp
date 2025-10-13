//
//  WispContext.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

internal final class WispContext {
    
    weak var sourceViewController: UIViewController?
    weak var viewControllerToPresent: UIViewController?
    weak var collectionView: WispableCollectionView?
    
    let sourceIndexPath: IndexPath
    var destinationIndexPath: IndexPath?
    let sourceCellSnapshot: UIView?
    var presentedSnapshot: UIView? = nil
    let configuration: WispConfiguration
    
    var isIndexPathChanged: Bool { sourceIndexPath != destinationIndexPath}
    
    init(
        sourceViewController: UIViewController,
        viewControllerToPresent: UIViewController,
        collectionView: WispableCollectionView,
        sourceIndexPath: IndexPath,
        sourceCellSnapshot: UIView?,
        configuration: WispConfiguration
    ) {
        self.sourceViewController = sourceViewController
        self.viewControllerToPresent = viewControllerToPresent
        self.collectionView = collectionView
        self.sourceIndexPath = sourceIndexPath
        self.destinationIndexPath = sourceIndexPath
        self.sourceCellSnapshot = sourceCellSnapshot
        self.configuration = configuration
    }
    
    func setPresentedSnapshot(_ snapshot: UIView?) {
        self.presentedSnapshot = snapshot
    }
    
}
