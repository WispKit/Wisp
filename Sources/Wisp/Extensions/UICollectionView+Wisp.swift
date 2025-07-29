//
//  UICollectionView+Wisp.swift
//  NoteCard
//
//  Created by 김민성 on 7/26/25.
//

import UIKit


public extension UICollectionView {
    
    static func makeWispable(
        frame: CGRect = .zero,
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
    ) -> UICollectionView {
        let customLayout = CustomCompositionalLayout(sectionProvider: sectionProvider)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: customLayout)
        return collectionView
    }
    
    // 단일 섹션 레이아웃만 지원
    static func makeWispable(
        frame: CGRect = .zero,
        section: NSCollectionLayoutSection,
    ) -> UICollectionView {
        let customLayout = CustomCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: customLayout)
        return collectionView
    }
    
}



public extension WispableCollectionView {
    
    var wisp: WispPresenter {
        return WispPresenter(collectionView: self)
    }
    
}
