//
//  WispableCollectionView.swift
//  NoteCard
//
//  Created by 김민성 on 7/26/25.
//

import UIKit

import Combine

open class WispableCollectionView: UICollectionView {
    
    private(set) var scrollDetected: PassthroughSubject<Void, Never> = .init()
    
    // 여러 섹션을 이용하는 경우. (sectionProvider 사용)
    public init(
        frame: CGRect,
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
        configuration: UICollectionViewCompositionalLayoutConfiguration? = nil
    ) {
        let customLayout: WispCompositionalLayout
        if let configuration {
            customLayout = WispCompositionalLayout(
                sectionProvider: sectionProvider,
                configuration: configuration
            )
        } else {
            customLayout = WispCompositionalLayout(sectionProvider: sectionProvider)
        }
        super.init(frame: frame, collectionViewLayout: customLayout)
        customLayout.delegate = self
    }
    
    
    // 단일 섹션을 이용하는 경우.
    public init(
        frame: CGRect,
        section: NSCollectionLayoutSection,
        configuration: UICollectionViewCompositionalLayoutConfiguration? = nil
    ) {
        let customLayout: WispCompositionalLayout
        if let configuration {
            customLayout = WispCompositionalLayout(section: section, configuration: configuration)
        } else {
            customLayout = WispCompositionalLayout(section: section)
        }
        super.init(frame: frame, collectionViewLayout: customLayout)
        customLayout.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // list configuration
    
    
}

extension WispableCollectionView {
    
    func makeSelectedCellInvisible(indexPath: IndexPath) {
        cellForItem(at: indexPath)?.alpha = 0
    }
    
    func makeSelectedCellVisible(indexPath: IndexPath) {
        cellForItem(at: indexPath)?.alpha = 1
    }
    
}


extension WispableCollectionView: CustomCompositionalLayoutDelegate {
    
    // scrolling(including orthogonal) detecting
    func layoutInvalidated() {
        scrollDetected.send()
    }
    
}
