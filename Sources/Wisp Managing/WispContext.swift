//
//  WispContext.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

internal struct WispContext {
    
    weak var sourceViewController: UIViewController?
    weak var viewControllerToPresent: UIViewController?
    weak var collectionView: WispableCollectionView?
    
    let sourceIndexPath: IndexPath
    var destinationIndexPath: IndexPath?
    let sourceCellSnapshot: UIView?
    var presentedSnapshot: UIView?
    let configuration: WispConfiguration
    
    var isIndexPathChanged: Bool { sourceIndexPath != destinationIndexPath}
    
    internal mutating func setPresentedSnapshot(_ snapshot: UIView?) {
        self.presentedSnapshot = snapshot
    }
    
}
