//
//  WispContext.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

internal struct WispContext {
    weak var collectionView: WispableCollectionView?
    let indexPath: IndexPath
    let sourceCellSnapshot: UIView?
    var presentedSnapshot: UIView?
    weak var sourceViewController: UIViewController?
    let configuration: WispConfiguration
}
