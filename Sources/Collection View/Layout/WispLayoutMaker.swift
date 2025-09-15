//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 9/15/25.
//

import UIKit

public protocol WispLayoutMakerType {
    
    @MainActor
    func make(section: NSCollectionLayoutSection) -> WispCompositionalLayout
    
    @MainActor
    func make(
        section: NSCollectionLayoutSection,
        configuration: UICollectionViewCompositionalLayoutConfiguration
    ) -> WispCompositionalLayout
    
    @MainActor
    func make(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider
    ) -> WispCompositionalLayout
    
    @MainActor
    func make(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
        configuration: UICollectionViewCompositionalLayoutConfiguration
    ) -> WispCompositionalLayout
    
    @MainActor
    func list(using configuration: UICollectionLayoutListConfiguration) -> WispCompositionalLayout
    
}


/// Concrete type of `WispLayoutMakerType`
internal struct WispLayoutMaker: WispLayoutMakerType {
    
    @MainActor
    public func make(section: NSCollectionLayoutSection) -> WispCompositionalLayout {
        return WispCompositionalLayout(section: section)
    }
    
    @MainActor
    public func make(
        section: NSCollectionLayoutSection,
        configuration: UICollectionViewCompositionalLayoutConfiguration
    ) -> WispCompositionalLayout {
        return WispCompositionalLayout(section: section, configuration: configuration)
    }
    
    @MainActor
    public func make(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider
    ) -> WispCompositionalLayout {
        return WispCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    @MainActor
    public func make(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
        configuration: UICollectionViewCompositionalLayoutConfiguration
    ) -> WispCompositionalLayout {
        return WispCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }
    
    @MainActor
    public func list(using configuration: UICollectionLayoutListConfiguration) -> WispCompositionalLayout {
        return WispCompositionalLayout._list(using: configuration)
    }
    
}
