//
//  WispableCollectionView.swift
//  NoteCard
//
//  Created by 김민성 on 7/26/25.
//

import UIKit

import Combine

public class WispableCollectionView: UICollectionView {
    
    private(set) var scrollDetected: PassthroughSubject<Void, Never> = .init()
    
    
    // 여러 섹션을 이용하는 경우. sectionProvider 사용
    public init(frame: CGRect, sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) {
        let customLayout = CustomCompositionalLayout(sectionProvider: sectionProvider)
        super.init(frame: frame, collectionViewLayout: customLayout)
        customLayout.delegate = self
    }
    
    // 단일 섹션을 이용하는 경우.
    public init(frame: CGRect, section: NSCollectionLayoutSection) {
        let customLayout = CustomCompositionalLayout(section: section)
        super.init(frame: frame, collectionViewLayout: customLayout)
        customLayout.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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


public extension WispableCollectionView {
    
    var wisp: WispPresenter {
        return WispPresenter(collectionView: self)
    }
    
}
