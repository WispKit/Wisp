//
//  HomeViewSection.swift
//  WispExample
//
//  Created by kinsgmin on 12/10/25.
//

import UIKit
import Wisp

struct HomeViewSection {
    
    struct Item {
        let vcType: UIViewController.Type
        let vcTypeName: String
    }
    
    let title: String
    let items: [Item]
    let configuration: WispConfiguration
    let layout: NSCollectionLayoutSection
    
    static var defaultItems: [Item] = [
        .init(vcType: BlueViewController.self, vcTypeName: "plain"),
        .init(vcType: MovieContentViewController.self, vcTypeName: "movie\ncontent"),
        .init(vcType: TextContentViewController.self, vcTypeName: "textView"),
    ]

    static func allSections(view: UIView) -> [HomeViewSection] {
        return [
            .init(
                title: "Modal",
                items: Self.defaultItems,
                configuration: WispConfiguration(configure: { config in
                    config.setLayout { layout in
                        layout.presentedAreaInset = .init(top: view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
                        layout.initialCornerRadius = 10
                    }
                }),
                layout: smallItemSection()
            ),
            .init(
                title: "Small Card",
                items: Self.defaultItems,
                configuration: WispConfiguration(configure: { config in
                    config.setLayout { layout in
                        layout.presentedAreaInset = .init(top: 270, left: 10, bottom: 270, right: 10)
                        layout.initialCornerRadius = 10
                    }
                }),
                layout: smallItemSection()
            ),
            .init(
                title: "Big Card",
                items: Self.defaultItems,
                configuration: WispConfiguration(configure: { config in
                    config.setLayout { layout in
                        layout.presentedAreaInset = .init(top: 130, left: 10, bottom: 130, right: 10)
                        layout.initialCornerRadius = 10
                    }
                }),
                layout: mediumItemSection()
            ),
            .init(
                title: "Fullscreen",
                items: Self.defaultItems,
                configuration: WispConfiguration(configure: { config in
                    config.setLayout { layout in
                        layout.presentedAreaInset = .zero
                        layout.initialCornerRadius = 10
                    }
                }),
                layout: smallItemSection()
            )
        ]
    }
}

private func smallItemSection() -> NSCollectionLayoutSection {
    let item = NSCollectionLayoutItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                          heightDimension: .fractionalHeight(1.0))
    )
    item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(widthDimension: .absolute(110),
                          heightDimension: .absolute(160)),
        subitems: [item]
    )
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
    section.orthogonalScrollingBehavior = .continuous
    section.boundarySupplementaryItems = [
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                heightDimension: .absolute(40)),
              elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    ]
    return section
}

private func mediumItemSection() -> NSCollectionLayoutSection {
    let item = NSCollectionLayoutItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                          heightDimension: .fractionalHeight(1.0))
    )
    item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(widthDimension: .absolute(180),
                          heightDimension: .absolute(270)),
        subitems: [item]
    )

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
    section.orthogonalScrollingBehavior = .continuous
    section.boundarySupplementaryItems = [
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                heightDimension: .absolute(40)),
              elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    ]
    return section
}
