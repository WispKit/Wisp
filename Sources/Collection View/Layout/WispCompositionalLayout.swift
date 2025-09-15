//
//  WispCompositionalLayout.swift
//  NoteCard
//
//  Created by 김민성 on 7/26/25.
//

import UIKit

internal protocol CustomCompositionalLayoutDelegate: AnyObject {
    
    func layoutInvalidated()
    
}


// section 정보를 받아와서 스크롤을 추척 (delegate method 호출)
public class WispCompositionalLayout: UICollectionViewCompositionalLayout {
    
    /// If this layout was created via `._ist(using:)`, `backingListLayout` holds the
    /// `UICollectionViewCompositionalLayout` returned by `UICollectionViewCompositionalLayout.list(using:)`.
    ///
    /// - When `backingLayout` is non-nil (the list case), the collection view uses that backing list layout for actual rendering.
    ///   In this mode `WispCompositionalLayout` acts as a wrapper:
    ///   rendering is delegated to `backingListLayout`, while Wisp still provides scroll-detection
    ///   and delegate forwarding behavior.
    ///
    /// - When `backingListLayout` is nil (the normal, non-list case), the collection view uses
    ///   `WispCompositionalLayout` itself for rendering, and Wisp's internal hooks
    ///   (e.g. visible-items invalidation handlers) are applied directly to the section(s).
    ///
    /// This property is internal and managed by Wisp; consumers should not modify it.
    internal var backingListLayout: UICollectionViewCompositionalLayout? = nil
    
    internal weak var delegate: (any CustomCompositionalLayoutDelegate)?
    
    @available(*, unavailable, message: "Direct initialization of `WispCompositionalLayout` is not supported. Please use a static method such as `UICollectionViewCompositionalLayout.wisp.make(...)`.")
    private init() {
        fatalError("Direct initialization of `WispCompositionalLayout` is not supported. Please use a static method such as `UICollectionViewCompositionalLayout.wisp.make(...)`.")
    }
    
    internal override init(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider
    ) {
        
        /// - NOTE: 사용자가 제공한 `sectionProvider`를 재정의하여 사용.
        /// 모든 `section`의 `visibleItemsInvalidationHandler`가 `nil`이면
        /// compositional layout의 main axis의 스크롤 시에는 `delegate` 함수가 호출되지 않음.
        /// `visibleItemsInvalidationHandler`에 명시적으로 클로저를 할당하여 모든 방향의 스크롤시 `delegate`  메서드 호출하도록 구현함.
        super.init(sectionProvider: { sectionIndex, layoutEnvironment in
            guard let section = sectionProvider(sectionIndex, layoutEnvironment) else { return nil }
            let originalHandler = section.visibleItemsInvalidationHandler
            section.visibleItemsInvalidationHandler = { visibleItems, contentOffset, environment in
                originalHandler?(visibleItems, contentOffset, environment)
            }
            return section
        })
    }
    
    internal override init(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
        configuration: UICollectionViewCompositionalLayoutConfiguration
    ) {
        super.init(
            sectionProvider: { sectionIndex, layoutEnvironment in
                guard let section = sectionProvider(sectionIndex, layoutEnvironment) else { return nil }
                let originalHandler = section.visibleItemsInvalidationHandler
                section.visibleItemsInvalidationHandler = { visibleItems, contentOffset, environment in
                    originalHandler?(visibleItems, contentOffset, environment)
                }
                return section
            },
            configuration: configuration
        )
    }

    internal override init(section: NSCollectionLayoutSection) {
        let originalHandler = section.visibleItemsInvalidationHandler
        section.visibleItemsInvalidationHandler = { visibleItems, contentOffset, environment in
            originalHandler?(visibleItems, contentOffset, environment)
        }
        
        /// - NOTE: 사용자가 제공한 `NSCollectionLayoutSection` 인스턴스의 `visibleItemsInvalidationHandler`가 `nil`이면
        /// compositional layout의 main axis의 스크롤 시에는 `delegate` 함수가 호출되지 않음.
        /// `visibleItemsInvalidationHandler`에 명시적으로 클로저를 할당하여 모든 방향의 스크롤시 `delegate`  메서드 호출하도록 구현함.
        super.init(section: section)
    }
    
    internal override init(
        section: NSCollectionLayoutSection,
        configuration: UICollectionViewCompositionalLayoutConfiguration
    ) {
        let originalHandler = section.visibleItemsInvalidationHandler
        section.visibleItemsInvalidationHandler = { visibleItems, contentOffset, environment in
            originalHandler?(visibleItems, contentOffset, environment)
        }
        
        /// - NOTE: 사용자가 제공한 `NSCollectionLayoutSection` 인스턴스의 `visibleItemsInvalidationHandler`가 `nil`이면
        /// compositional layout의 main axis의 스크롤 시에는 `delegate` 함수가 호출되지 않음.
        /// `visibleItemsInvalidationHandler`에 명시적으로 클로저를 할당하여 모든 방향의 스크롤시 `delegate`  메서드 호출하도록 구현함.
        super.init(section: section, configuration: configuration)
    }
    
    internal static func _list(using configuration: UICollectionLayoutListConfiguration) -> WispCompositionalLayout {
        let wispLayout = WispCompositionalLayout.dummy
        wispLayout.backingListLayout = self.list(using: configuration)
        return wispLayout
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // 레이아웃이 무효화될 때마다 호출되는 메서드를 오버라이드합니다.
    override public func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        delegate?.layoutInvalidated()
    }
    
}


private extension WispCompositionalLayout {
    
    /// A placeholder `WispCompositionalLayout` instance used only for initialization purposes.
    /// This layout itself is never used for rendering; the actual rendering is delegated to `backingListLayout`.
    static var dummy: WispCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(.zero), heightDimension: .absolute(.zero)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .absolute(.zero), heightDimension: .absolute(.zero)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        return WispCompositionalLayout(section: section)
    }
    
}
